// ignore: file_names
class User {
  final String name;
  final String email;
  final String phone_number;
  final String gender;
  final bool active;
  final String password;
  

  User({
    required this.name,
    required this.email,
    required this.phone_number,
    required this.gender,
    required this.active,
    required this.password,
    
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phone_number,
      'gender': gender,
      'active': active,
      'password': password,
      
    };
  }
}
