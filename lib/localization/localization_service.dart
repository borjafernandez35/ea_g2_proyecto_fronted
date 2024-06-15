import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService extends Translations {
  final box = GetStorage();

  static final Map<String, Locale> locales = {
    'en': Locale('en', 'US'),
    'es': Locale('es', 'ES'),
    'ca': Locale('ca', 'ES'),
    'gl': Locale('gl', 'ES'),
    'eu': Locale('eu', 'ES'),
    'pt': Locale('pt', 'PT'),
    'fr': Locale('fr', 'FR'),
    'it': Locale('it', 'IT'),
  };

  Locale getCurrentLocale() {
    String? langCode = box.read('lang');
    if (langCode != null) {
      return locales[langCode]!;
    }
    return Locale('en', 'US');
  }

  void changeLocale(String langCode) {
    Locale locale = locales[langCode]!;
    Get.updateLocale(locale);
    box.write('lang', langCode);
  }

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'enableDyslexicFont': 'Enable Dyslexic-Friendly Font',
      'selectTheme': 'Select Theme',
      'apply': 'Apply',
      'selectLanguage': 'Select Language',
      'light': 'Light',
      'dark': 'Dark',
      'colorblindAccessible': 'Colorblind Accessible',
    },
    'es_ES': {
      'settings': 'Configuración',
      'theme': 'Tema',
      'language': 'Idioma',
      'enableDyslexicFont': 'Habilitar fuente amigable para dislexia',
      'selectTheme': 'Seleccionar tema',
      'apply': 'Aplicar',
      'selectLanguage': 'Seleccionar idioma',
      'light': 'Claro',
      'dark': 'Oscuro',
      'colorblindAccessible': 'Accesible para daltónicos',
    },
    'ca_ES': {
      'settings': 'Configuració',
      'theme': 'Tema',
      'language': 'Idioma',
      'enableDyslexicFont': 'Habilitar font amigable per a dislèxia',
      'selectTheme': 'Seleccionar tema',
      'apply': 'Aplicar',
      'selectLanguage': 'Seleccionar idioma',
      'light': 'Clar',
      'dark': 'Fosc',
      'colorblindAccessible': 'Accessible per a daltònics',
    },
    'gl_ES': {
      'settings': 'Configuración',
      'theme': 'Tema',
      'language': 'Idioma',
      'enableDyslexicFont': 'Habilitar fonte amigable para dislexia',
      'selectTheme': 'Seleccionar tema',
      'apply': 'Aplicar',
      'selectLanguage': 'Seleccionar idioma',
      'light': 'Claro',
      'dark': 'Escuro',
      'colorblindAccessible': 'Accesible para daltónicos',
    },
    'eu_ES': {
      'settings': 'Ezarpenak',
      'theme': 'Gaia',
      'language': 'Hizkuntza',
      'enableDyslexicFont': 'Dizlexia errespetatzen duen letra-mota gaitu',
      'selectTheme': 'Gaia aukeratu',
      'apply': 'Aplikatu',
      'selectLanguage': 'Hizkuntza aukeratu',
      'light': 'Argia',
      'dark': 'Iluna',
      'colorblindAccessible': 'Daltonismoarentzat egokia',
    },
    'pt_PT': {
      'settings': 'Configurações',
      'theme': 'Tema',
      'language': 'Idioma',
      'enableDyslexicFont': 'Habilitar fonte amigável para dislexia',
      'selectTheme': 'Selecionar tema',
      'apply': 'Aplicar',
      'selectLanguage': 'Selecionar idioma',
      'light': 'Claro',
      'dark': 'Escuro',
      'colorblindAccessible': 'Acessível para daltônicos',
    },
    'fr_FR': {
      'settings': 'Paramètres',
      'theme': 'Thème',
      'language': 'Langue',
      'enableDyslexicFont': 'Activer la police adaptée à la dyslexie',
      'selectTheme': 'Choisir un thème',
      'apply': 'Appliquer',
      'selectLanguage': 'Choisir une langue',
      'light': 'Clair',
      'dark': 'Foncé',
      'colorblindAccessible': 'Accessible aux daltoniens',
    },
    'it_IT': {
      'settings': 'Impostazioni',
      'theme': 'Tema',
      'language': 'Lingua',
      'enableDyslexicFont': 'Abilita carattere adatto alla dislessia',
      'selectTheme': 'Seleziona tema',
      'apply': 'Applica',
      'selectLanguage': 'Seleziona lingua',
      'light': 'Chiaro',
      'dark': 'Scuro',
      'colorblindAccessible': 'Accessibile ai daltonici',
    },
  };
}
