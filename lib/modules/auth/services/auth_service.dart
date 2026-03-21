import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> register(String email, String password, String name) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      await _db.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": email,
        "name": name,
        "photo": "",
        "isOnline": true,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Creates `users/{uid}` when missing (e.g. first Google sign-in).
  Future<void> ensureUserDocumentForOAuthUser(User user) async {
    final ref = _db.collection("users").doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : (user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'User');

    await ref.set({
      "uid": user.uid,
      "email": user.email ?? "",
      "name": name,
      "photo": user.photoURL ?? "",
      "isOnline": true,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<void> saveFcmToken(String fcmToken) async {
    final user = currentUser;
    if (user != null) {
      try {
        await _db.collection("users").doc(user.uid).update({
          "fcmToken": fcmToken,
        });
      } catch (e) {}
    }
  }
}
