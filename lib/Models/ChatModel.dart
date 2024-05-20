class Message {
  String message;
  String sentByMe;
  String userName;
 

  Message({required this.message, required this.sentByMe, required this.userName });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(message: json["message"], sentByMe: json["sentByMe"], userName: json["userName"]);
  }
}
