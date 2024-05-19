import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Utils/phone_utils.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:spotfinder/Widgets/paramTextBox_sign_up.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';

late UserService userService;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final RegisterController controller = Get.put(RegisterController());

  @override
  void initState() {
    super.initState();
    userService = UserService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotFinder'),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/login_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo de la empresa
              Image.asset(
                'assets/spotfinder.png',
                height: 90,
                width: 90,
              ),
              const SizedBox(height: 5), // Separación entre el logo y el cuadro negro
              // Cuadro negro con el formulario de inicio de sesión
              Container(
                margin: const EdgeInsets.all(3), // Ajusta el margen del cuadro negro aquí
                padding: const EdgeInsets.all(3), // Ajusta el padding del cuadro negro aquí
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7), // Color del cuadro negro con opacidad
                  borderRadius: BorderRadius.circular(20), // Bordes redondeados del cuadro
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ParamTextBox(controller: controller.nameController, text: 'name'),
                    const SizedBox(height: 4),
                    ParamTextBox(controller: controller.mailController, text: 'e-mail'),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200), // Ancho máximo para el Row
                      child: Row(
                        children: [
                          Expanded(
                            child: ParamTextBox(
                              controller: controller.phoneController,
                              text: 'phone number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d\s]')),
                              ],
                              prefixWidget: Container(
                                width: double.infinity, // Ancho máximo del prefixWidget
                                child: DropdownButtonFormField<String>(
                                  value: controller.selectedPrefix.value,
                                  alignment: Alignment.centerRight,
                                  onChanged: (String? newValue) {
                                    controller.selectedPrefix.value = newValue!;
                                  },
                                  items: PhoneUtils.phonePrefixes
                                      .map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: TextStyle(color: Colors.grey)),
                                      );
                                    },
                                 ).toList(),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 5.6), // Adjusts the padding
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey), // Icono de flecha hacia abajo
                                ),
                                
                              ),
                            ),
                          ),
                        ],
                      ),
                    ), 
                    const SizedBox(height: 4),
                      ParamTextBox(
                      controller: controller.birthdayController,
                      text: 'birthday',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => controller.selectDate(context),
                      ),
                      editable: false, // Hace que el campo de cumpleaños no sea editable
                    ),
                    const SizedBox(height: 4),
                    ParamTextBox(controller: controller.genderController, text: 'gender'),
                    const SizedBox(height: 4),
                    ParamTextBox(controller: controller.contrasenaController, text: 'password'),
                    const SizedBox(height: 4),
                    ParamTextBox(controller: controller.confirmcontrasenaController, text: 'confirm password'),
                    const SizedBox(height: 4),
                    SignUpButton(onPressed: () => controller.signUp(), text: 'Sign up')
                  ],
                ),
              ),
            ],
          ),
        ),
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
      String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString()}";
      birthdayController.text = formattedDate;
      date = utcDate.toIso8601String();
    }
  }

  void signUp() {
    if (contrasenaController.text.isEmpty || mailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Campos vacios',
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
          // La solicitud se completó exitosamente, puedes realizar acciones adicionales si es necesario
          print('Usuario creado exitosamente');
          Get.to(() => const LoginScreen());
        }).catchError((error) {
          // Manejar errores de solicitud HTTP
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
