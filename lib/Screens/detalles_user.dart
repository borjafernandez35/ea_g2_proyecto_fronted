import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_seminario/Models/ActivityModel.dart';
import 'package:flutter_seminario/Screens/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:dio/dio.dart' ;
import 'dart:io';


class UserDetailsPage extends StatelessWidget {
  final Activity place;
  

const UserDetailsPage(this.place, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${place.name}'),
            Text('Content: ${place.description}'),
            //Text('Image: '),
            //Image.network(place.),
            // Add more user details here as needed
          ],
        ),
      ),
    );
  }
}