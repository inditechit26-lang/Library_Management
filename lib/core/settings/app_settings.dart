import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('English', 'en'),
  hindi('हिंदी', 'hi'),
  marathi('मराठी', 'mr');

  const AppLanguage(this.label, this.code);
  final String label;
  final String code;
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.language = AppLanguage.english,
  });

  final ThemeMode themeMode;
  final AppLanguage language;

  AppSettings copyWith({ThemeMode? themeMode, AppLanguage? language}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
      );
}

class AppSettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'app_language';

  @override
  AppSettings build() {
    Future.microtask(_restore);
    return const AppSettings();
  }

  Future<void> _restore() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languageKey);
    state = AppSettings(
      themeMode: preferences.getBool(_themeKey) == true
          ? ThemeMode.dark
          : ThemeMode.light,
      language: AppLanguage.values.firstWhere(
        (language) => language.code == languageCode,
        orElse: () => AppLanguage.english,
      ),
    );
  }

  Future<void> setDarkMode(bool enabled) async {
    state = state.copyWith(
      themeMode: enabled ? ThemeMode.dark : ThemeMode.light,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, enabled);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, language.code);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

final _translations = <String, Map<AppLanguage, String>>{
  'Dashboard': {AppLanguage.hindi: 'डैशबोर्ड', AppLanguage.marathi: 'डॅशबोर्ड'},
  'Students': {AppLanguage.hindi: 'छात्र', AppLanguage.marathi: 'विद्यार्थी'},
  'Seats': {AppLanguage.hindi: 'सीटें', AppLanguage.marathi: 'आसने'},
  'Fees': {AppLanguage.hindi: 'शुल्क', AppLanguage.marathi: 'शुल्क'},
  'Settings': {AppLanguage.hindi: 'सेटिंग्स', AppLanguage.marathi: 'सेटिंग्ज'},
  'Appearance & language': {
    AppLanguage.hindi: 'रूप और भाषा',
    AppLanguage.marathi: 'स्वरूप आणि भाषा',
  },
  'Language': {AppLanguage.hindi: 'भाषा', AppLanguage.marathi: 'भाषा'},
  'Choose the language used throughout the app.': {
    AppLanguage.hindi: 'पूरे ऐप में इस्तेमाल होने वाली भाषा चुनें।',
    AppLanguage.marathi: 'संपूर्ण अॅपमध्ये वापरली जाणारी भाषा निवडा.',
  },
  'Dark mode': {
    AppLanguage.hindi: 'डार्क मोड',
    AppLanguage.marathi: 'डार्क मोड',
  },
  'Use a darker color theme.': {
    AppLanguage.hindi: 'गहरे रंग की थीम का उपयोग करें।',
    AppLanguage.marathi: 'गडद रंगसंगती वापरा.',
  },
};

String translate(String text, AppLanguage language) =>
    _translations[text]?[language] ?? text;
