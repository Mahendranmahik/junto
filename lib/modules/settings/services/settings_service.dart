import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get myUid => _auth.currentUser!.uid;

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final doc = await _db.collection("users").doc(myUid).get();
      
      if (doc.exists) {
        return doc.data();
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      
      final decodedImage = img.decodeImage(imageBytes);
      
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }
      
      final resizedImage = img.copyResize(
        decodedImage,
        width: 200,
        height: 200,
        interpolation: img.Interpolation.linear,
      );
      
      final resizedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      final base64String = base64Encode(resizedBytes);
      
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to process profile picture: $e');
    }
  }

  Future<void> updateProfilePicture(String imageData) async {
    try {
      await _db.collection("users").doc(myUid).update({
        "photo": imageData,
      });
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  Future<void> updateUserName(String name) async {
    try {
      await _db.collection("users").doc(myUid).update({
        "name": name,
      });
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }
}

