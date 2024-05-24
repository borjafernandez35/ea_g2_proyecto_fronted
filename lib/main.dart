import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/activity_detail.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';
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
    return GetMaterialApp(
      title: 'SpotFinder',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
      ),
      initialRoute: token != null ? '/home' : '/',
      getPages: [
        GetPage(name: '/', page: () => TitleScreen()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(
          name: '/activity/:id',
          page: () => ActivityDetail(),
          transition: Transition.fade,
        ),
      ],
    );
  }
}


