import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';

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
          enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Pallete.backgroundColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
            color: Pallete.salmonColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
          ),
          hintText: text,
          hintStyle: const TextStyle(
            color: Pallete.greyColor,
          ),
        ),
        
      ),
    );
  }
}