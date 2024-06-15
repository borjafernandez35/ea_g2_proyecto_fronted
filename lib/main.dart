import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/activity_detail.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';
import 'package:spotfinder/Screens/settingsScreen.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spotfinder/l10n/app_localizations.dart';
import 'package:spotfinder/localization/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final UserService userService = UserService();
  final String? token = await userService.getToken();

  setUrlStrategy(PathUrlStrategy());

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SpotFinder',
      theme: _getAppTheme(),
      locale: Locale(_getLocale()), // Configura el idioma seleccionado
      translations: LocalizationService(),
      fallbackLocale: Locale('en', 'US'),
      supportedLocales: LocalizationService.locales.values.toList(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      getPages: [
        GetPage(name: '/', page: () => TitleScreen()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
        GetPage(
          name: '/activity/:id',
          page: () => ActivityDetail(),
          transition: Transition.fade,
        ),
      ],
      initialRoute: token != null ? '/home' : '/',
    );
  }

  String _getLocale() {
    final box = GetStorage();
    return box.read('lang') ?? 'en';
  }

  ThemeData _getAppTheme() {
    final box = GetStorage();
    String? font = box.read('font');
    String? theme = box.read('theme') ?? 'Light';

    switch (theme) {
      case 'Dark':
        Pallete.setDarkTheme();
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Pallete.backgroundColor,
          textTheme: _getFontTextTheme(font),
        );
      case 'Custom':
        Pallete.setCustomTheme();
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Pallete.backgroundColor,
          textTheme: _getFontTextTheme(font),
        );
      case 'Light':
      default:
        Pallete.setLightTheme();
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Pallete.backgroundColor,
          textTheme: _getFontTextTheme(font),
        );
    }
  }

  TextTheme? _getFontTextTheme(String? font) {
    switch (font) {
      case 'Dyslexia':
        return GoogleFonts.comicNeueTextTheme();
      case 'Default':
      default:
        return null;
    }
  }
}
