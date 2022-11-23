import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'i18n_lookup.generated.dart';
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unnecessary_brace_in_string_interps

//WARNING: This file is automatically generated. DO NOT EDIT, all your changes would be lost.

typedef LocaleChangeCallback = void Function(Locale locale);

class I18n with I18nLookup implements WidgetsLocalizations {
  factory I18n() {
    return _instance;
  }

  I18n._internal();

  static final I18n _instance = I18n._internal();

  static Locale? _locale;
  static bool _shouldReload = false;

  static set locale(Locale? newLocale) {
    _shouldReload = true;
    I18n._locale = newLocale;
  }

  static const GeneratedLocalizationsDelegate delegate =
      GeneratedLocalizationsDelegate();

  /// function to be invoked when changing the language
  static late LocaleChangeCallback onLocaleChanged;

  static I18n of(BuildContext context) {
    late I18n instance;
    try {
      instance = Localizations.of<I18n>(context, WidgetsLocalizations) as I18n;
    } catch (e) {
      instance = _instance;
    }
    return instance;
  }

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class GeneratedLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const GeneratedLocalizationsDelegate();
  List<Locale> get supportedLocales {
    return const <Locale>[Locale('en', 'US')];
  }

  LocaleResolutionCallback resolution({Locale? fallback}) {
    return (Locale? locale, Iterable<Locale> supported) {
      if (isSupported(locale)) {
        return locale;
      }
      final Locale? fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    };
  }

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    I18n._locale ??= locale;
    I18n._shouldReload = false;
    final lang = I18n._locale?.toString() ?? 'en_US';
    final languageCode = I18n._locale?.languageCode ?? 'en';

    if ('en_US' == lang) {
      return SynchronousFuture<WidgetsLocalizations>(I18n());
    } else if ('en' == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(I18n());
    }

    return SynchronousFuture<WidgetsLocalizations>(I18n());
  }

  @override
  bool isSupported(Locale? locale) {
    for (var i = 0; i < supportedLocales.length && locale != null; i++) {
      final l = supportedLocales[i];
      if (l.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => I18n._shouldReload;
}
