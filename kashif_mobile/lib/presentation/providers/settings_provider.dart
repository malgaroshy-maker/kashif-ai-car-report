import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/hive_storage.dart';
import '../../data/models/report_sections_config.dart';

class SettingsState {
  final List<String> customApiKeys;
  final String? customApiKey;
  final String workshopName;
  final String workshopPhone;
  final String workshopAddress;
  final String technicianName;
  final ThemeMode themeMode;
  final String apinexApiKey;
  final String apinexModel;
  final bool isApinexAutoFailoverEnabled;
  final bool useApinexAsPrimary;
  final bool isTokenSaverEnabled;
  final ReportSectionsConfig reportSectionsConfig;

  SettingsState({
    List<String>? customApiKeys,
    this.customApiKey,
    this.workshopName = '',
    this.workshopPhone = '',
    String? workshopAddress,
    String? technicianName,
    this.themeMode = ThemeMode.system,
    String? apinexApiKey,
    String? apinexModel,
    bool? isApinexAutoFailoverEnabled,
    bool? useApinexAsPrimary,
    bool? isTokenSaverEnabled,
    ReportSectionsConfig? reportSectionsConfig,
  })  : customApiKeys =
            customApiKeys ?? (customApiKey != null ? [customApiKey] : []),
        workshopAddress =
            workshopAddress ?? KashifStorage.workshopAddress,
        technicianName =
            technicianName ?? KashifStorage.technicianName,
        apinexApiKey = apinexApiKey ?? KashifStorage.apinexApiKey,
        apinexModel = apinexModel ?? KashifStorage.apinexModel,
        isApinexAutoFailoverEnabled =
            isApinexAutoFailoverEnabled ?? KashifStorage.isApinexAutoFailoverEnabled,
        useApinexAsPrimary =
            useApinexAsPrimary ?? KashifStorage.useApinexAsPrimary,
        isTokenSaverEnabled =
            isTokenSaverEnabled ?? KashifStorage.isTokenSaverEnabled,
        reportSectionsConfig =
            reportSectionsConfig ?? KashifStorage.reportSectionsConfig;

  SettingsState copyWith({
    List<String>? customApiKeys,
    String? customApiKey,
    String? workshopName,
    String? workshopPhone,
    String? workshopAddress,
    String? technicianName,
    ThemeMode? themeMode,
    String? apinexApiKey,
    String? apinexModel,
    bool? isApinexAutoFailoverEnabled,
    bool? useApinexAsPrimary,
    bool? isTokenSaverEnabled,
    ReportSectionsConfig? reportSectionsConfig,
    bool clearKey = false,
  }) {
    final newKeys = customApiKeys ?? this.customApiKeys;
    final primary = clearKey
        ? null
        : (customApiKey ??
              (newKeys.isNotEmpty ? newKeys.first : this.customApiKey));
    return SettingsState(
      customApiKeys: newKeys,
      customApiKey: primary,
      workshopName: workshopName ?? this.workshopName,
      workshopPhone: workshopPhone ?? this.workshopPhone,
      workshopAddress: workshopAddress ?? this.workshopAddress,
      technicianName: technicianName ?? this.technicianName,
      themeMode: themeMode ?? this.themeMode,
      apinexApiKey: apinexApiKey ?? this.apinexApiKey,
      apinexModel: apinexModel ?? this.apinexModel,
      isApinexAutoFailoverEnabled:
          isApinexAutoFailoverEnabled ?? this.isApinexAutoFailoverEnabled,
      useApinexAsPrimary: useApinexAsPrimary ?? this.useApinexAsPrimary,
      isTokenSaverEnabled: isTokenSaverEnabled ?? this.isTokenSaverEnabled,
      reportSectionsConfig: reportSectionsConfig ?? this.reportSectionsConfig,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(
        SettingsState(
          customApiKeys: KashifStorage.customApiKeys,
          customApiKey: KashifStorage.customApiKey,
          workshopName: KashifStorage.workshopName,
          workshopPhone: KashifStorage.workshopPhone,
          workshopAddress: KashifStorage.workshopAddress,
          technicianName: KashifStorage.technicianName,
          themeMode: _parseThemeMode(KashifStorage.themeMode),
          apinexApiKey: KashifStorage.apinexApiKey,
          apinexModel: KashifStorage.apinexModel,
          isApinexAutoFailoverEnabled: KashifStorage.isApinexAutoFailoverEnabled,
          useApinexAsPrimary: KashifStorage.useApinexAsPrimary,
          isTokenSaverEnabled: KashifStorage.isTokenSaverEnabled,
          reportSectionsConfig: KashifStorage.reportSectionsConfig,
        ),
      );

  static ThemeMode _parseThemeMode(String mode) {
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> updateApiKey(String? key) async {
    final clean = (key != null && key.trim().isNotEmpty) ? key.trim() : null;
    await KashifStorage.setCustomApiKey(clean);
    final keys = KashifStorage.customApiKeys;
    state = state.copyWith(
      customApiKeys: keys,
      customApiKey: clean,
      clearKey: clean == null,
    );
  }

  Future<void> addApiKey(String key) async {
    final clean = key.trim();
    if (clean.isEmpty) return;
    await KashifStorage.addCustomApiKey(clean);
    final keys = KashifStorage.customApiKeys;
    state = state.copyWith(
      customApiKeys: keys,
      customApiKey: keys.isNotEmpty ? keys.first : null,
    );
  }

  Future<void> removeApiKey(int index) async {
    await KashifStorage.removeCustomApiKey(index);
    final keys = KashifStorage.customApiKeys;
    state = state.copyWith(
      customApiKeys: keys,
      customApiKey: keys.isNotEmpty ? keys.first : null,
      clearKey: keys.isEmpty,
    );
  }

  Future<void> updateApiKeys(List<String> keys) async {
    await KashifStorage.setCustomApiKeys(keys);
    final saved = KashifStorage.customApiKeys;
    state = state.copyWith(
      customApiKeys: saved,
      customApiKey: saved.isNotEmpty ? saved.first : null,
      clearKey: saved.isEmpty,
    );
  }

  Future<void> updateWorkshop(
    String name,
    String phone, {
    String? address,
    String? technicianName,
  }) async {
    await KashifStorage.setWorkshopName(name);
    await KashifStorage.setWorkshopPhone(phone);
    if (address != null) await KashifStorage.setWorkshopAddress(address);
    if (technicianName != null) {
      await KashifStorage.setTechnicianName(technicianName);
    }
    state = state.copyWith(
      workshopName: name,
      workshopPhone: phone,
      workshopAddress: address,
      technicianName: technicianName,
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    String str = 'system';
    if (mode == ThemeMode.light) str = 'light';
    if (mode == ThemeMode.dark) str = 'dark';
    await KashifStorage.setThemeMode(str);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updateApinexSettings({
    String? key,
    String? model,
    bool? autoFailover,
    bool? asPrimary,
  }) async {
    if (key != null) await KashifStorage.setApinexApiKey(key);
    if (model != null) await KashifStorage.setApinexModel(model);
    if (autoFailover != null) await KashifStorage.setApinexAutoFailoverEnabled(autoFailover);
    if (asPrimary != null) await KashifStorage.setUseApinexAsPrimary(asPrimary);

    state = state.copyWith(
      apinexApiKey: key,
      apinexModel: model,
      isApinexAutoFailoverEnabled: autoFailover,
      useApinexAsPrimary: asPrimary,
    );
  }

  Future<void> setTokenSaverEnabled(bool enabled) async {
    await KashifStorage.setTokenSaverEnabled(enabled);
    state = state.copyWith(isTokenSaverEnabled: enabled);
  }

  Future<void> updateReportSectionsConfig(ReportSectionsConfig config) async {
    await KashifStorage.setReportSectionsConfig(config);
    state = state.copyWith(reportSectionsConfig: config);
  }

  Future<void> toggleReportSection(String key, bool enabled) async {
    final updated = state.reportSectionsConfig.toggleByKey(key, enabled);
    await KashifStorage.setReportSectionsConfig(updated);
    state = state.copyWith(reportSectionsConfig: updated);
  }

  Future<void> setAllReportSections(bool enabled) async {
    final updated = ReportSectionsConfig(
      includeTechnicalAssessment: enabled,
      includeFaultsTable: enabled,
      includePassedSystems: enabled,
      includeProbabilitiesTable: enabled,
      includeChecklist: enabled,
      includeSpareParts: enabled,
      includeTechnicianSignature: enabled,
    );
    await KashifStorage.setReportSectionsConfig(updated);
    state = state.copyWith(reportSectionsConfig: updated);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
