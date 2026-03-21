class ChatUserModel {
  final String uid;
  final String name;
  final String email;
  final bool isOnline;

  ChatUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isOnline,
  });

  factory ChatUserModel.fromMap(Map<String, dynamic> map) {
    return ChatUserModel(
      uid: map["uid"],
      name: map["name"],
      email: map["email"],
      isOnline: map["isOnline"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "isOnline": isOnline,
    };
  }
}







