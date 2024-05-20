import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:spotfinder/Widgets/user_card.dart';
import 'package:spotfinder/Resources/pallete.dart';

late ActivityService activityService;
late UserService userService;
late List<User> users = [];
late User user;

class ActivityDetail extends StatefulWidget {
  final Activity activity;
  const ActivityDetail(this.activity, {Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ActivityDetail createState() => _ActivityDetail();
}

class _ActivityDetail extends State<ActivityDetail> {
  final ActivityDetailController controllerActivityDetail = Get.put(ActivityDetailController());
  // ignore: non_constant_identifier_names

  bool isLoading = true; // Nuevo estado para indicar si se están cargando los datos

  @override
  void initState() {
    super.initState();
    userService = UserService();
    activityService = ActivityService();
    userService = UserService();
    final listLength = widget.activity.listUsers?.length ?? 0;
    print(listLength);
    user = User(
      name: '',
      email: '',
      phone_number: '',
      gender: '',
      password: ''
    ); 
    getData(listLength);
  }
  void getData(int length) async {
    try {
      for (var i = 0; i < length; i++) {
        user = await userService.getAnotherUser(widget.activity.listUsers?[i]);
        users.add(user);
        print(user.name);
      }
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
    if (isLoading) {
      // Muestra un indicador de carga mientras se cargan los datos
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.whiteColor,
          title: Center(
            widthFactor: 5,
            child: Text(widget.activity.name,
              style: const TextStyle(
                color: Pallete.backgroundColor,
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Pallete.backgroundColor,
              ),
              onPressed: () {
                Get.to(() => HomePage());
              },
            ),
          ),
        ),
        body: Center(
          child: Column(children: [
              const SizedBox(height: 40,),
              Container(
                margin: const EdgeInsets.only(left: 30),
                child: Column(children: [
                    const Text(
                      'Description:',
                      style: TextStyle(
                        color: Pallete.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.activity.name,
                      style: const TextStyle(
                        color: Pallete.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${widget.activity.rate} ⭐',
                      style: const TextStyle(
                        color: Pallete.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(40), // Ajusta el margen del cuadro negro aquí
                      padding: const EdgeInsets.all(20), // Ajusta el padding del cuadro negro aquí
                      decoration: BoxDecoration(
                        color: Pallete.primaryColor, // Color del cuadro negro con opacidad
                        borderRadius: BorderRadius.circular(20), // Bordes redondeados del cuadro
                      ),
                      child: Column(children: [
                          const Text(
                            'Users participating',
                            style: TextStyle(
                              color: Pallete.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20,),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.activity.listUsers?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              print(users[index].name);
                              return Card(
                                color: Pallete.whiteColor,
                                child: UserCard(users[index].name),
                              );
                            },
                          ),
                          const SizedBox(height: 20,),
                          SignUpButton(onPressed: () => controllerActivityDetail.joinActivity(widget.activity.id), text: 'Join')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ], 
          ),
        ),
      );
    }
  }
}

  
class ActivityDetailController extends GetxController {
  
  void joinActivity(String? id) {
    activityService.joinActivity(id);
  }
}
