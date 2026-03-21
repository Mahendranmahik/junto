import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:junto/core/routes/app_routes.dart';
import 'package:junto/modules/auth/services/auth_service.dart';
import 'package:junto/modules/chat/services/push_notification_service.dart';
import 'package:junto/di/locator.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: const <String>['email', 'profile'],
);

class AuthController extends GetxController {
  final AuthService authService = getIt<AuthService>();
  final PushNotificationService pushService = getIt<PushNotificationService>();

  var firebaseUser = Rxn<User>();
  var isLoading = false.obs;

  StreamSubscription<User?>? _authStateSub;

  @override
  void onInit() {
    firebaseUser.value = authService.currentUser;
    _authStateSub = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
    super.onInit();
  }

  @override
  void onClose() {
    _authStateSub?.cancel();
    super.onClose();
  }

  void _onAuthStateChanged(User? user) {
    firebaseUser.value = user;
    if (user == null) return;

    final route = Get.currentRoute;
    if (route == Routes.HOME ||
        route == Routes.CHAT ||
        route == Routes.SETTINGS) {
      return;
    }
    if (route == Routes.SPLASH) {
      return;
    }

    scheduleMicrotask(() {
      if (FirebaseAuth.instance.currentUser == null) return;
      if (Get.currentRoute == Routes.HOME) return;
      Get.offAllNamed(Routes.HOME);
    });
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
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        Get.snackbar(
          'Google Sign-In',
          'No credentials from Google. Add your app SHA-1 in Firebase, enable Google sign-in, '
              'and replace google-services.json so oauth clients are present.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential cred = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = cred.user;
      if (user == null) {
        Get.snackbar('Google Sign-In', 'No Firebase user after sign-in.');
        return;
      }

      await authService.ensureUserDocumentForOAuthUser(user);

      firebaseUser.value = user;
      await _saveFcmToken();
      await _sendWelcomeNotification();
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Google Sign-In',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PlatformException catch (e) {
      final msg = e.message ?? '';

      Get.snackbar(
        'Google Sign-In',
        '${e.code}: $msg',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    } on FirebaseException catch (e) {
      Get.snackbar(
        'Google Sign-In',
        '${e.code}: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Google Sign-In',
        '${e.runtimeType}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await authService.logout();
    firebaseUser.value = null;
    Get.offAllNamed("/login");
  }
}
