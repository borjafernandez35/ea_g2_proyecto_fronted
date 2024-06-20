import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Utils/phone_utils.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:spotfinder/Widgets/paramTextBox_sign_up.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';

late UserService userService;
late String? id;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final RegisterController controller = Get.put(RegisterController());

  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    id = Get.arguments?['id'];
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotFinder'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/spotfinder.png',
                            height: 150,
                            width: 150,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'SpotFinder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Find the best spots around you!',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ParamTextBox(
                              controller: controller.nameController,
                              text: 'Name',
                            ),
                            const SizedBox(height: 10),
                            ParamTextBox(
                              controller: controller.mailController,
                              text: 'E-mail',
                            ),
                            const SizedBox(height: 10),
                            ParamTextBox(
                              controller: controller.phoneController,
                              text: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                              ],
                              prefixWidget: DropdownButtonFormField<String>(
                                value: controller.selectedPrefix.value,
                                alignment: Alignment.centerRight,
                                onChanged: (String? newValue) {
                                  controller.selectedPrefix.value = newValue!;
                                },
                                items: PhoneUtils.phonePrefixes.map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: TextStyle(color: Colors.grey)),
                                    );
                                  },
                                ).toList(),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 5.6),
                                ),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ParamTextBox(
                              controller: controller.birthdayController,
                              text: 'Birthday',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => controller.selectDate(context),
                              ),
                              editable: false,
                            ),
                            const SizedBox(height: 10),
                            ParamTextBox(
                              controller: controller.genderController,
                              text: 'Gender',
                            ),
                            const SizedBox(height: 10),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                key: ValueKey<bool>(_obscureText),
                                children: [
                                  ParamTextBox(
                                    controller: controller.contrasenaController,
                                    text: 'Password',
                                    obscureText: _obscureText,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ParamTextBox(
                                    controller: controller.confirmcontrasenaController,
                                    text: 'Confirm Password',
                                    obscureText: _obscureText,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SignUpButton(
                              onPressed: () => controller.signUp(),
                              text: 'Sign up',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmcontrasenaController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  late String date;

  var selectedPrefix = '+34'.obs;

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
      String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString()}";
      birthdayController.text = formattedDate;
      date = utcDate.toIso8601String();
    }
  }

  void signUp() {
    if (contrasenaController.text.isEmpty || mailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Campos vacíos',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (contrasenaController.text != confirmcontrasenaController.text) {
      Get.snackbar(
        'Error',
        'Las contraseñas no coinciden',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (GetUtils.isEmail(mailController.text) == true &&
          PhoneUtils.validatePhoneNumber(phoneController.text)) {
        User newUser = User(
          name: nameController.text,
          email: mailController.text,
          password: contrasenaController.text,
          birthday: date,
          phone_number: '${selectedPrefix.value}${phoneController.text.trim()}',
          gender: genderController.text,
        );
        userService.createUser(newUser).then((statusCode) {
          print('Usuario creado exitosamente');
          Get.toNamed('/login', arguments: {'id': id});
        }).catchError((error) {
          Get.snackbar(
            'Error',
            'Los datos introducidos son incorrectos. Prueba otra vez.',
            snackPosition: SnackPosition.BOTTOM,
          );
          if (kDebugMode) {
            print('Error al enviar create in al backend: $error');
          }
        });
      } else {
        Get.snackbar(
          'Error',
          'E-mail o teléfono no válidos',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
