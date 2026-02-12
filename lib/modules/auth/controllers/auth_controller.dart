import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:junto/modules/auth/services/auth_service.dart';
import 'package:junto/di/locator.dart';

class AuthController extends GetxController {
  final AuthService authService = getIt<AuthService>();

  var firebaseUser = Rxn<User>();
  var isLoading = false.obs;

  @override
  void onInit() {
    firebaseUser.value = authService.currentUser;
    super.onInit();
  }

  // REGISTER
  Future<void> register(String email, String pass, String name) async {
    try {
      isLoading.value = true;
      await authService.register(email, pass, name);
      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // LOGIN
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      firebaseUser.value = await authService.login(email, password);
      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await authService.logout();
    firebaseUser.value = null;
    Get.offAllNamed("/login");
  }
}



