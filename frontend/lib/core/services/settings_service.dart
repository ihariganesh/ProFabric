import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service that persists and exposes app settings.
/// Uses [SharedPreferences] for persistence and [ValueNotifier] for reactive UI.
class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _keyDarkMode = 'setting_dark_mode';
  static const _keyNotifications = 'setting_notifications';
  static const _keyLanguage = 'setting_language';

  late SharedPreferences _prefs;
  bool _initialized = false;

  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
  final notificationsNotifier = ValueNotifier<bool>(true);
  final languageNotifier = ValueNotifier<String>('English');

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    final isDark = _prefs.getBool(_keyDarkMode) ?? true;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    notificationsNotifier.value = _prefs.getBool(_keyNotifications) ?? true;
    languageNotifier.value = _prefs.getString(_keyLanguage) ?? 'English';
  }

  bool get isDarkMode => themeNotifier.value == ThemeMode.dark;
  bool get notificationsEnabled => notificationsNotifier.value;
  String get language => languageNotifier.value;

  Future<void> setDarkMode(bool value) async {
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool(_keyDarkMode, value);
  }

  Future<void> setNotifications(bool value) async {
    notificationsNotifier.value = value;
    await _prefs.setBool(_keyNotifications, value);
  }

  Future<void> setLanguage(String value) async {
    languageNotifier.value = value;
    await _prefs.setString(_keyLanguage, value);
  }
}
