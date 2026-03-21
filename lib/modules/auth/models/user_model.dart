class UserModel {
  final String uid;
  final String email;
  final String name;
  final String photo;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photo = "",
    this.isOnline = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "photo": photo,
      "isOnline": isOnline,
      "createdAt": DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"],
      email: map["email"],
      name: map["name"],
      photo: map["photo"] ?? "",
      isOnline: map["isOnline"] ?? false,
    );
  }
}







