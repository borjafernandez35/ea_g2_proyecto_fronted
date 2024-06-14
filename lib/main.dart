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

class MyApp extends StatefulWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);

  static final GlobalKey<_MyAppState> _instance = GlobalKey<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? get instance => _instance.currentState;
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.token != null) {
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
      theme = "Light";
      box.write('theme', theme);
    }

    ThemeData themeData;

    switch (theme) {
      case 'Dark':
        themeData = ThemeData.dark().copyWith(
          primaryColor: Colors.white,
          backgroundColor: Colors.black,
          scaffoldBackgroundColor: Pallete.whiteColor,
          textTheme: textTheme,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
            ),
          ),
        );
        break;
      case 'Custom':
        themeData = ThemeData(
          primaryColor: const Color(0xFF7E1E9C), // morado
          backgroundColor: const Color(0xFFF97306),
          scaffoldBackgroundColor: const Color(0xFFF97306),
          textTheme: textTheme,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E1E9C), // morado
            ),
          ),
        );
        break;
      case 'Light':
      default:
        themeData = ThemeData.light().copyWith(
          primaryColor: Colors.black,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          textTheme: textTheme,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
            ),
          ),
        );
        break;
    }

    return GetMaterialApp(
      key: MyApp._instance,
      title: 'SpotFinder',
      theme: themeData,
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
      initialRoute: widget.token != null ? '/home' : '/',
    );
  }

  void restartApp() {
    setState(() {});
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
