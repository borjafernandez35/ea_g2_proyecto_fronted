/* import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotfinder/Resources/pallete.dart';

/* class SignInButton extends StatelessWidget {
  final String text; 
  final VoidCallback onPressed; */
  //const SignInButton({Key? key, required this.onPressed, required this.text, required GoogleSignIn googleSignIn}) : super(key: key);

  @override 
  Widget build(BuildContext context){
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 55),
        backgroundColor: Pallete.salmonColor,
        foregroundColor: Colors.white,
      ),
      child: Text(text, style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 27,
      ),),
    );
  }
} */