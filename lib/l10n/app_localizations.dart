import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales {
    return [
      const Locale('en', 'US'),
      const Locale('es', 'ES'),
      const Locale('ca', 'ES'),
      const Locale('gl', 'ES'),
      const Locale('eu', 'ES'),
      const Locale('pt', 'PT'),
      const Locale('fr', 'FR'),
      const Locale('it', 'IT'),
    ];
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Implement your localization logic here
  String get hello {
    // Example of a localized string
    return "Hello";
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Return an instance of AppLocalizations for the given locale
    return AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

