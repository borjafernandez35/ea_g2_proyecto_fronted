import 'package:flutter/material.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  _PasswordRecoveryScreen createState() => _PasswordRecoveryScreen();
}

class _PasswordRecoveryScreen extends State<PasswordRecoveryScreen> {
  final TextEditingController emailController = TextEditingController();
  final UserService userService = UserService();

  void _recoverPassword() {
    final email = emailController.text;
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingrese su correo electrónico',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Correo electrónico no válido',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      userService.recoverPassword(email).then((_) {
        Get.snackbar(
          'Success',
          'Correo de recuperación enviado',
          snackPosition: SnackPosition.BOTTOM,
        );
      }).catchError((error) {
        Get.snackbar(
          'Error',
          'No se pudo enviar el correo de recuperación',
          snackPosition: SnackPosition.BOTTOM,
        );
        print('Error al enviar correo de recuperación: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingrese su correo electrónico para recuperar su contraseña',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recoverPassword,
              child: const Text('Enviar correo de recuperación'),
            ),
          ],
        ),
      ),
    );
  }
}
