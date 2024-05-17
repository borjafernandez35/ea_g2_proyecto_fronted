import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Utils/phone_utils.dart';

late UserService userService;

class UserDetailsPage extends StatefulWidget {
  final User user;
  final VoidCallback onUpdate;

  const UserDetailsPage(this.user, {Key? key, required this.onUpdate})
      : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final UpdateScreenController controller = Get.put(UpdateScreenController());

  @override
  void initState() {
    super.initState();

    final phoneNumber = widget.user.phone_number;
    final prefix = PhoneUtils.phonePrefixes.firstWhere(
      (prefix) => phoneNumber.startsWith(prefix),
      orElse: () => '+1',
    );
    final number = phoneNumber.replaceFirst(prefix, '').trim();

    userService = UserService();
    controller.nombreController.text = widget.user.name;
    controller.generoController.text = widget.user.gender;
    controller.contrasenaController.text = widget.user.password;
    controller.mailController.text = widget.user.email;
    controller.selectedPrefix.value = prefix;
    controller.telController.text = number;
    controller.date = widget.user.birthday!;
    if (widget.user.birthday != null) {
      final DateTime birthdayDateTime = DateTime.parse(widget.user.birthday!);
      final localBirthdayDateTime = birthdayDateTime.toLocal();
      final formattedBirthday =
          "${localBirthdayDateTime.day.toString().padLeft(2, '0')}/${localBirthdayDateTime.month.toString().padLeft(2, '0')}/${localBirthdayDateTime.year}";
      controller.cumpleController.text = formattedBirthday;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(), // Establecer el tema en modo claro
      child: Scaffold(
        appBar: AppBar(
          title: Text('User details'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              ParamTextBox(
                controller: controller.nombreController,
                text: 'Name',
              ),
              SizedBox(height: 15),
              ParamTextBox(
                controller: controller.mailController,
                text: 'E-Mail',
              ),
              Visibility(
                visible: controller.invalid,
                child: Text(
                  'Invalid',
                  style: TextStyle(
                    color: Pallete.salmonColor,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedPrefix.value,
                        onChanged: (String? newValue) {
                          controller.selectedPrefix.value = newValue!;
                        },
                        items: PhoneUtils.phonePrefixes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Prefix',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: ParamTextBox(
                      controller: controller.telController,
                      text: 'Phone number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ParamTextBox(
                      controller: controller.cumpleController,
                      text: 'Birthdate',
                      editable: false,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => controller.selectDate(context),
                  ),
                ],
              ),
              SizedBox(height: 15),
              ParamTextBox(
                controller: controller.generoController,
                text: 'Gender',
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  controller.updateUser(widget.user);
                  widget.onUpdate();
                },
                child: const Text('Update'),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _confirmDeleteAccount(context),
                child: const Text('Delete account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                userService.deleteUser();
                Get.to(TitleScreen());
              },
              child: Text('Delete account'),
            ),
          ],
        );
      },
    );
  }
}

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
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}

class UpdateScreenController extends GetxController {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController generoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController cumpleController = TextEditingController();
  late String date;

  var selectedPrefix = '+1'.obs;

  bool invalid = false;
  bool parameters = false;

  void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final utcDate = pickedDate.toUtc();
      String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString()}";
      cumpleController.text = formattedDate;

      date = utcDate.toIso8601String();
    }
  }

  void updateUser(User updatedUser) {
    if (nombreController.text.isEmpty ||
        generoController.text.isEmpty ||
        contrasenaController.text.isEmpty ||
        mailController.text.isEmpty ||
        telController.text.isEmpty ||
        cumpleController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Empty fields',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (GetUtils.isEmail(mailController.text) == true &&
          PhoneUtils.validatePhoneNumber(telController.text)) {
        User user = User(
          id: updatedUser.id,
          name: nombreController.text,
          gender: generoController.text,
          password: contrasenaController.text,
          email: mailController.text,
          phone_number: '${selectedPrefix.value}${telController.text.trim()}',
          birthday: date,
        );
        userService.updateUser(user).then((statusCode) {
          print('User successfully edited');
          Get.snackbar(
            'User edited!',
            'User edited successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }).catchError((error) {
          Get.snackbar(
            'Error',
            'Error sending user to backend: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      } else {
        Get.snackbar(
          'Error',
          'Invalid email or phone number',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
