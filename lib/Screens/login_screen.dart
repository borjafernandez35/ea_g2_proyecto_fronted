import 'package:flutter/material.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/register_screen.dart';
import 'package:spotfinder/Widgets/button_sign_in.dart';
import 'package:spotfinder/Widgets/paramTextBox.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';

late UserService userService;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final Controller controller = Get.put(Controller());

  @override
  void initState(){
    super.initState();
    userService = UserService();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotFinder'),
      ),
      // #docregion addWidget
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text('Log in', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 15),
              ParamTextBox(controller: controller.mailController, text: 'E-Mail'),
              const SizedBox(height: 15),
              ParamTextBox(controller: controller.contrasenaController, text: 'Contraseña'),
              const SizedBox(height: 40),
              SignInButton(onPressed: () => controller.logIn(), text: 'Log in'),
              const SizedBox(height: 15),
              SignInButton(onPressed: () => Get.to(RegisterScreen()), text: 'Register'),
            ],
          ),
        )
      ),
    );
  }
}

class Controller extends GetxController {
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController mailController = TextEditingController();

  bool invalid = false;
  bool parameters = false;

  void logIn() {
    if(contrasenaController.text.isEmpty || mailController.text.isEmpty){
      Get.snackbar(
        'Error', 
        'Campos vacios',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    else{
      if(GetUtils.isEmail(mailController.text)==true){
        final logIn = (
          email: mailController.text,
          password: contrasenaController.text,
        );
        userService.logIn(logIn).then((statusCode) {
          // La solicitud se completó exitosamente, puedes realizar acciones adicionales si es necesario
          print('Usuario creado exitosamente');
          Get.to(() => HomePage());
        }).catchError((error) {
          // Manejar errores de solicitud HTTP
          Get.snackbar(
            'Error',
            'Este E-Mail ya está en uso actualmente.',
            snackPosition: SnackPosition.BOTTOM,
          );
          print('Error al enviar log in al backend: $error');
        });
      }
      else{
        Get.snackbar(
          'Error', 
          'e-mail no valido',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}



