import 'package:flutter/material.dart';
import 'package:flutter_seminario/Resources/pallete.dart';

class ParamTextBox extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  ParamTextBox({Key? key, required this.controller, required this.text}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true, // Establecer como true para agregar un fondo
          fillColor: Colors.white, // Establecer el color de fondo
          enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
            color: Pallete.salmonColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(50),
          ),
          hintText: text,
          hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 20.0), // Cambiar el color y tamaño del texto dentro del cuadro de texto
          contentPadding: EdgeInsets.only(left: 20.0),
          
        ),
        
      ),
    );
  }
}