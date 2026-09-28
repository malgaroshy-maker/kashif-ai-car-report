import 'dart:typed_data';
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

  /// Computes a deterministic 32-bit FNV-1a fingerprint for byte buffers (safe for Web/JS & Native)
  static String computeFingerprint(Uint8List bytes) {
    int hash = 0x811c9dc5;
    final len = bytes.length;
    final step = len > 65536 ? (len ~/ 4096) : 1;
    for (int i = 0; i < len; i += step) {
      hash ^= bytes[i];
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return '${len}_${hash.toRadixString(16)}';
  }

  /// Computes a normalized fingerprint for manual codes
  static String computeCodesFingerprint(String codes, [String? vin]) {
    final cleanCodes =
        codes
            .toUpperCase()
            .replaceAll(RegExp(r'[^A-Z0-9]'), ' ')
            .split(RegExp(r'\s+'))
            .where((s) => s.isNotEmpty)
            .toList()
          ..sort();
    final cleanVin = (vin ?? '').trim().toUpperCase();
    return 'codes_${cleanCodes.join("-")}_vin_$cleanVin';
  }

  /// Saves a report associated with a file/codes fingerprint
  static Future<void> cacheReportByFingerprint(
    String fp,
    DiagnosticReport report,
  ) async {
    try {
      await saveReport(report);
      await settingsBox.put('fp_$fp', report.reportId);
    } catch (_) {}
  }

  /// Retrieves a cached report by its fingerprint, or null if none
  static DiagnosticReport? getReportByFingerprint(String fp) {
    try {
      final reportId = settingsBox.get('fp_$fp') as String?;
      if (reportId == null) return null;
      final raw = reportsBox.get(reportId);
      if (raw == null) return null;
      final json = Map<String, dynamic>.from(raw);
      return DiagnosticReport.fromJson(json);
    } catch (_) {
      return null;
    }
  }

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
  static List<String> get customApiKeys {
    final raw = settingsBox.get('customApiKeys');
    if (raw is List && raw.isNotEmpty) {
      final list = raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return list;
    }
    final single = settingsBox.get('customApiKey');
    if (single != null && single.toString().trim().isNotEmpty) {
      return [single.toString().trim()];
    }
    return [];
  }

  static Future<void> setCustomApiKeys(List<String> keys) async {
    final clean = keys
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    await settingsBox.put('customApiKeys', clean);
    if (clean.isNotEmpty) {
      await settingsBox.put('customApiKey', clean.first);
    } else {
      await settingsBox.delete('customApiKey');
    }
  }

  static Future<void> addCustomApiKey(String key) async {
    final clean = key.trim();
    if (clean.isEmpty) return;
    final keys = List<String>.from(customApiKeys);
    if (!keys.contains(clean)) {
      keys.add(clean);
      await setCustomApiKeys(keys);
    }
  }

  static Future<void> removeCustomApiKey(int index) async {
    final keys = List<String>.from(customApiKeys);
    if (index >= 0 && index < keys.length) {
      keys.removeAt(index);
      await setCustomApiKeys(keys);
    }
  }

  static String? get customApiKey {
    final single = settingsBox.get('customApiKey');
    if (single != null && single.toString().trim().isNotEmpty) {
      return single.toString().trim();
    }
    final raw = settingsBox.get('customApiKeys');
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first.toString().trim();
      if (first.isNotEmpty) return first;
    }
    return null;
  }

  static Future<void> setCustomApiKey(String? key) async {
    final clean = (key != null && key.trim().isNotEmpty) ? key.trim() : null;
    if (clean != null) {
      await settingsBox.put('customApiKey', clean);
      final keys = List<String>.from(customApiKeys);
      if (!keys.contains(clean)) {
        keys.insert(0, clean);
        await setCustomApiKeys(keys);
      }
    } else {
      await settingsBox.delete('customApiKey');
      await settingsBox.delete('customApiKeys');
    }
  }

  static String get workshopName {
    try {
      final val = settingsBox.get('workshopName', defaultValue: '') as String;
      return val == 'ورشة الفحص الفني' ? '' : val;
    } catch (_) {
      return '';
    }
  }

  static Future<void> setWorkshopName(String name) async =>
      await settingsBox.put('workshopName', name);

  static String get workshopPhone {
    try {
      return settingsBox.get('workshopPhone', defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  static Future<void> setWorkshopPhone(String phone) async =>
      await settingsBox.put('workshopPhone', phone);

  static String get themeMode =>
      settingsBox.get('themeMode', defaultValue: 'system') as String;
  static Future<void> setThemeMode(String mode) async =>
      await settingsBox.put('themeMode', mode);
}
