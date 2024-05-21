
class Activity {
  final String? id;
  final String name;
  final String description;
  final double? rate;
  final String idUser;
  final DateTime date; // Cambiado el tipo de dato a DateTime
  final List<String>? listUsers;
  final List<String>? comments;
  final String? imageUrl; // Asegurado que imageUrl sea de tipo String

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
  });

    Map<String, dynamic> toJson() {
    return {
      'owner': idUser,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      rate: json['rate'],
      idUser: json['owner'],
      date: DateTime.parse(json['date']), // Parsear la fecha desde String a DateTime
      listUsers: (json['listUsers'] as List<dynamic>?)?.cast<String>(),
      comments: (json['comments'] as List<dynamic>?)?.cast<String>(),
      imageUrl: json['image'], // Asignar imageUrl desde JSON si está disponible
    );
  }
}
