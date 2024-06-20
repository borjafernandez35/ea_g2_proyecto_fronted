import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';

class ParamTextBox extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final bool obscureText;
  final IconButton? suffixIcon;
  final Icon? prefixIcon;
  final String? Function(String?)? validator;

  const ParamTextBox({
    super.key,
    required this.controller,
    required this.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Pallete.backgroundColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Pallete.salmonColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
          hintText: text,
          hintStyle: const TextStyle(
            color: Color.fromARGB(255, 122, 122, 122),
          ),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: suffixIcon!,
                )
              : null,
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: prefixIcon!,
                )
              : null,
          errorStyle: TextStyle(color: Colors.red),
        ),
        validator: validator,
      ),
    );
  }
}


