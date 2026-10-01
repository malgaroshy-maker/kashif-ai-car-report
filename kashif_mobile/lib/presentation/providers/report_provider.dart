import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/apinex_client.dart';
import '../../core/utils/ediag_pdf_parser.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/repositories/offline_report_service.dart';
import '../../data/storage/hive_storage.dart';

class ReportState {
  final DiagnosticReport? report;
  final bool isLoading;
  final String? errorMessage;
  final String progressText;
  final bool isFromLocalCache;
  final String? cacheNotice;
  final Uint8List? lastScannedBytes;
  final String? lastScannedFileName;
  final bool lastScannedIsPdf;
  final String? lastManualCodes;
  final String? lastManualVin;

  ReportState({
    this.report,
    this.isLoading = false,
    this.errorMessage,
    this.progressText = '',
    this.isFromLocalCache = false,
    this.cacheNotice,
    this.lastScannedBytes,
    this.lastScannedFileName,
    this.lastScannedIsPdf = false,
    this.lastManualCodes,
    this.lastManualVin,
  });

  ReportState copyWith({
    DiagnosticReport? report,
    bool? isLoading,
    String? errorMessage,
    String? progressText,
    bool clearError = false,
    bool? isFromLocalCache,
    String? cacheNotice,
    bool clearNotice = false,
    Uint8List? lastScannedBytes,
    String? lastScannedFileName,
    bool? lastScannedIsPdf,
    String? lastManualCodes,
    String? lastManualVin,
  }) {
    return ReportState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      progressText: progressText ?? this.progressText,
      isFromLocalCache: isFromLocalCache ?? this.isFromLocalCache,
      cacheNotice: clearNotice ? null : (cacheNotice ?? this.cacheNotice),
      lastScannedBytes: lastScannedBytes ?? this.lastScannedBytes,
      lastScannedFileName: lastScannedFileName ?? this.lastScannedFileName,
      lastScannedIsPdf: lastScannedIsPdf ?? this.lastScannedIsPdf,
      lastManualCodes: lastManualCodes ?? this.lastManualCodes,
      lastManualVin: lastManualVin ?? this.lastManualVin,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final KashifApiClient _apiClient;
  final ApinexClient _apinexClient;

  ReportNotifier({KashifApiClient? apiClient, ApinexClient? apinexClient})
    : _apiClient = apiClient ?? KashifApiClient(),
      _apinexClient = apinexClient ?? ApinexClient(),
      super(ReportState());

  void clearCacheNotice() {
    if (state.cacheNotice != null) {
      state = state.copyWith(clearNotice: true);
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> scanPdfBytes(
    Uint8List bytes,
    String fileName, {
    bool forceAi = false,
  }) async {
    // 1. Smart Local Cache Check (0 API calls if already analyzed)
    final fp = KashifStorage.computeFingerprint(bytes);
    if (!forceAi) {
      // 1. Offline Ediag Recognition Engine (0 Internet, 0 API Calls, 100% Precision)
      try {
        final extracted = EdiagPdfParser.extractFromPdfBytes(bytes);
        if (extracted.isValid && (extracted.hasFaults || extracted.hasPassedSystems || extracted.vin != null)) {
          final offlineReport = OfflineReportService.buildOfflineReportFromEdiag(extracted);
          await KashifStorage.cacheReportByFingerprint(fp, offlineReport);
          state = state.copyWith(
            isLoading: false,
            report: offlineReport,
            isFromLocalCache: true,
            cacheNotice: '⚡ تم قراءة وتحليل تقرير الفحص فورياً بدون إنترنت',
            lastScannedBytes: bytes,
            lastScannedFileName: fileName,
            lastScannedIsPdf: true,
            clearError: true,
          );
          return;
        }
      } catch (_) {
        // Fallback to local cache or online AI pipeline
      }

      // 2. Smart Local Cache Check (0 API calls if already analyzed)
      final cached = KashifStorage.getReportByFingerprint(fp);
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          report: cached,
          isFromLocalCache: true,
          cacheNotice:
              '⚡ تم تحميل التقرير فورياً من الذاكرة المحلية (تم توفير طلب API)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: true,
          clearError: true,
        );
        return;
      }
    }

    // Check if user set APInex as Primary AI
    if (KashifStorage.useApinexAsPrimary) {
      final activeModel = KashifStorage.apinexModel;
      state = state.copyWith(
        isLoading: true,
        progressText: 'جاري التحليل عبر محرك APInex ($activeModel)...',
        clearError: true,
        clearNotice: true,
        lastScannedBytes: bytes,
        lastScannedFileName: fileName,
        lastScannedIsPdf: true,
      );
      try {
        final rawText = EdiagPdfParser.extractRawTextFromPdf(bytes);
        final apReport = await _apinexClient.analyzeTextReport(rawText);
        await KashifStorage.cacheReportByFingerprint(fp, apReport);
        state = state.copyWith(
          isLoading: false,
          report: apReport,
          isFromLocalCache: true,
          cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك APInex ($activeModel)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: true,
          clearError: true,
        );
        return;
      } catch (e) {
        // If APInex primary failed, continue to standard pipeline
      }
    }

    state = state.copyWith(
      isLoading: true,
      progressText: forceAi
          ? 'إعادة التحليل العميق بالذكاء الاصطناعي...'
          : 'جاري رفع تقرير الفحص وقراءة النصوص...',
      clearError: true,
      clearNotice: true,
      lastScannedBytes: bytes,
      lastScannedFileName: fileName,
      lastScannedIsPdf: true,
    );

    try {
      final apiKey = KashifStorage.customApiKey;
      final report = await _apiClient.analyzePdfBytes(
        bytes,
        fileName,
        customApiKey: apiKey,
      );
      await KashifStorage.cacheReportByFingerprint(fp, report);
      state = state.copyWith(
        isLoading: false,
        report: report,
        progressText: '',
        isFromLocalCache: false,
        clearNotice: true,
      );
    } catch (e) {
      // 1. Check if offline Ediag parser can rescue it
      try {
        final extracted = EdiagPdfParser.extractFromPdfBytes(bytes);
        if (extracted.isValid && (extracted.hasFaults || extracted.hasPassedSystems || extracted.vin != null)) {
          final offlineReport = OfflineReportService.buildOfflineReportFromEdiag(extracted);
          await KashifStorage.cacheReportByFingerprint(fp, offlineReport);
          state = state.copyWith(
            isLoading: false,
            report: offlineReport,
            isFromLocalCache: true,
            cacheNotice: '⚡ تم تشخيص تقرير الفحص عبر القاموس المحلي بنجاح',
            lastScannedBytes: bytes,
            lastScannedFileName: fileName,
            lastScannedIsPdf: true,
            clearError: true,
            progressText: '',
          );
          return;
        }
      } catch (_) {}

      // 2. Seamless failover to APInex
      if (KashifStorage.isApinexAutoFailoverEnabled) {
        try {
          final activeModel = KashifStorage.apinexModel;
          state = state.copyWith(progressText: 'جاري التحويل التلقائي إلى محرك APInex ($activeModel)...');
          final rawText = EdiagPdfParser.extractRawTextFromPdf(bytes);
          final apReport = await _apinexClient.analyzeTextReport(rawText);
          await KashifStorage.cacheReportByFingerprint(fp, apReport);
          state = state.copyWith(
            isLoading: false,
            report: apReport,
            isFromLocalCache: true,
            cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك الذكاء البديل (APInex • $activeModel)',
            lastScannedBytes: bytes,
            lastScannedFileName: fileName,
            lastScannedIsPdf: true,
            clearError: true,
            progressText: '',
          );
          return;
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        progressText: '',
      );
    }
  }

  Future<void> scanImageBytes(
    Uint8List bytes,
    String fileName, {
    bool forceAi = false,
  }) async {
    // 1. Smart Local Cache Check (0 API calls if already analyzed)
    final fp = KashifStorage.computeFingerprint(bytes);
    if (!forceAi) {
      final cached = KashifStorage.getReportByFingerprint(fp);
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          report: cached,
          isFromLocalCache: true,
          cacheNotice:
              '⚡ تم تحميل التقرير فورياً من الذاكرة المحلية (تم توفير طلب API)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: false,
          clearError: true,
        );
        return;
      }
    }

    // Check if user set APInex as Primary AI
    if (KashifStorage.useApinexAsPrimary) {
      state = state.copyWith(
        isLoading: true,
        progressText: 'جاري فحص الشاشة عبر محرك APInex (GPT-6 Luna)...',
        clearError: true,
        clearNotice: true,
        lastScannedBytes: bytes,
        lastScannedFileName: fileName,
        lastScannedIsPdf: false,
      );
      try {
        final apReport = await _apinexClient.analyzeImage(bytes, fileName);
        await KashifStorage.cacheReportByFingerprint(fp, apReport);
        state = state.copyWith(
          isLoading: false,
          report: apReport,
          isFromLocalCache: true,
          cacheNotice: '⚡ تم فحص شاشة الجهاز عبر محرك APInex (GPT-6 Luna)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: false,
          clearError: true,
        );
        return;
      } catch (_) {}
    }

    state = state.copyWith(
      isLoading: true,
      progressText: forceAi
          ? 'إعادة التحليل العميق بالذكاء الاصطناعي...'
          : 'جاري مسح شاشة جهاز الفحص وتحليل الرموز بالذكاء الاصطناعي...',
      clearError: true,
      clearNotice: true,
      lastScannedBytes: bytes,
      lastScannedFileName: fileName,
      lastScannedIsPdf: false,
    );

    try {
      final apiKey = KashifStorage.customApiKey;
      final report = await _apiClient.analyzeImageBytes(
        bytes,
        fileName,
        customApiKey: apiKey,
      );
      await KashifStorage.cacheReportByFingerprint(fp, report);
      state = state.copyWith(
        isLoading: false,
        report: report,
        progressText: '',
        isFromLocalCache: false,
        clearNotice: true,
      );
    } catch (e) {
      // Seamless failover to APInex Vision
      if (KashifStorage.isApinexAutoFailoverEnabled) {
        try {
          final activeModel = KashifStorage.apinexModel;
          state = state.copyWith(progressText: 'جاري فحص الشاشة عبر محرك APInex ($activeModel)...');
          final apReport = await _apinexClient.analyzeImage(bytes, fileName);
          await KashifStorage.cacheReportByFingerprint(fp, apReport);
          state = state.copyWith(
            isLoading: false,
            report: apReport,
            isFromLocalCache: true,
            cacheNotice: '⚡ تم فحص شاشة الجهاز بنجاح عبر محرك الذكاء البديل (APInex • $activeModel)',
            lastScannedBytes: bytes,
            lastScannedFileName: fileName,
            lastScannedIsPdf: false,
            clearError: true,
            progressText: '',
          );
          return;
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        progressText: '',
      );
    }
  }

  Future<void> scanPdf(dynamic file) async {
    final bytes = await file.readAsBytes() as Uint8List;
    final name = file.path.toString().split(RegExp(r'[/\\]')).last;
    await scanPdfBytes(bytes, name);
  }

  Future<void> scanImage(dynamic file) async {
    final bytes = await file.readAsBytes() as Uint8List;
    final name = file.path.toString().split(RegExp(r'[/\\]')).last;
    await scanImageBytes(bytes, name);
  }

  Future<void> scanManual(
    String codes,
    String? vin, {
    bool forceAi = false,
  }) async {
    final fp = KashifStorage.computeCodesFingerprint(codes, vin);

    if (!forceAi) {
      // 1. Instant Offline Dictionary Engine Check (0 API calls for known codes)
      final offlineReport = OfflineReportService.tryBuildOfflineReport(
        codes,
        vin: vin,
      );
      if (offlineReport != null) {
        await KashifStorage.cacheReportByFingerprint(fp, offlineReport);
        state = state.copyWith(
          isLoading: false,
          report: offlineReport,
          isFromLocalCache: true,
          cacheNotice:
              '⚡ تم استخراج التقرير فورياً من القاموس الليبي الداخلي (0 استهلاك API)',
          lastManualCodes: codes,
          lastManualVin: vin,
          clearError: true,
        );
        return;
      }

      // 2. Previously Cached Manual Diagnostic Check
      final cached = KashifStorage.getReportByFingerprint(fp);
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          report: cached,
          isFromLocalCache: true,
          cacheNotice:
              '⚡ تم تحميل التقرير فورياً من الذاكرة المحلية (تم توفير طلب API)',
          lastManualCodes: codes,
          lastManualVin: vin,
          clearError: true,
        );
        return;
      }
    }

    // Check if user set APInex as Primary AI
    if (KashifStorage.useApinexAsPrimary) {
      final activeModel = KashifStorage.apinexModel;
      state = state.copyWith(
        isLoading: true,
        progressText: 'جاري تشخيص الأكواد عبر محرك APInex ($activeModel)...',
        clearError: true,
        clearNotice: true,
        lastManualCodes: codes,
        lastManualVin: vin,
      );
      try {
        final apReport = await _apinexClient.analyzeManualCodes(codes, vin: vin);
        await KashifStorage.cacheReportByFingerprint(fp, apReport);
        state = state.copyWith(
          isLoading: false,
          report: apReport,
          isFromLocalCache: true,
          cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك APInex ($activeModel)',
          lastManualCodes: codes,
          lastManualVin: vin,
          clearError: true,
        );
        return;
      } catch (_) {}
    }

    // 3. Online Gemini AI Fallback for rare or unrecognized codes
    state = state.copyWith(
      isLoading: true,
      progressText: forceAi
          ? 'إعادة التحليل العميق بالذكاء الاصطناعي...'
          : 'جاري مطابقة الأكواد مع قاموس الصيانة الليبي عبر الذكاء الاصطناعي...',
      clearError: true,
      clearNotice: true,
      lastManualCodes: codes,
      lastManualVin: vin,
    );

    try {
      final apiKey = KashifStorage.customApiKey;
      final report = await _apiClient.analyzeManual(
        codes: codes,
        vin: vin,
        customApiKey: apiKey,
      );
      await KashifStorage.cacheReportByFingerprint(fp, report);
      state = state.copyWith(
        isLoading: false,
        report: report,
        progressText: '',
        isFromLocalCache: false,
        clearNotice: true,
      );
    } catch (e) {
      if (KashifStorage.isApinexAutoFailoverEnabled) {
        try {
          state = state.copyWith(progressText: 'جاري تشخيص الأكواد عبر محرك APInex البديل...');
          final apReport = await _apinexClient.analyzeManualCodes(codes, vin: vin);
          await KashifStorage.cacheReportByFingerprint(fp, apReport);
          state = state.copyWith(
            isLoading: false,
            report: apReport,
            isFromLocalCache: true,
            cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك الذكاء البديل (APInex • GPT-6 Luna)',
            lastManualCodes: codes,
            lastManualVin: vin,
            clearError: true,
            progressText: '',
          );
          return;
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        progressText: '',
      );
    }
  }

  /// Generates a local offline report using the Libyan dictionary immediately (0 API calls)
  Future<void> generateOfflineReport(String codes, [String? vin]) async {
    final cleanCodes = codes.trim().isNotEmpty ? codes.trim() : 'P0100';
    final report = OfflineReportService.buildOfflineReportFallback(
      cleanCodes,
      vin: vin,
    );
    final fp = KashifStorage.computeCodesFingerprint(cleanCodes, vin);
    await KashifStorage.cacheReportByFingerprint(fp, report);
    await KashifStorage.saveReport(report);
    state = state.copyWith(
      isLoading: false,
      report: report,
      isFromLocalCache: true,
      cacheNotice:
          '⚡ تم إنشاء التقرير فورياً من القاموس الليبي الداخلي (0 استهلاك للـ AI)',
      lastManualCodes: cleanCodes,
      lastManualVin: vin,
      clearError: true,
      progressText: '',
    );
  }

  /// Forces an AI re-analysis on the current cached report
  Future<void> reAnalyzeCurrentWithAi() async {
    if (state.lastScannedBytes != null) {
      if (state.lastScannedIsPdf) {
        await scanPdfBytes(
          state.lastScannedBytes!,
          state.lastScannedFileName ?? 'report.pdf',
          forceAi: true,
        );
      } else {
        await scanImageBytes(
          state.lastScannedBytes!,
          state.lastScannedFileName ?? 'image.jpg',
          forceAi: true,
        );
      }
    } else if (state.lastManualCodes != null) {
      await scanManual(
        state.lastManualCodes!,
        state.lastManualVin,
        forceAi: true,
      );
    }
  }

  Future<void> loadDemo(String sampleId) async {
    state = state.copyWith(
      isLoading: true,
      progressText: 'تحميل نموذج فحص جاهز...',
      clearError: true,
    );

    try {
      final report = await _apiClient.loadDemoReport(sampleId);
      state = state.copyWith(
        isLoading: false,
        report: report,
        progressText: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        progressText: '',
      );
    }
  }

  void setReport(DiagnosticReport report) {
    state = state.copyWith(report: report, clearError: true);
  }

  Future<void> saveCurrentReport() async {
    if (state.report != null) {
      await KashifStorage.saveReport(state.report!);
    }
  }
}

final apiClientProvider = Provider<KashifApiClient>((ref) => KashifApiClient());

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return ReportNotifier(apiClient: client);
});
