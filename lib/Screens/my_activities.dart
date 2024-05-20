// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/activity_detail.dart';
import 'package:spotfinder/Screens/edit_activity.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/new_activity.dart'; // Importa la nueva pantalla
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Widgets/activity_card.dart';
import 'package:spotfinder/Resources/pallete.dart';

late ActivityService activityService;

class MyActivities extends StatefulWidget {
  const MyActivities({Key? key}) : super(key: key);

  @override
  _MyActivities createState() => _MyActivities();
}

class _MyActivities extends State<MyActivities> {
  late List<Activity> lista_activities;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    activityService = ActivityService();
    getData();
  }

  void getData() async {
    try {
      lista_activities = await activityService.getUserActivities();
      setState(() {
        isLoading = false;
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
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.whiteColor,
          title: Center(
            child: Text('Your activities',
              style: TextStyle(
                color: Pallete.backgroundColor,
              ),
            ),
          ),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Pallete.backgroundColor,
              ),
              onPressed: () {
                Get.to(HomePage());
              },
            ),
          ),
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Pallete.backgroundColor,
              child: InkWell(
                onTap: () {
                  print(lista_activities[index]);
                  Get.to(() => EditActivity(onUpdate: getData, id: lista_activities[index].id));
                },
                child: ActivityCard(lista_activities[index]),
              ),
            );
          },
          itemCount: lista_activities.length,
        ),
        floatingActionButton: Tooltip(
          message: 'Add new activity',
          child: FloatingActionButton(
            backgroundColor: Pallete.backgroundColor,
            child: Icon(Icons.add),
            onPressed: () {
              Get.to(() => NewActivityScreen(onUpdate: getData));
            },
          ),
        ),
      );
    }
  }
}
