import 'package:hive_flutter/hive_flutter.dart';
import '../models/diagnostic_report.dart';

class KashifStorage {
  static const String reportsBoxName = 'kashif_reports';
  static const String settingsBoxName = 'kashif_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(reportsBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<Map> get reportsBox => Hive.box<Map>(reportsBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  // Save report to local storage
  static Future<void> saveReport(DiagnosticReport report) async {
    final map = report.toJson();
    await reportsBox.put(report.reportId, map);
  }

  // Get all saved reports
  static List<DiagnosticReport> getSavedReports() {
    final list = <DiagnosticReport>[];
    for (var key in reportsBox.keys) {
      final data = reportsBox.get(key);
      if (data != null) {
        try {
          final json = Map<String, dynamic>.from(data);
          list.add(DiagnosticReport.fromJson(json));
        } catch (e) {
          // ignore corrupted entry
        }
      }
    }
    // Sort descending by date
    list.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return list;
  }

  // Delete a report
  static Future<void> deleteReport(String reportId) async {
    await reportsBox.delete(reportId);
  }

  // Settings getters & setters
  static String? get customApiKey => settingsBox.get('customApiKey') as String?;
  static Future<void> setCustomApiKey(String? key) async => await settingsBox.put('customApiKey', key);

  static String get workshopName => settingsBox.get('workshopName', defaultValue: 'ورشة الفحص الفني') as String;
  static Future<void> setWorkshopName(String name) async => await settingsBox.put('workshopName', name);

  static String get workshopPhone => settingsBox.get('workshopPhone', defaultValue: '') as String;
  static Future<void> setWorkshopPhone(String phone) async => await settingsBox.put('workshopPhone', phone);

  static String get themeMode => settingsBox.get('themeMode', defaultValue: 'system') as String;
  static Future<void> setThemeMode(String mode) async => await settingsBox.put('themeMode', mode);
}
