import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/pallete.dart';

class TitleScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final String? id = Get.arguments?['id'];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Fondo de pantalla
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          // Contenido de la pantalla
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo de SpotFinder
              Image.asset(
                'assets/spotfinder.png',
                height: 200,
                width: 200,
              ),
              Container(
                margin: const EdgeInsets.all(
                  20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón
                    Get.toNamed('/login',  arguments: {'id' : id});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete
                        .salmonColor, // Cambia el color del botón a salmón
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 26, // Ajusta el tamaño del texto aquí
                      color: Colors.white, // Cambia el color del texto a blanco
                    ),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(
                      text: "Don't have an account? ",
                    ),
                    TextSpan(
                      text: "Sign up",
                      style: TextStyle(
                        color: Pallete.salmonColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline, // Subraya el texto "Sign up"
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                           Get.toNamed('/register',  arguments: {'id' : id});
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}