import 'package:flutter/material.dart';
import 'package:flutter_seminario/Resources/pallete.dart';
import 'package:flutter_seminario/Screens/login_screen.dart';
import 'package:flutter_seminario/Screens/home_page.dart';
import 'package:flutter_seminario/Screens/title_screen.dart';
import 'package:get/get.dart';

void main() {
  Get.put(GlobalController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'SpotFinder';
    return GetMaterialApp(
      title: appTitle,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.backgroundColor,
      ),
      home: TitleScreen(),
    );
  }
}

class GlobalController extends GetxController {
  RxString token = "".obs;
}

