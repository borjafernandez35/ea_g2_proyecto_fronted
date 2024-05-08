import 'package:flutter/material.dart';
import 'package:flutter_seminario/Models/ActivityModel.dart';
import 'package:flutter_seminario/Screens/detalles_user.dart';
import 'package:flutter_seminario/Screens/register_screen.dart';
import 'package:flutter_seminario/Screens/detalles_user.dart';

import 'package:flutter_seminario/Resources/pallete.dart';
import 'package:get/get.dart';


class PostWidget extends StatelessWidget {
  final Activity place;

  const PostWidget({Key? key, required this.place}) : super(key: key);

  @override 
  Widget build(BuildContext context){
    return Card(
      child: ListTile(
        title: Text(place.name),
        subtitle: Text(place.description),
        onTap: () {
          Get.to(() => UserDetailsPage(place));
        },
      ),
    );
  }
}
