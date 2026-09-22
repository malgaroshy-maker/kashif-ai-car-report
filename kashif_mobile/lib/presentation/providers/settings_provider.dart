import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/hive_storage.dart';

class SettingsState {
  final String? customApiKey;
  final String workshopName;
  final String workshopPhone;
  final ThemeMode themeMode;

  SettingsState({
    this.customApiKey,
    this.workshopName = 'ورشة الفحص الفني',
    this.workshopPhone = '',
    this.themeMode = ThemeMode.system,
  });

  SettingsState copyWith({
    String? customApiKey,
    String? workshopName,
    String? workshopPhone,
    ThemeMode? themeMode,
    bool clearKey = false,
  }) {
    return SettingsState(
      customApiKey: clearKey ? null : (customApiKey ?? this.customApiKey),
      workshopName: workshopName ?? this.workshopName,
      workshopPhone: workshopPhone ?? this.workshopPhone,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(
          SettingsState(
            customApiKey: KashifStorage.customApiKey,
            workshopName: KashifStorage.workshopName,
            workshopPhone: KashifStorage.workshopPhone,
            themeMode: _parseThemeMode(KashifStorage.themeMode),
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
    state = state.copyWith(customApiKey: clean, clearKey: clean == null);
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
