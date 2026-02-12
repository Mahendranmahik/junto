import '../../base/idto.dart';

class LoginDto implements IDto {
  final String email;
  final String password;

  LoginDto({
    required this.email,
    required this.password,
  });

  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  IDto fromJson(Map<String, dynamic> json) {
    return LoginDto.fromJson(json);
  }
}

