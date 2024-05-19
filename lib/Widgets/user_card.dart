import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Models/UserModel.dart';

class UserCard extends StatelessWidget {
  final String? name;
  const UserCard(this.name ,{super.key,});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          surfaceTintColor: Pallete.accentColor,
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Row(
            children: [
              // Left side: Image
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  'https://via.placeholder.com/100', // Replace with your image URL
                  fit: BoxFit.cover,
                ),
              ),
              // Right side: Title, Description, and Value
              const SizedBox(height: 8),
              Text(
                'Description: $name',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        // Add other widgets below if needed
      ],
    );
  }
}