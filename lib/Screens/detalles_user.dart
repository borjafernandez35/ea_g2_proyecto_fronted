import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/title_screen.dart';
import 'package:spotfinder/Services/UserService.dart';

late UserService userService;

const List<String> phonePrefixes = [
  '+1',
  '+7',
  '+20',
  '+27',
  '+30',
  '+31',
  '+32',
  '+33',
  '+34',
  '+36',
  '+39',
  '+40',
  '+41',
  '+43',
  '+44',
  '+45',
  '+46',
  '+47',
  '+48',
  '+49',
  '+51',
  '+52',
  '+53',
  '+54',
  '+55',
  '+56',
  '+57',
  '+58',
  '+60',
  '+61',
  '+62',
  '+63',
  '+64',
  '+65',
  '+66',
  '+81',
  '+82',
  '+84',
  '+86',
  '+90',
  '+91',
  '+92',
  '+93',
  '+94',
  '+95',
  '+98',
  '+211',
  '+212',
  '+213',
  '+216',
  '+218',
  '+220',
  '+221',
  '+222',
  '+223',
  '+224',
  '+225',
  '+226',
  '+227',
  '+228',
  '+229',
  '+230',
  '+231',
  '+232',
  '+233',
  '+234',
  '+235',
  '+236',
  '+237',
  '+238',
  '+239',
  '+240',
  '+241',
  '+242',
  '+243',
  '+244',
  '+245',
  '+246',
  '+247',
  '+248',
  '+249',
  '+250',
  '+251',
  '+252',
  '+253',
  '+254',
  '+255',
  '+256',
  '+257',
  '+258',
  '+260',
  '+261',
  '+262',
  '+263',
  '+264',
  '+265',
  '+266',
  '+267',
  '+268',
  '+269',
  '+290',
  '+291',
  '+297',
  '+298',
  '+299'
];

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
    final prefix = phonePrefixes.firstWhere(
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
          title: Text('Detalles del Usuario'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              ParamTextBox(
                controller: controller.nombreController,
                text: 'Nombre',
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
                        items: phonePrefixes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Prefijo',
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
                      text: 'Teléfono',
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
                      text: 'Cumpleaños',
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
                text: 'Género',
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
                child: const Text('Eliminar Cuenta'),
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
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de querer eliminar tu cuenta?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                userService.deleteUser();
                Get.to(TitleScreen());
              },
              child: Text('Eliminar cuenta'),
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
  final List<TextInputFormatter>? inputFormatters;

  const ParamTextBox({
    required this.controller,
    required this.text,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
        'Campos vacíos',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (GetUtils.isEmail(mailController.text) == true &&
          validatePhoneNumber(telController.text)) {
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
          print('Usuario editado exitosamente');
          Get.snackbar(
            '¡Usuario editado!',
            'Usuario editado correctamente',
            snackPosition: SnackPosition.BOTTOM,
          );
        }).catchError((error) {
          Get.snackbar(
            'Error',
            'Error al enviar usuario al backend: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
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

  bool validatePhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^[\d\s]{7,15}$');
    return regex.hasMatch(phoneNumber);
  }
}
