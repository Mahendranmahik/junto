import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:junto/modules/chat/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUsers() {
    return _db.collection("users").snapshots();
  }

  String get myUid => _auth.currentUser!.uid;

  /// Generate a unique chat room ID from two user IDs
  /// This ensures both users see the same chat room
  String _getChatRoomId(String userId1, String userId2) {
    // Sort IDs alphabetically to ensure same room ID regardless of order
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Send a message to Firestore
  /// This stores the message in the 'messages' collection
  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    try {
      final senderId = myUid;
      final chatRoomId = _getChatRoomId(senderId, receiverId);

      // Create message data
      final messageData = {
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      // Add message to Firestore
      await _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .add(messageData);

      // Update the chat room's last message timestamp
      await _db.collection('messages').doc(chatRoomId).set({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get real-time stream of messages for a conversation
  /// This listens to Firestore and updates automatically when new messages arrive
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    try {
      final senderId = myUid;
      final chatRoomId = _getChatRoomId(senderId, otherUserId);

      // Return stream of messages, ordered by timestamp
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

  /// Mark messages as read
  Future<void> markMessagesAsRead(String otherUserId) async {
    try {
      final senderId = myUid;
      final chatRoomId = _getChatRoomId(senderId, otherUserId);

      // Get all unread messages sent to current user
      final unreadMessages = await _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .where('receiverId', isEqualTo: senderId)
          .where('isRead', isEqualTo: false)
          .get();

      // Update each message to mark as read
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
