import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUsers() {
    return _db.collection("users").snapshots();
  }

  String get myUid => _auth.currentUser!.uid;

  String _getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<String?> getLastMessage(String otherUserId) async {
    try {
      final chatRoomId = _getChatRoomId(myUid, otherUserId);
      
      final messagesSnapshot = await _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messagesSnapshot.docs.isNotEmpty) {
        final lastMessage = messagesSnapshot.docs.first.data();
        return lastMessage['text'] as String?;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<String?> getLastMessageStream(String otherUserId) {
    try {
      final chatRoomId = _getChatRoomId(myUid, otherUserId);
      
      return _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final lastMessage = snapshot.docs.first.data();
          return lastMessage['text'] as String?;
        }
        return null;
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  Stream<int> getUnreadCountStream(String otherUserId) {
    try {
      final chatRoomId = _getChatRoomId(myUid, otherUserId);
      
      return _db
          .collection('messages')
          .doc(chatRoomId)
          .collection('chats')
          .where('receiverId', isEqualTo: myUid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      return Stream.value(0);
    }
  }
}



