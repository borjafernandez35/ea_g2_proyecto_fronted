import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';


class UserDetailsPage extends StatelessWidget {
  final Activity place;
  

const UserDetailsPage(this.place, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${place.name}'),
            Text('Content: ${place.description}'),
          ],
        ),
      ),
    );
  }
}