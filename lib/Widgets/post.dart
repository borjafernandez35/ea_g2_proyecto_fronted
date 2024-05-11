import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/detalles_user.dart';
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
