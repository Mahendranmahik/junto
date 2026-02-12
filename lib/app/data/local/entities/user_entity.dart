import '../base/i_entity.dart';

class UserEntity implements IEntity {
  final String id;
  final String email;
  final String? name;
  final String? phone;

  UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
    };
  }

  @override
  IEntity fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}


