import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  final Dio _dio = Dio();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _pushServerUrl =
      'https://push-server-bv0y.onrender.com/sendPush';

  /// Get FCM token for a user from Firestore
  Future<String?> getUserFcmToken(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Send push notification to a user
  Future<bool> sendPushNotification({
    required String receiverId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final fcmToken = await getUserFcmToken(receiverId);

      if (fcmToken == null || fcmToken.isEmpty) {
        return false;
      }

      final payload = {
        'token': fcmToken,
        'title': title,
        'body': body,
        if (data != null) 'data': data,
      };

      final response = await _dio.post(
        _pushServerUrl,
        data: payload,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Send push notification for a chat message
  Future<bool> sendChatNotification({
    required String receiverId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    return await sendPushNotification(
      receiverId: receiverId,
      title: senderName,
      body: message,
      data: {'type': 'chat', 'senderId': senderId, 'receiverId': receiverId},
    );
  }

  /// Send welcome notification to user
  Future<bool> sendWelcomeNotification(String userId) async {
    return await sendPushNotification(
      receiverId: userId,
      title: 'Welcome to Junto!',
      body: 'Welcome to Junto',
      data: {'type': 'welcome'},
    );
  }
}
