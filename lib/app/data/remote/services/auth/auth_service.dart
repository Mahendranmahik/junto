import '../../api/dio_client.dart';
import '../../api/api_routes.dart';
import '../../base/status.dart';
import '../../exceptions/dio_exceptions.dart';
import '../../dto/auth/login_dto.dart';
import '../../dto/auth/auth_response_dto.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  /// Login user
  Future<Result<AuthResponseDto>> login(LoginDto loginDto) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.login,
        data: loginDto.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponseDto.fromJson(response.data);
        return Result.success(authResponse);
      } else {
        return Result.failure('Login failed');
      }
    } on DioExceptions catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Unexpected error occurred');
    }
  }

  /// Register user
  Future<Result<AuthResponseDto>> register(LoginDto registerDto) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.register,
        data: registerDto.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponseDto.fromJson(response.data);
        return Result.success(authResponse);
      } else {
        return Result.failure('Registration failed');
      }
    } on DioExceptions catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Unexpected error occurred');
    }
  }
}


