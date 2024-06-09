import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/SignInService.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:google_sign_in/google_sign_in.dart';


void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de que los widgets estén inicializados
  await GetStorage.init(); // Espera la inicialización de GetStorage
  

   // Inicializa GoogleSignIn
  final UserService userService = UserService();
  final String? token = await userService.getToken();
  
  runApp(MyApp(
    token: token,
    
  ));
}





class MyApp extends StatelessWidget {
  final String? token;
  //final GoogleSignIn googleSignIn;

  const MyApp({super.key, this.token,  });

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'SpotFinder';

    // Si tienes un token, muestra la pantalla principal del usuario; de lo contrario, muestra la pantalla de título
    return GetMaterialApp(
      title: appTitle,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
      ),
      home: token != null ? HomePage() : TitleScreen(),
    );
  }
}
