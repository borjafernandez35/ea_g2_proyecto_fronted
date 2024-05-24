import 'package:latlong2/latlong.dart';

class Activity {
  final String? id;
  final String name;
  final String description;
  final double? rate;
  final String idUser;
  final DateTime date; 
  final List<String>? listUsers;
  final List<String>? comments;
  final String? imageUrl;
  final LatLng? position; // Nuevo campo para la posición

  Activity({
    this.id,
    required this.name,
    required this.description,
    this.rate,
    required this.idUser,
    required this.date,
    this.listUsers,
    this.comments,
    this.imageUrl,
    this.position, // Incluido el argumento para la posición
  });

  Map<String, dynamic> toJson() {
    return {
      'owner': idUser,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'position': position?.toJson(), // Convertir la posición a JSON si está disponible
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      rate: json['rate'],
      idUser: json['owner'],
      date: DateTime.parse(json['date']),
      listUsers: (json['listUsers'] as List<dynamic>?)?.cast<String>(),
      comments: (json['comments'] as List<dynamic>?)?.cast<String>(),
      imageUrl: json['image'],
      position: json['position'] != null
          ? LatLng.fromJson(json['position']) // Convertir la posición desde JSON
          : null,
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
