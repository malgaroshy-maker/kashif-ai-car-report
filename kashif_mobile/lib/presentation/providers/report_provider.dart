import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';

class ReportState {
  final DiagnosticReport? report;
  final bool isLoading;
  final String? errorMessage;
  final String progressText;

  ReportState({
    this.report,
    this.isLoading = false,
    this.errorMessage,
    this.progressText = '',
  });

  ReportState copyWith({
    DiagnosticReport? report,
    bool? isLoading,
    String? errorMessage,
    String? progressText,
    bool clearError = false,
  }) {
    return ReportState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      progressText: progressText ?? this.progressText,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final KashifApiClient _apiClient;

  ReportNotifier({KashifApiClient? apiClient})
      : _apiClient = apiClient ?? KashifApiClient(),
        super(ReportState());

  Future<void> scanPdf(File file) async {
    state = state.copyWith(
      isLoading: true,
      progressText: 'جاري رفع تقرير الفحص وقراءة النصوص...',
      clearError: true,
    );

    try {
      final apiKey = KashifStorage.customApiKey;
      final report = await _apiClient.analyzePdf(file, customApiKey: apiKey);
      await KashifStorage.saveReport(report);
      state = state.copyWith(isLoading: false, report: report, progressText: '');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        progressText: '',
      );
    }
  }

  Future<void> scanImage(File file) async {
    state = state.copyWith(
      isLoading: true,
      progressText: 'جاري مسح شاشة جهاز الفحص وتحليل الرموز بالذكاء الاصطناعي...',
      clearError: true,
    );

    try {
      final apiKey = KashifStorage.customApiKey;
      final report = await _apiClient.analyzeImage(file, customApiKey: apiKey);
      await KashifStorage.saveReport(report);
      state = state.copyWith(isLoading: false, report: report, progressText: '');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        progressText: '',
      );
    }
  }

  Future<void> scanManual(String codes, String? vin) async {
    state = state.copyWith(
      isLoading: true,
      progressText: 'جاري مطابقة الأكواد مع قاموس الصيانة الليبي...',
      clearError: true,
    );

    try {
      final apiKey = KashifStorage.customApiKey;
      final report = await _apiClient.analyzeManual(
        codes: codes,
        vin: vin,
        customApiKey: apiKey,
      );
      await KashifStorage.saveReport(report);
      state = state.copyWith(isLoading: false, report: report, progressText: '');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        progressText: '',
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
      state = state.copyWith(isLoading: false, report: report, progressText: '');
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

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReportNotifier(apiClient: client);
});
