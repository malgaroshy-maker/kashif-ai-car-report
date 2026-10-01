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
  final bool canFallbackToOffline;

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
    this.canFallbackToOffline = false,
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
    bool? canFallbackToOffline,
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
      canFallbackToOffline: canFallbackToOffline ?? this.canFallbackToOffline,
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
    if (state.errorMessage != null || state.canFallbackToOffline) {
      state = state.copyWith(clearError: true, canFallbackToOffline: false);
    }
  }

  void dismissOfflineFallback() {
    state = state.copyWith(canFallbackToOffline: false);
  }

  String _formatFriendlyError(dynamic e) {
    final str = e.toString();
    if (str.contains('429') || str.contains('Resource Exhausted') || str.contains('QUOTA')) {
      return 'تم استنفاد كوتة الذكاء الاصطناعي (Quota Exceeded 429). يمكنك التحويل التلقائي أو استخراج التقرير بالقاموس المحلي.';
    }
    if (str.contains('402') || str.contains('Daily check-in') || str.contains('check-in')) {
      return 'النماذج في APInex مجانية 100% ولا تتطلب أي دفع أو شحن رصيد؛ كل ما تحتاجه هو تسجيل حضور يومي مجاني بنقرة واحدة على: https://apinex.bond/airdrop?tab=quests لتفعيل الكوتة اليومية.';
    }
    if (str.contains('401')) {
      return 'مفتاح الـ API غير صالح أو ملغي. يرجى مراجعة إعدادات المفاتيح.';
    }
    if (str.contains('SocketException') || str.contains('Failed host lookup') || str.contains('Timeout')) {
      return 'تعذر الاتصال بخادم الذكاء الاصطناعي (تحقق من اتصال الإنترنت).';
    }
    return 'تعذر إتمام الفحص عبر الذكاء الاصطناعي: $str';
  }

  /// Scan PDF with strict AI prioritization
  Future<void> scanPdfBytes(
    Uint8List bytes,
    String fileName, {
    bool forceAi = false,
  }) async {
    final fp = KashifStorage.computeFingerprint(bytes);

    // 1. If not forcing AI and already cached from previous run, return cached
    if (!forceAi) {
      final cached = KashifStorage.getReportByFingerprint(fp);
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          report: cached,
          isFromLocalCache: true,
          cacheNotice: '⚡ تم تحميل التقرير فورياً من الذاكرة المحلية (تم توفير طلب API)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: true,
          clearError: true,
          canFallbackToOffline: false,
        );
        return;
      }
    }

    // 2. Primary Engine Execution (Always prioritize AI first)
    if (KashifStorage.useApinexAsPrimary) {
      final activeModel = KashifStorage.apinexModel;
      state = state.copyWith(
        isLoading: true,
        progressText: 'جاري تشخيص ملف الـ PDF عبر محرك APInex ($activeModel)...',
        clearError: true,
        clearNotice: true,
        canFallbackToOffline: false,
        lastScannedBytes: bytes,
        lastScannedFileName: fileName,
        lastScannedIsPdf: true,
      );

      try {
        final rawText = EdiagPdfParser.extractRawTextFromPdf(bytes);
        final apReport = await _apinexClient.analyzeTextReport(rawText);
        await KashifStorage.cacheReportByFingerprint(fp, apReport);
        await KashifStorage.saveReport(apReport);
        state = state.copyWith(
          isLoading: false,
          report: apReport,
          isFromLocalCache: false,
          cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك APInex ($activeModel)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: true,
          clearError: true,
          canFallbackToOffline: false,
        );
        return;
      } catch (apError) {
        // Failover to Gemini if configured
        if (KashifStorage.customApiKey?.isNotEmpty == true) {
          try {
            state = state.copyWith(progressText: 'تحويل إلى محرك Gemini...');
            final report = await _apiClient.analyzePdfBytes(
              bytes,
              fileName,
              customApiKey: KashifStorage.customApiKey,
            );
            await KashifStorage.cacheReportByFingerprint(fp, report);
            await KashifStorage.saveReport(report);
            state = state.copyWith(
              isLoading: false,
              report: report,
              isFromLocalCache: false,
              clearNotice: true,
              lastScannedBytes: bytes,
              lastScannedFileName: fileName,
              lastScannedIsPdf: true,
              clearError: true,
              canFallbackToOffline: false,
            );
            return;
          } catch (_) {}
        }

        // Both AI engines failed -> ask user instead of silent bypass
        state = state.copyWith(
          isLoading: false,
          errorMessage: _formatFriendlyError(apError),
          canFallbackToOffline: true,
          progressText: '',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: true,
        );
        return;
      }
    }

    // Default: Gemini as Primary
    state = state.copyWith(
      isLoading: true,
      progressText: forceAi
          ? 'إعادة الفحص والتحليل العميق بالذكاء الاصطناعي...'
          : 'جاري رفع تقرير الفحص وقراءة النصوص عبر Gemini...',
      clearError: true,
      clearNotice: true,
      canFallbackToOffline: false,
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
      await KashifStorage.saveReport(report);
      state = state.copyWith(
        isLoading: false,
        report: report,
        progressText: '',
        isFromLocalCache: false,
        clearNotice: true,
        clearError: true,
        canFallbackToOffline: false,
      );
    } catch (geminiError) {
      // Automatic failover to APInex if enabled
      if (KashifStorage.isApinexAutoFailoverEnabled) {
        try {
          final activeModel = KashifStorage.apinexModel;
          state = state.copyWith(
            progressText: 'جاري التحويل التلقائي إلى محرك APInex ($activeModel)...',
          );
          final rawText = EdiagPdfParser.extractRawTextFromPdf(bytes);
          final apReport = await _apinexClient.analyzeTextReport(rawText);
          await KashifStorage.cacheReportByFingerprint(fp, apReport);
          await KashifStorage.saveReport(apReport);
          state = state.copyWith(
            isLoading: false,
            report: apReport,
            isFromLocalCache: false,
            cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك الذكاء البديل (APInex • $activeModel)',
            lastScannedBytes: bytes,
            lastScannedFileName: fileName,
            lastScannedIsPdf: true,
            clearError: true,
            canFallbackToOffline: false,
            progressText: '',
          );
          return;
        } catch (_) {}
      }

      // Both AI attempts failed -> notify user and offer fallback
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatFriendlyError(geminiError),
        canFallbackToOffline: true,
        progressText: '',
        lastScannedBytes: bytes,
        lastScannedFileName: fileName,
        lastScannedIsPdf: true,
      );
    }
  }

  /// Scan Camera/Gallery Image with strict AI prioritization
  Future<void> scanImageBytes(
    Uint8List bytes,
    String fileName, {
    bool forceAi = false,
  }) async {
    final fp = KashifStorage.computeFingerprint(bytes);

    if (!forceAi) {
      final cached = KashifStorage.getReportByFingerprint(fp);
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          report: cached,
          isFromLocalCache: true,
          cacheNotice: '⚡ تم تحميل التقرير فورياً من الذاكرة المحلية (تم توفير طلب API)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: false,
          clearError: true,
          canFallbackToOffline: false,
        );
        return;
      }
    }

    // APInex as Primary
    if (KashifStorage.useApinexAsPrimary) {
      final activeModel = KashifStorage.apinexModel;
      state = state.copyWith(
        isLoading: true,
        progressText: 'جاري فحص شاشة جهاز الفحص عبر APInex ($activeModel)...',
        clearError: true,
        clearNotice: true,
        canFallbackToOffline: false,
        lastScannedBytes: bytes,
        lastScannedFileName: fileName,
        lastScannedIsPdf: false,
      );

      try {
        final apReport = await _apinexClient.analyzeImage(bytes, fileName);
        await KashifStorage.cacheReportByFingerprint(fp, apReport);
        await KashifStorage.saveReport(apReport);
        state = state.copyWith(
          isLoading: false,
          report: apReport,
          isFromLocalCache: false,
          cacheNotice: '⚡ تم فحص الشاشة بنجاح عبر محرك APInex ($activeModel)',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: false,
          clearError: true,
          canFallbackToOffline: false,
        );
        return;
      } catch (apError) {
        // Try Gemini fallback if configured
        if (KashifStorage.customApiKey?.isNotEmpty == true) {
          try {
            state = state.copyWith(progressText: 'تحويل إلى محرك Gemini Vision...');
            final report = await _apiClient.analyzeImageBytes(
              bytes,
              fileName,
              customApiKey: KashifStorage.customApiKey,
            );
            await KashifStorage.cacheReportByFingerprint(fp, report);
            await KashifStorage.saveReport(report);
            state = state.copyWith(
              isLoading: false,
              report: report,
              progressText: '',
              isFromLocalCache: false,
              clearNotice: true,
              clearError: true,
              canFallbackToOffline: false,
            );
            return;
          } catch (_) {}
        }

        state = state.copyWith(
          isLoading: false,
          errorMessage: _formatFriendlyError(apError),
          canFallbackToOffline: true,
          progressText: '',
          lastScannedBytes: bytes,
          lastScannedFileName: fileName,
          lastScannedIsPdf: false,
        );
        return;
      }
    }

    // Gemini as Primary
    state = state.copyWith(
      isLoading: true,
      progressText: forceAi
          ? 'إعادة المسح والتحليل العميق بالذكاء الاصطناعي...'
          : 'جاري مسح شاشة جهاز الفحص وتحليل الرموز بالذكاء الاصطناعي...',
      clearError: true,
      clearNotice: true,
      canFallbackToOffline: false,
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
      await KashifStorage.saveReport(report);
      state = state.copyWith(
        isLoading: false,
        report: report,
        progressText: '',
        isFromLocalCache: false,
        clearNotice: true,
        clearError: true,
        canFallbackToOffline: false,
      );
    } catch (geminiError) {
      if (KashifStorage.isApinexAutoFailoverEnabled) {
        try {
          final activeModel = KashifStorage.apinexModel;
          state = state.copyWith(
            progressText: 'جاري فحص الشاشة عبر محرك APInex ($activeModel)...',
          );
          final apReport = await _apinexClient.analyzeImage(bytes, fileName);
          await KashifStorage.cacheReportByFingerprint(fp, apReport);
          await KashifStorage.saveReport(apReport);
          state = state.copyWith(
            isLoading: false,
            report: apReport,
            isFromLocalCache: false,
            cacheNotice: '⚡ تم فحص الشاشة بنجاح عبر محرك الذكاء البديل (APInex • $activeModel)',
            lastScannedBytes: bytes,
            lastScannedFileName: fileName,
            lastScannedIsPdf: false,
            clearError: true,
            canFallbackToOffline: false,
            progressText: '',
          );
          return;
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatFriendlyError(geminiError),
        canFallbackToOffline: true,
        progressText: '',
        lastScannedBytes: bytes,
        lastScannedFileName: fileName,
        lastScannedIsPdf: false,
      );
    }
  }

  /// Scan Manual Codes with strict AI prioritization
  Future<void> scanManual(
    String codes,
    String? vin, {
    bool forceAi = false,
  }) async {
    final fp = KashifStorage.computeCodesFingerprint(codes, vin);

    if (!forceAi) {
      final cached = KashifStorage.getReportByFingerprint(fp);
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          report: cached,
          isFromLocalCache: true,
          cacheNotice: '⚡ تم تحميل التقرير فورياً من الذاكرة المحلية (تم توفير طلب API)',
          lastManualCodes: codes,
          lastManualVin: vin,
          clearError: true,
          canFallbackToOffline: false,
        );
        return;
      }
    }

    // 1. APInex as Primary
    if (KashifStorage.useApinexAsPrimary) {
      final activeModel = KashifStorage.apinexModel;
      state = state.copyWith(
        isLoading: true,
        progressText: 'جاري تشخيص الأكواد عبر محرك APInex ($activeModel)...',
        clearError: true,
        clearNotice: true,
        canFallbackToOffline: false,
        lastManualCodes: codes,
        lastManualVin: vin,
      );

      try {
        final apReport = await _apinexClient.analyzeManualCodes(codes, vin: vin);
        await KashifStorage.cacheReportByFingerprint(fp, apReport);
        await KashifStorage.saveReport(apReport);
        state = state.copyWith(
          isLoading: false,
          report: apReport,
          isFromLocalCache: false,
          cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك APInex ($activeModel)',
          lastManualCodes: codes,
          lastManualVin: vin,
          clearError: true,
          canFallbackToOffline: false,
        );
        return;
      } catch (apError) {
        if (KashifStorage.customApiKey?.isNotEmpty == true) {
          try {
            state = state.copyWith(progressText: 'تحويل إلى محرك Gemini...');
            final report = await _apiClient.analyzeManual(
              codes: codes,
              vin: vin,
              customApiKey: KashifStorage.customApiKey,
            );
            await KashifStorage.cacheReportByFingerprint(fp, report);
            await KashifStorage.saveReport(report);
            state = state.copyWith(
              isLoading: false,
              report: report,
              isFromLocalCache: false,
              lastManualCodes: codes,
              lastManualVin: vin,
              clearError: true,
              canFallbackToOffline: false,
            );
            return;
          } catch (_) {}
        }

        state = state.copyWith(
          isLoading: false,
          errorMessage: _formatFriendlyError(apError),
          canFallbackToOffline: true,
          progressText: '',
          lastManualCodes: codes,
          lastManualVin: vin,
        );
        return;
      }
    }

    // 2. Gemini as Primary
    state = state.copyWith(
      isLoading: true,
      progressText: forceAi
          ? 'إعادة الفحص والتحليل العميق بالذكاء الاصطناعي...'
          : 'جاري تشخيص الأكواد ومطابقتها عبر الذكاء الاصطناعي...',
      clearError: true,
      clearNotice: true,
      canFallbackToOffline: false,
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
      await KashifStorage.saveReport(report);
      state = state.copyWith(
        isLoading: false,
        report: report,
        progressText: '',
        isFromLocalCache: false,
        clearNotice: true,
        clearError: true,
        canFallbackToOffline: false,
      );
    } catch (geminiError) {
      if (KashifStorage.isApinexAutoFailoverEnabled) {
        try {
          final activeModel = KashifStorage.apinexModel;
          state = state.copyWith(
            progressText: 'جاري تشخيص الأكواد عبر محرك APInex ($activeModel)...',
          );
          final apReport = await _apinexClient.analyzeManualCodes(codes, vin: vin);
          await KashifStorage.cacheReportByFingerprint(fp, apReport);
          await KashifStorage.saveReport(apReport);
          state = state.copyWith(
            isLoading: false,
            report: apReport,
            isFromLocalCache: false,
            cacheNotice: '⚡ تم التشخيص بنجاح عبر محرك الذكاء البديل (APInex • $activeModel)',
            lastManualCodes: codes,
            lastManualVin: vin,
            clearError: true,
            canFallbackToOffline: false,
            progressText: '',
          );
          return;
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatFriendlyError(geminiError),
        canFallbackToOffline: true,
        progressText: '',
        lastManualCodes: codes,
        lastManualVin: vin,
      );
    }
  }

  /// User explicitly chose to extract the report instantly using the offline local dictionary
  Future<void> generateOfflineReportForPending() async {
    DiagnosticReport? offlineReport;

    // Check if pending input was a PDF
    if (state.lastScannedBytes != null && state.lastScannedIsPdf) {
      try {
        final extracted = EdiagPdfParser.extractFromPdfBytes(state.lastScannedBytes!);
        if (extracted.isValid && (extracted.hasFaults || extracted.hasPassedSystems || extracted.vin != null)) {
          offlineReport = OfflineReportService.buildOfflineReportFromEdiag(extracted);
        }
      } catch (_) {}
    }

    // Check if pending input was manual DTC codes
    if (offlineReport == null && state.lastManualCodes != null && state.lastManualCodes!.isNotEmpty) {
      offlineReport = OfflineReportService.tryBuildOfflineReport(
        state.lastManualCodes!,
        vin: state.lastManualVin,
      );
      offlineReport ??= OfflineReportService.buildOfflineReportFallback(
        state.lastManualCodes!,
        vin: state.lastManualVin,
      );
    }

    // If still null, generate a fallback report
    offlineReport ??= OfflineReportService.buildOfflineReportFallback(
      state.lastManualCodes ?? 'P0100',
      vin: state.lastManualVin,
    );

    await KashifStorage.saveReport(offlineReport);
    state = state.copyWith(
      isLoading: false,
      report: offlineReport,
      isFromLocalCache: true,
      canFallbackToOffline: false,
      cacheNotice: '⚡ تم استخراج التقرير فورياً عبر القاموس الليبي المدمج (0 إنترنت)',
      clearError: true,
      progressText: '',
    );
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
      canFallbackToOffline: false,
      cacheNotice: '⚡ تم إنشاء التقرير فورياً من القاموس الليبي الداخلي (0 استهلاك للـ AI)',
      lastManualCodes: cleanCodes,
      lastManualVin: vin,
      clearError: true,
      progressText: '',
    );
  }

  /// Forces an AI re-analysis on the current pending or cached scan
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
      canFallbackToOffline: false,
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
