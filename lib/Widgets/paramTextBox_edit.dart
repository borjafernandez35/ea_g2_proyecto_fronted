import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotfinder/Resources/pallete.dart';

class ParamTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final TextInputType keyboardType;
  final bool? editable;
  final List<TextInputFormatter>? inputFormatters;

  const ParamTextBox({
    required this.controller,
    required this.text,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: !editable!,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: const TextStyle(
          color: Pallete.accentColor, // Color del texto del label
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Pallete.accentColor, // Color del borde
          ),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: Pallete.backgroundColor),
    );
  }
}