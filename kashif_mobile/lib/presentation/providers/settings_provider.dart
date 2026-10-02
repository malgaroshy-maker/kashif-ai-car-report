import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/hive_storage.dart';

class SettingsState {
  final List<String> customApiKeys;
  final String? customApiKey;
  final String workshopName;
  final String workshopPhone;
  final ThemeMode themeMode;
  final String apinexApiKey;
  final String apinexModel;
  final bool isApinexAutoFailoverEnabled;
  final bool useApinexAsPrimary;
  final bool isTokenSaverEnabled;

  SettingsState({
    List<String>? customApiKeys,
    this.customApiKey,
    this.workshopName = '',
    this.workshopPhone = '',
    this.themeMode = ThemeMode.system,
    String? apinexApiKey,
    String? apinexModel,
    bool? isApinexAutoFailoverEnabled,
    bool? useApinexAsPrimary,
    bool? isTokenSaverEnabled,
  })  : customApiKeys =
            customApiKeys ?? (customApiKey != null ? [customApiKey] : []),
        apinexApiKey = apinexApiKey ?? KashifStorage.apinexApiKey,
        apinexModel = apinexModel ?? KashifStorage.apinexModel,
        isApinexAutoFailoverEnabled =
            isApinexAutoFailoverEnabled ?? KashifStorage.isApinexAutoFailoverEnabled,
        useApinexAsPrimary =
            useApinexAsPrimary ?? KashifStorage.useApinexAsPrimary,
        isTokenSaverEnabled =
            isTokenSaverEnabled ?? KashifStorage.isTokenSaverEnabled;

  SettingsState copyWith({
    List<String>? customApiKeys,
    String? customApiKey,
    String? workshopName,
    String? workshopPhone,
    ThemeMode? themeMode,
    String? apinexApiKey,
    String? apinexModel,
    bool? isApinexAutoFailoverEnabled,
    bool? useApinexAsPrimary,
    bool? isTokenSaverEnabled,
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
      themeMode: themeMode ?? this.themeMode,
      apinexApiKey: apinexApiKey ?? this.apinexApiKey,
      apinexModel: apinexModel ?? this.apinexModel,
      isApinexAutoFailoverEnabled:
          isApinexAutoFailoverEnabled ?? this.isApinexAutoFailoverEnabled,
      useApinexAsPrimary: useApinexAsPrimary ?? this.useApinexAsPrimary,
      isTokenSaverEnabled: isTokenSaverEnabled ?? this.isTokenSaverEnabled,
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
          themeMode: _parseThemeMode(KashifStorage.themeMode),
          apinexApiKey: KashifStorage.apinexApiKey,
          apinexModel: KashifStorage.apinexModel,
          isApinexAutoFailoverEnabled: KashifStorage.isApinexAutoFailoverEnabled,
          useApinexAsPrimary: KashifStorage.useApinexAsPrimary,
          isTokenSaverEnabled: KashifStorage.isTokenSaverEnabled,
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

  Future<void> updateWorkshop(String name, String phone) async {
    await KashifStorage.setWorkshopName(name);
    await KashifStorage.setWorkshopPhone(phone);
    state = state.copyWith(workshopName: name, workshopPhone: phone);
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
