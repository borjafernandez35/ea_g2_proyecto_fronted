import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Screens/Signin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_identity_services_web/google_identity_services_web.dart' as gis;

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura la inicialización de los widgets
  await GetStorage.init(); // Inicializa GetStorage
  await gis.loadWebSdk();
final GoogleSignIn _googleSignIn =
      initGoogleSignIn(); // Inicializa GoogleSignIn
  final UserService userService = UserService();
  final String? token = await userService.getToken();
 final IdConfiguration idConfiguration = IdConfiguration(
    client_id: '435863540335-3edtkmprvlpkb3j4ea522cvndn8mc7mr.apps.googleusercontent.com',
    use_fedcm_for_prompt: true,
  );
  id.initialize(idConfiguration);
    id.setLogLevel('debug');
  

  runApp(MyApp(token: token, googleSignIn: _googleSignIn));
}


GoogleSignIn initGoogleSignIn() {
  return GoogleSignIn(
    scopes: scopes,
  );
}

class MyApp extends StatelessWidget {
  final String? token;
  final GoogleSignIn googleSignIn;

  const MyApp({Key? key, this.token, required this.googleSignIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'SpotFinder';

    // Si tienes un token, muestra la pantalla principal del usuario; de lo contrario, muestra la pantalla de inicio de sesión
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
      ),
      home: token != null ? HomePage() :// TitleScreen(googleSignIn: googleSignIn)
      SignIn(googleSignIn: googleSignIn),
    );
  }
}
