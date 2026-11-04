import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The languages of the app (docs/ARCHITECTURE.md §11). Turkish is the source language.
enum AppLanguage {
  tr('Türkçe'),
  en('English'),
  de('Deutsch'),
  fr('Français'),
  nl('Nederlands'),
  es('Español'),
  pt('Português'),
  it('Italiano'),
  ru('Русский'),
  ar('العربية'),
  az('Azərbaycan dili'),
  uk('Українська');

  const AppLanguage(this.nativeName);

  /// The language's own name, shown in the language list whatever the current language is.
  final String nativeName;

  String get code => name;

  Locale get locale => Locale(name);

  bool get isRtl => this == ar;

  static AppLanguage? parse(String? code) {
    if (code == null) return null;
    final lang = code.split(RegExp('[-_]')).first.toLowerCase();
    return values.where((l) => l.name == lang).firstOrNull;
  }

  static List<Locale> get locales => [for (final l in values) l.locale];

  /// The first device language we support, otherwise English.
  static AppLanguage fromDevice(List<Locale> deviceLocales) {
    for (final l in deviceLocales) {
      if (parse(l.languageCode) case final lang?) return lang;
    }
    return en;
  }
}

AppLanguage _current = AppLanguage.tr;

/// The language in use, for code without a `BuildContext` (failure messages, enum labels, notification text).
/// Kept in step with [appLanguageProvider]; widgets rebuild when it changes because the app's locale changes.
AppLanguage get currentAppLanguage => _current;

Locale get currentAppLocale => _current.locale;

/// Sets [currentAppLanguage]; used by [appLanguageProvider] and by tests.
void setCurrentAppLanguage(AppLanguage language) {
  _current = language;
  Intl.defaultLocale = language.code;
}

/// Device storage for the chosen language; each app overrides it in `main` after
/// `SharedPreferences.getInstance()`. Without it the choice lasts until the app closes.
final languagePreferencesProvider = Provider<SharedPreferences?>((_) => null);

const _prefsKey = 'gway.language';

/// Opens the device storage for [languagePreferencesProvider].
Future<SharedPreferences> openLanguagePreferences() => SharedPreferences.getInstance();

/// The device's preferred languages; tests override it.
final deviceLocalesProvider = Provider<List<Locale>>((_) => PlatformDispatcher.instance.locales);

/// The chosen language: saved choice, else the device language, else English.
final appLanguageProvider = NotifierProvider<AppLanguageController, AppLanguage>(AppLanguageController.new);

class AppLanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final saved = AppLanguage.parse(ref.watch(languagePreferencesProvider)?.getString(_prefsKey));
    final language = saved ?? AppLanguage.fromDevice(ref.watch(deviceLocalesProvider));
    setCurrentAppLanguage(language);
    return language;
  }

  Future<void> choose(AppLanguage language) async {
    setCurrentAppLanguage(language);
    state = language;
    await ref.read(languagePreferencesProvider)?.setString(_prefsKey, language.code);
  }
}
