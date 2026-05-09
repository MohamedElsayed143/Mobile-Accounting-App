import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _themeKey = 'isDarkMode';
  static const String _localeKey = 'languageCode';

  SettingsCubit() : super(SettingsState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    final languageCode = prefs.getString(_localeKey) ?? 'ar';

    emit(state.copyWith(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(languageCode, languageCode == 'ar' ? 'SA' : 'US'),
    ));
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    emit(state.copyWith(
      locale: Locale(languageCode, languageCode == 'ar' ? 'SA' : 'US'),
    ));
  }
}
