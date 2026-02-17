import 'package:get/get.dart';
import 'package:junto/modules/chat/models/message_model.dart';
import 'package:junto/modules/chat/services/chat_service.dart';
import 'package:junto/di/locator.dart';

class ChatController extends GetxController {
  final ChatService _chatService = getIt<ChatService>();

  // Observable list of messages
  var messages = <MessageModel>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Error message
  var errorMessage = ''.obs;

  // Other user's ID (passed when opening chat)
  String? otherUserId;

  @override
  void onInit() {
    super.onInit();
    // Get other user ID from arguments
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      otherUserId = arguments['uid'] as String?;
    }

    // If we have other user ID, start listening to messages
    if (otherUserId != null) {
      _loadMessages();
      _markMessagesAsRead();
    }
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }

  /// Load messages from Firestore (real-time stream)
  void _loadMessages() {
    if (otherUserId == null) return;

    try {
      // Listen to messages stream - updates automatically when new messages arrive
      _chatService.getMessages(otherUserId!).listen(
        (messageList) {
          // Update messages list when new messages arrive
          messages.value = messageList;
          errorMessage.value = '';
        },
        onError: (error) {
          errorMessage.value = 'Failed to load messages: $error';
          Get.snackbar('Error', errorMessage.value);
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to load messages: $e';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  /// Send a message
  Future<void> sendMessage(String text) async {
    if (otherUserId == null || text.trim().isEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Send message to Firestore
      await _chatService.sendMessage(
        receiverId: otherUserId!,
        text: text.trim(),
      );

      // Note: Messages will automatically update via the stream
      // No need to manually add to the list!
    } catch (e) {
      errorMessage.value = 'Failed to send message: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark messages as read when user opens chat
  Future<void> _markMessagesAsRead() async {
    if (otherUserId == null) return;

    try {
      await _chatService.markMessagesAsRead(otherUserId!);
    } catch (e) {
      // Silent fail - not critical if marking as read fails
      print('Failed to mark messages as read: $e');
    }
  }

  /// Check if message is sent by current user
  bool isSentByMe(MessageModel message) {
    return message.senderId == _chatService.myUid;
  }

  /// Get other user's name (if available from arguments)
  String get otherUserName {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      return arguments['name'] as String? ?? 'User';
    }
    return 'User';
  }

  /// Delete a message
  Future<void> deleteMessage({
    required String messageId,
    required bool deleteForEveryone,
  }) async {
    if (otherUserId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _chatService.deleteMessage(
        otherUserId: otherUserId!,
        messageId: messageId,
        deleteForEveryone: deleteForEveryone,
      );

      // Messages will automatically update via the stream
    } catch (e) {
      errorMessage.value = 'Failed to delete message: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if message is deleted for current user
  bool isMessageDeletedForMe(MessageModel message) {
    return _chatService.isMessageDeletedForMe(message, _chatService.myUid);
  }

  /// Permanently delete a message from database
  Future<void> permanentlyDeleteMessage(String messageId) async {
    if (otherUserId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _chatService.permanentlyDeleteMessage(
        otherUserId: otherUserId!,
        messageId: messageId,
      );

      // Messages will automatically update via the stream
    } catch (e) {
      errorMessage.value = 'Failed to permanently delete message: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}



