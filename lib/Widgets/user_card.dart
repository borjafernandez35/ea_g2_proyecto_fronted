import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Screens/activity_detail.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Services/UserService.dart';

late UserService userService;
String? name;

class UserCard extends StatefulWidget {
  final String? uId;
  const UserCard(this.uId ,{super.key,});

  @override
  // ignore: library_private_types_in_public_api
  _UserCard createState() => _UserCard();
}

class _UserCard extends State<UserCard> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    getData();
  }

  void getData() async {
    try {
      user = await userService.getAnotherUser(widget.uId);
      print(user.name);
      setState(() {
        isLoading = false; // Cambiar el estado de carga cuando los datos están disponibles
      });
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se han podido obtener los datos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (kDebugMode) {
        print('Error al comunicarse con el backend: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          surfaceTintColor: Pallete.accentColor,
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Row(
            children: [
              // Left side: Image
              Container(
                width: 75,
                height: 75,
                child: Image.network(
                  'https://via.placeholder.com/100', // Replace with your image URL
                  fit: BoxFit.cover,
                ),
              ),
              // Right side: Title, Description, and Value
              const SizedBox(width: 15),
              Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
            ],
          ),
        ),
        // Add other widgets below if needed
      ],
    );
  }
}