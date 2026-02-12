import '../../base/idto.dart';

class AuthResponseDto implements IDto {
  final String token;
  final String refreshToken;
  final Map<String, dynamic> user;

  AuthResponseDto({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: json['user'] as Map<String, dynamic>,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user,
    };
  }

  @override
  IDto fromJson(Map<String, dynamic> json) {
    return AuthResponseDto.fromJson(json);
  }
}

