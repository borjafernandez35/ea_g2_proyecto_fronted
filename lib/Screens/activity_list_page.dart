// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/activity_detail.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/new_activity.dart'; // Importa la nueva pantalla
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Widgets/activity_card.dart';
import 'package:spotfinder/Resources/pallete.dart';

late ActivityService activityService;

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({Key? key,}) : super(key: key);

  @override
  _ActivityListPage createState() => _ActivityListPage();
}

class _ActivityListPage extends State<ActivityListPage> {
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
      lista_activities = await activityService.getData();
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
        title: const Text(
          'Your feed',
          style: TextStyle(
            color: Pallete.backgroundColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Pallete.backgroundColor,
              child: InkWell(
                onTap: () {
                  Get.to(() => ActivityDetail(lista_activities[index]));
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
