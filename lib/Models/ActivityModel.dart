class Activity {
   final String name;
  final String description;
  final String idUser;
  final DateTime date;
  final bool active;
    

  Activity({
    required this.name,
    required this.description,
    required this.idUser,
    required this.date,
    required this.active,
   
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'],
      description: json['description'],
      idUser: json['idUser'],
      date: json['date'],
      active: json['active'],
     
    );
  }
}
