import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:junto/modules/auth/services/auth_service.dart';
import 'package:junto/modules/chat/services/push_notification_service.dart';
import 'package:junto/di/locator.dart';

class AuthController extends GetxController {
  final AuthService authService = getIt<AuthService>();
  final PushNotificationService pushService = getIt<PushNotificationService>();

  var firebaseUser = Rxn<User>();
  var isLoading = false.obs;

  @override
  void onInit() {
    firebaseUser.value = authService.currentUser;
    super.onInit();
  }

  Future<void> _saveFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && authService.currentUser != null) {
        await authService.saveFcmToken(fcmToken);
      }
    } catch (e) {}
  }

  Future<void> _sendWelcomeNotification() async {
    try {
      final userId = authService.currentUser?.uid;
      if (userId != null) {
        await Future.delayed(const Duration(seconds: 1));
        await pushService.sendWelcomeNotification(userId);
      }
    } catch (e) {}
  }

  Future<void> register(String email, String pass, String name) async {
    try {
      isLoading.value = true;
      await authService.register(email, pass, name);
      await _saveFcmToken();
      await _sendWelcomeNotification();
      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      firebaseUser.value = await authService.login(email, password);
      await _saveFcmToken();
      await _sendWelcomeNotification();
      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    firebaseUser.value = null;
    Get.offAllNamed("/login");
  }
}
