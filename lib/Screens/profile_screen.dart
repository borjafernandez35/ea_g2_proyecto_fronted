import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/detalles_user.dart';
import 'package:spotfinder/Screens/history.dart';
import 'package:spotfinder/Screens/my_comments_screen.dart';
import 'package:spotfinder/Screens/my_activities.dart';
import 'package:spotfinder/Screens/settingsScreen.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
late UserService userService;
User? user;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  bool isLoading = true;
  int _selectedIndex = 0;

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
    try {
      final retrievedUser = await userService.getUser();
      setState(() {
        user = retrievedUser;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Error fetching user data: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Pallete.textColor,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        final bytes = await pickedImage.readAsBytes();
        final url = Uri.parse('https://api.cloudinary.com/v1_1/dgwbrwvux/image/upload');
        final String filename = 'upload_${DateTime.now().millisecondsSinceEpoch}.png';
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'byxhgftn'
          ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await http.Response.fromStream(response);
          final jsonData = jsonDecode(responseData.body);
          final imageUrl = jsonData['secure_url'];

          user?.image = imageUrl;

          try {
            await userService.updateUser(user!);
            getData();
          } catch (error) {
            Get.snackbar(
              'Error',
              'Error sending user to backend: $error',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Pallete.textColor,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Error uploading image',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Pallete.textColor,
          );
        }
      } else {
        print('No se seleccionó ninguna imagen.');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error unexpected: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Pallete.textColor,
      );
    }
  }

  Future<void> deleteImageFromUrl(String imageUrl) async {
    try {
      final String cloudName = 'dgwbrwvux';
      final String apiKey = '388645541249985';
      final String apiSecret = 'MTRqeAf4459Akl-4NwIbzYP0jCM';
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final Uri uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final String publicId = segments.last.split('.').first;

      // Create the signature
      final String signatureBase =
          'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final String signature =
          sha1.convert(utf8.encode(signatureBase)).toString();

      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        user?.image = null;
        await userService.updateUser(user!);
        getData();
      } else {
        Get.snackbar(
          'Error',
          'Error removing image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Pallete.textColor,
        );
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'Error removing image: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Pallete.textColor,
      );
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
              if (user?.image != null)
                ListTile(
                  leading: const Icon(Icons.remove_circle),
                  title: const Text('Remove image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteImageFromUrl(user!.image!);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

    void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        backgroundColor: Pallete.backgroundColor,
        body: Row(
          children: [
            Container(
              width: 250.0,
              decoration: BoxDecoration(
                color: Pallete.primaryColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Pallete.textColor.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(-2, 2),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      user!.name,
                      style: TextStyle(color: Pallete.backgroundColor),
                    ),
                    accountEmail: Text(
                      user!.email,
                      style: TextStyle(color: Pallete.backgroundColor),
                    ),
                    currentAccountPicture: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Pallete.paleBlueColor,
                            child: user?.image == null
                                ? Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Pallete.primaryColor,
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      user!.image!,
                                      fit: BoxFit.cover,
                                      height: 110,
                                      width: 110,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                minimumSize: Size(36, 36),
                                backgroundColor: Pallete.primaryColor,
                                padding: EdgeInsets.all(8),
                              ),
                              onPressed: () {
                                _showImageSourceActionSheet(context);
                              },
                              child: Icon(
                                Icons.edit,
                                color: Pallete.paleBlueColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Pallete.accentColor.withOpacity(0.7),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('My Profile', style: TextStyle(color: Pallete.textColor)),
                    onTap: () {
                      _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_activity),
                    title: Text('My Activities', style: TextStyle(color: Pallete.textColor)),
                    onTap: () {
                      _onItemTapped(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.comment),
                    title: Text('My Reviews', style: TextStyle(color: Pallete.textColor)),
                    onTap: () {
                      _onItemTapped(2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('History', style: TextStyle(color: Pallete.textColor)),
                    onTap: () {
                      _onItemTapped(3);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text('Settings', style: TextStyle(color: Pallete.textColor)),
                    onTap: () {
                      _onItemTapped(4);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      color: Pallete.salmonColor,
                    ),
                    title: Text(
                      'Log out',
                      style: TextStyle(
                        color: Pallete.salmonColor,
                      ),
                    ),
                    onTap: () {
                      userService.logout();
                      Get.to(() => TitleScreen());
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  UserDetailsPage(user!, onUpdate: getData),
                  MyActivities(),
                  MyCommentsScreen(user!, onUpdate: getData),
                  HistoryPage(user!),
                  SettingsScreen(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
