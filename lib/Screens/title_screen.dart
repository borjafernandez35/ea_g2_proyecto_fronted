import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';
import 'package:spotfinder/Screens/Signin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotfinder/Widgets/button_sign_in.dart';
import '../Resources/sign_in_button.dart';

class TitleScreen extends StatelessWidget {
 // final SignIn _signIn = SignIn(googleSignIn: GoogleSignIn,);

    final GoogleSignIn googleSignIn; // Agrega este campo

  TitleScreen({super.key, required this.googleSignIn}); 
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
              Container(
                margin: const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  children: [
                    // Botón de inicio de sesión con Google
                   // SignIn(googleSignIn: googleSignIn),
                    SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LoginScreen() // Navega a la pantalla de inicio de sesión
                              ), 
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
                 ],
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
                      style: const TextStyle(
                        color: Pallete.salmonColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration
                            .underline, // Subraya el texto "Sign up"
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
          /* Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              child:  SignInButton(
                googleSignIn: _signIn.googleSignIn,
                onPressed: _signIn.handlesigin(),
                text: 'Sign in with Google',
              ),
            ),
          ), */
        ],
      ),
    );
  }
}
