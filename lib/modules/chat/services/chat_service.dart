import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/modules/chat/models/message_model.dart';
import 'package:junto/modules/chat/services/push_notification_service.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PushNotificationService _pushService = GetIt.instance<PushNotificationService>();

  Stream<QuerySnapshot> getUsers() {
    return _db.collection("users").snapshots();
  }

  String get myUid => _auth.currentUser!.uid;

  String _getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['name'] as String? ?? 'User';
      }
      return 'User';
    } catch (e) {
      return 'User';
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    try {
      final senderId = myUid;
      final chatRoomId = _getChatRoomId(senderId, receiverId);

      final messageData = {
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .add(messageData);

      await _db.collection('messages').doc(chatRoomId).set({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));

      try {
        final senderName = await getUserName(senderId);
        await _pushService.sendChatNotification(
          receiverId: receiverId,
          senderId: senderId,
          senderName: senderName,
          message: text,
        );
      } catch (e) {
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<MessageModel>> getMessages(String otherUserId) {
    try {
      final senderId = myUid;
      final chatRoomId = _getChatRoomId(senderId, otherUserId);

      return _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      final senderId = myUid;
      final chatRoomId = _getChatRoomId(senderId, otherUserId);

      final unreadMessages = await _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .where('receiverId', isEqualTo: senderId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }
}
