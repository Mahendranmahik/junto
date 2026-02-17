import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final bool isDeleted;
  final List<String> deletedFor; // List of user IDs who deleted this message

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.isDeleted = false,
    this.deletedFor = const [],
  });

  // Convert Firestore document to MessageModel
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      deletedFor: List<String>.from(data['deletedFor'] ?? []),
    );
  }

  // Convert MessageModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'isDeleted': isDeleted,
      'deletedFor': deletedFor,
    };
  }

  // Helper method to check if message is sent by current user
  bool isSentBy(String userId) {
    return senderId == userId;
  }
}
