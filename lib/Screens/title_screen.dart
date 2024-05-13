import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';

class TitleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              Positioned(
                bottom: 200, // Ajusta la posición vertical aquí
                left: 50,
                child: Container(
                  width: 200, // Ajusta el ancho del contenedor aquí
                  height: 50, // Ajusta la altura del contenedor aquí
                  margin: const EdgeInsets.all(
                      20), // Establece el margen deseado aquí
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción al presionar el botón
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()), // Navega a la pantalla de inicio de sesión
                      );
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
              ),
              Positioned(
                top: 100,
                left: 50,
                child: RichText(
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
                        style: const TextStyle(
                          color: Pallete
                          .salmonColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, // Subraya el texto "Sign up"
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}