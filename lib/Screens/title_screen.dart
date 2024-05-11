import 'package:flutter/material.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';

class TitleScreen extends StatelessWidget {
  Widget build(BuildContext context){
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
              SizedBox(height:20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Iniciar Sesión'),
              ),
              SizedBox(height: 10),
              //Enlace a pagina de registro
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}