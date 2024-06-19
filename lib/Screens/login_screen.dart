import 'package:flutter/material.dart';
import 'package:spotfinder/Widgets/button_sign_in.dart';
import 'package:spotfinder/Widgets/paramTextBox.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';

late UserService userService;
late String? id;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final Controller controller = Get.put(Controller());
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    id = Get.arguments?['id'];
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotFinder'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/spotfinder.png',
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'SpotFinder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Find the best activities around you!',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                key: ValueKey<bool>(_obscureText),
                                children: [
                                  ParamTextBox(
                                    controller: controller.mailController,
                                    text: 'e-mail',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  const SizedBox(height: 20),
                                  ParamTextBox(
                                    controller: controller.contrasenaController,
                                    text: 'Password',
                                    obscureText: _obscureText,
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SignInButton(
                              onPressed: () => controller.logIn(),
                              text: 'Sign in',
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/password_recovery');
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    if (contrasenaController.text.isEmpty || mailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Campos vacios',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (GetUtils.isEmail(mailController.text) == true) {
        final logIn = (
          email: mailController.text,
          password: contrasenaController.text,
        );

        userService.logIn(logIn).then((statusCode) {
          print('Usuario logeado exitosamente');
          if (id != null) {
            Get.toNamed('/activity/$id');
          } else {
            Get.toNamed('/home');
          }
          contrasenaController.text = '';
        }).catchError((error) {
          Get.snackbar(
            'Error',
            'Los datos introducidos son incorrectos. Prueba otra vez.',
            snackPosition: SnackPosition.BOTTOM,
          );
          print('Error al enviar log in al backend: $error');
        });
      } else {
        Get.snackbar(
          'Error',
          'e-mail no valido',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
