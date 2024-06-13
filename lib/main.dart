import 'dart:html';
import 'dart:ui';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Espera la inicialización de GetStorage
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (token != null) {
        if (Get.currentRoute != '/home' &&
            !Get.currentRoute.contains('activity') &&
            !Get.currentRoute.contains('settings')) {
          Get.offAllNamed('/home');
        }
      }
    });

    final box = GetStorage();
    String? font = box.read('font');
    TextTheme? textTheme = getFontTextTheme(font);

    String? theme = box.read('theme');
    if (theme == null) {
      box.write('theme', "Light");
    }

    return GetMaterialApp(
      title: 'SpotFinder',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
        textTheme: textTheme,
      ),
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

  TextTheme? getFontTextTheme(String? font) {
    switch (font) {
      case 'Dyslexia':
        return GoogleFonts.comicNeueTextTheme().copyWith();
      case 'Default':
        return null;
    }
    return null;
  }
}
