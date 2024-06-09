import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Models/ActivityModel.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  const ActivityCard(
    this.activity, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Pallete.primaryColor,
          surfaceTintColor: Pallete.accentColor,
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Row(
            children: [
              // Lado izquierdo: Imagen
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  'https://via.placeholder.com/100', // Reemplaza con la URL de tu imagen
                  fit: BoxFit.cover,
                ),
              ),
              // Lado derecho: Título, Descripción y Valor
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description: ${activity.description}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rate: ${activity.rate.toString()}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
