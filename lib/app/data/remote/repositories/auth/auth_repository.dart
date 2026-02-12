import '../../base/status.dart';
import '../../dto/auth/login_dto.dart';
import '../../dto/auth/auth_response_dto.dart';
import '../../services/auth/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  /// Login user
  Future<Result<AuthResponseDto>> login(String email, String password) async {
    final loginDto = LoginDto(email: email, password: password);
    return await _authService.login(loginDto);
  }

  /// Register user
  Future<Result<AuthResponseDto>> register(String email, String password) async {
    final registerDto = LoginDto(email: email, password: password);
    return await _authService.register(registerDto);
  }
}


