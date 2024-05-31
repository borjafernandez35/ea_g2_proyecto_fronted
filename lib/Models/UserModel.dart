
class User {
  final String? id;
  final String name;
  final String email;
  final String phone_number;
  final String gender;
  final String? birthday;
  final List<String>? activities;
  final List<String>? listActivities;
  final List<String>? comments;
  final bool? active;
  final String password;
  final LatLng? position;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone_number,
    required this.gender,
    this.active,
    required this.password,
    this.birthday,
    this.activities,
    this.listActivities,
    this.comments,
    this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phone_number,
      'gender': gender,
      'active': active,
      'password': password,
      'birthday': birthday,
      'position': position?.toJson(),
    };
  }


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone_number: json['phone_number'],
      gender: json['gender'],
      active: json['active'],
      password: json['password'],
      birthday: json['birthday'],
      activities: (json['Activities'] as List<dynamic>?)?.cast<String>(),
      listActivities: (json['listActivities'] as List<dynamic>?)?.cast<String>(),
      comments: (json['comments'] as List<dynamic>?)?.cast<String>(),
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
