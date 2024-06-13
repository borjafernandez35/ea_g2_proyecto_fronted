import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/detalles_user.dart';
import 'package:spotfinder/Screens/my_comments_screen.dart';
import 'package:spotfinder/Screens/my_activities.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

late UserService userService;
User? user;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    user = User(
        name: '',
        email: '',
        phone_number: '',
        gender: '',
        password: ''); // Provide an initial value
    getData();
  }

  Future<void> getData() async {
    await userService.getUser().then((retrievedUser) {
      setState(() {
        user = retrievedUser;
        isLoading = false;
      });
    }).catchError((error) {
      // Handle error
      print("Error fetching user data: $error");
    });
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/dgwbrwvux/image/upload');
      final String filename =
          'upload_${DateTime.now().millisecondsSinceEpoch}.png';
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'typvcah6'
        ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: filename));

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await http.Response.fromStream(response);
          final jsonData = jsonDecode(responseData.body);
          final imageUrl = jsonData['secure_url'];

          user?.image = imageUrl;

          userService.updateUser(user!).then((_) {
            getData();
          }).catchError((error) {
            Get.snackbar(
              'Error',
              'Error sending user to backend: $error',
              snackPosition: SnackPosition.BOTTOM,
            );
          });
        } else {
          print(
              'Error al subir la imagen a Cloudinary: ${response.statusCode}');
          return;
        }
      } catch (e) {
        return;
      }
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        backgroundColor: Pallete.whiteColor,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de información del usuario
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Avatar y botón de edición
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Pallete.accentColor,
                          child: user?.image == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Pallete.paleBlueColor,
                                )
                              : ClipOval(
                                  child: Image.network(
                                    user!.image!,
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: -10,
                          left: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Pallete.paleBlueColor,
                              padding: EdgeInsets.all(8),
                            ),
                            onPressed: () {
                              _showImageSourceActionSheet(context);
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Pallete.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                        // Texto del nombre del usuario
                        Positioned(
                          left: 140, // Ajusta la posición horizontal del nombre
                          top: 27,
                          child: Align(
                            alignment: Alignment
                                .centerLeft, // Alinea el texto a la izquierda
                            child: Text(
                              user!.name,
                              style: const TextStyle(
                                fontSize: 26.0,
                                fontWeight: FontWeight.bold,
                                color: Pallete.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botones de navegación
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.to(() =>
                                UserDetailsPage(user!, onUpdate: getData));
                          },
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'My profile',
                              style: TextStyle(color: Pallete.primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Get.to(() => MyActivities());
                          },
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'My activities',
                              style: TextStyle(color: Pallete.primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Get.to(() =>
                                MyCommentsScreen(user!, onUpdate: getData));
                          },
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'My reviews',
                              style: TextStyle(color: Pallete.primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            // Navegar a otra pantalla (puedes reemplazar esta función)
                          },
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Preferences',
                              style: TextStyle(
                                  color:
                                      Pallete.primaryColor), // Texto en negro
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            userService.logout();
                            Get.to(() => TitleScreen());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Pallete.salmonColor, // Color del texto
                          ),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.exit_to_app, // Icono de log out
                                  color: Pallete.salmonColor, // Color del icono
                                ),
                                SizedBox(
                                    width:
                                        8), // Espaciado entre el icono y el texto
                                Text(
                                  'Log out',
                                  style: TextStyle(
                                      color: Pallete
                                          .salmonColor), // Color del texto
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                child: TextButton(
                  onPressed: () {
                    // Acción para el nuevo botón en la parte inferior
                    Get.toNamed('/settings');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(12.0), // Padding del botón
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.settings, // Icono de configuración
                        color: Pallete.backgroundColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: TextStyle(color: Pallete.backgroundColor),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
