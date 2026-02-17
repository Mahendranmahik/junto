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

  /// Delete a message
  /// deleteForEveryone: if true, deletes for both users; if false, only for current user
  Future<void> deleteMessage({
    required String otherUserId,
    required String messageId,
    required bool deleteForEveryone,
  }) async {
    try {
      final currentUserId = myUid;
      final chatRoomId = _getChatRoomId(currentUserId, otherUserId);
      final messageRef = _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .doc(messageId);

      if (deleteForEveryone) {
        // Delete for everyone - mark as deleted
        await messageRef.update({
          'isDeleted': true,
          'text': 'This message was deleted',
          'deletedFor': FieldValue.arrayUnion([currentUserId, otherUserId]),
        });
      } else {
        // Delete only for current user
        final messageDoc = await messageRef.get();
        if (messageDoc.exists) {
          final currentDeletedFor = List<String>.from(
            messageDoc.data()?['deletedFor'] ?? [],
          );
          
          if (!currentDeletedFor.contains(currentUserId)) {
            currentDeletedFor.add(currentUserId);
          }

          await messageRef.update({
            'deletedFor': currentDeletedFor,
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// Check if message is deleted for current user
  bool isMessageDeletedForMe(MessageModel message, String currentUserId) {
    return message.deletedFor.contains(currentUserId);
  }

  /// Permanently delete a message from database
  Future<void> permanentlyDeleteMessage({
    required String otherUserId,
    required String messageId,
  }) async {
    try {
      final currentUserId = myUid;
      final chatRoomId = _getChatRoomId(currentUserId, otherUserId);
      final messageRef = _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .doc(messageId);

      // Permanently delete the message document
      await messageRef.delete();

      // Update last message in chat room if this was the last message
      final remainingMessages = await _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (remainingMessages.docs.isNotEmpty) {
        final lastMsg = remainingMessages.docs.first.data();
        await _db.collection('messages').doc(chatRoomId).set({
          'lastMessage': lastMsg['text'] ?? '',
          'lastMessageTime': lastMsg['timestamp'],
          'participants': [currentUserId, otherUserId],
        }, SetOptions(merge: true));
      } else {
        // No messages left, update chat room
        await _db.collection('messages').doc(chatRoomId).set({
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'participants': [currentUserId, otherUserId],
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to permanently delete message: $e');
    }
  }
}
