import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junto/modules/chat/models/message_model.dart';
import 'package:junto/modules/chat/services/chat_service.dart';
import 'package:junto/modules/chat/services/wallpaper_service.dart';
import 'package:junto/app/core/values/colors.dart';
import 'package:junto/di/locator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatController extends GetxController {
  final ChatService _chatService = getIt<ChatService>();
  final WallpaperService _wallpaperService = WallpaperService();

  // Observable list of messages
  var messages = <MessageModel>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Error message
  var errorMessage = ''.obs;

  // Wallpaper path
  var wallpaperPath = Rxn<String>();

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

    // Load wallpaper
    _loadWallpaper();

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

  /// Load wallpaper from storage
  Future<void> _loadWallpaper() async {
    try {
      final path = await _wallpaperService.getWallpaper();
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          wallpaperPath.value = path;
        } else {
          wallpaperPath.value = null;
        }
      } else {
        wallpaperPath.value = null;
      }
    } catch (e) {
      wallpaperPath.value = null;
    }
  }

  /// Pick image from gallery and set as wallpaper
  Future<void> pickWallpaperFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _setWallpaper(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  /// Pick image from camera and set as wallpaper
  Future<void> pickWallpaperFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        await _setWallpaper(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }

  /// Set wallpaper from file path
  Future<void> _setWallpaper(String imagePath) async {
    try {
      final success = await _wallpaperService.setWallpaper(imagePath);
      if (success) {
        wallpaperPath.value = imagePath;
        Get.snackbar(
          'Success',
          'Wallpaper set successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar('Error', 'Failed to save wallpaper');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to set wallpaper: $e');
    }
  }

  /// Remove wallpaper
  Future<void> removeWallpaper() async {
    try {
      final success = await _wallpaperService.removeWallpaper();
      if (success) {
        wallpaperPath.value = null;
        Get.snackbar(
          'Success',
          'Wallpaper removed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar('Error', 'Failed to remove wallpaper');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove wallpaper: $e');
    }
  }

  /// Show wallpaper options dialog
  void showWallpaperOptions() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.cardBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chat Wallpaper',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.white),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  pickWallpaperFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  pickWallpaperFromCamera();
                },
              ),
              if (wallpaperPath.value != null) ...[
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text(
                    'Remove Wallpaper',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Get.back();
                    removeWallpaper();
                  },
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



