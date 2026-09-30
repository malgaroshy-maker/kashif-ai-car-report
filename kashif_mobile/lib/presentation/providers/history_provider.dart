import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';

class HistoryNotifier extends StateNotifier<List<DiagnosticReport>> {
  HistoryNotifier() : super([]) {
    loadHistory();
  }

  void loadHistory() {
    state = KashifStorage.getSavedReports();
  }

  Future<void> saveReport(DiagnosticReport report) async {
    await KashifStorage.saveReport(report);
    loadHistory();
  }

  Future<void> deleteReport(String reportId) async {
    await KashifStorage.deleteReport(reportId);
    loadHistory();
  }

  Future<void> clearAll() async {
    await KashifStorage.clearAllReports();
    loadHistory();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<DiagnosticReport>>((ref) {
      return HistoryNotifier();
    });
