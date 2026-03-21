import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:junto/modules/chat/controllers/chat_controller.dart';
import 'package:junto/modules/chat/models/message_model.dart';
import 'package:junto/app/core/values/colors.dart';
import 'dart:io';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final controller = Get.find<ChatController>();
  final textCtrl = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-scroll to bottom when messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    scrollController.dispose();
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.cardBackgroundDark,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryGradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  controller.otherUserName.isNotEmpty
                      ? controller.otherUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.otherUserName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper),
            color: Colors.white,
            onPressed: () => controller.showWallpaperOptions(),
            tooltip: 'Set Wallpaper',
          ),
        ],
      ),
      body: Obx(() {
        // Get wallpaper path
        final wallpaperPath = controller.wallpaperPath.value;
        
        return Stack(
          children: [
            // Wallpaper background
            if (wallpaperPath != null)
              Positioned.fill(
                child: Image.file(
                  File(wallpaperPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.scaffoldBackgroundDark);
                  },
                ),
              )
            else
              Container(color: AppColors.scaffoldBackgroundDark),
            
            // Semi-transparent overlay for better readability
            if (wallpaperPath != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            
            // Content
            Column(
              children: [
                // Messages List
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.messages.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (controller.errorMessage.value.isNotEmpty &&
                        controller.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.errorMessage.value,
                              style: TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (controller.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackgroundDark,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final reversedMessages = controller.messages.reversed.toList();

                    return ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: reversedMessages.length,
                      itemBuilder: (context, index) {
                        final message = reversedMessages[index];
                        final isSentByMe = controller.isSentByMe(message);
                        final isDeleted = controller.isMessageDeletedForMe(message);
                        return _buildMessageBubble(context, message, isSentByMe, isDeleted);
                      },
                    );
                  }),
                ),

                // Input Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundDark,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: textCtrl,
                              focusNode: focusNode,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: TextStyle(color: AppColors.textTertiaryDark),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryGradientEnd,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: controller.isLoading.value ? null : _sendMessage,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(12),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// Build a message bubble widget
  Widget _buildMessageBubble(
    BuildContext context,
    MessageModel message,
    bool isSentByMe,
    bool isDeleted,
  ) {
    return GestureDetector(
      onLongPress: () {
        _showMessageOptions(context, message, isSentByMe);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSentByMe) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryGradientEnd],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    controller.otherUserName.isNotEmpty
                        ? controller.otherUserName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSentByMe && !isDeleted
                      ? const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isDeleted
                      ? AppColors.surfaceDark
                      : isSentByMe
                          ? null
                          : AppColors.receivedMessageBg,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isSentByMe ? 20 : 4),
                    bottomRight: Radius.circular(isSentByMe ? 4 : 20),
                  ),
                  boxShadow: isSentByMe && !isDeleted
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                  border: isDeleted
                      ? Border.all(
                          color: AppColors.textTertiaryDark.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDeleted ? 'This message was deleted' : message.text,
                      style: TextStyle(
                        color: isDeleted
                            ? AppColors.textTertiaryDark
                            : Colors.white,
                        fontSize: 15,
                        height: 1.4,
                        fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: TextStyle(
                            color: isDeleted
                                ? AppColors.textTertiaryDark
                                : isSentByMe
                                    ? Colors.white70
                                    : AppColors.textTertiaryDark,
                            fontSize: 11,
                          ),
                        ),
                        if (isSentByMe && !isDeleted) ...[
                          const SizedBox(width: 6),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 16,
                            color: message.isRead
                                ? Colors.blue[200]
                                : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isSentByMe) ...[
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    FirebaseAuth.instance.currentUser?.displayName?.isNotEmpty == true
                        ? FirebaseAuth.instance.currentUser!.displayName![0].toUpperCase()
                        : FirebaseAuth.instance.currentUser?.email?.isNotEmpty == true
                            ? FirebaseAuth.instance.currentUser!.email![0].toUpperCase()
                            : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show message options menu on long press
  void _showMessageOptions(
    BuildContext context,
    MessageModel message,
    bool isSentByMe,
  ) {
    final isDeleted = controller.isMessageDeletedForMe(message);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (isDeleted) ...[
                // Options for already deleted messages
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text(
                    'Remove from chat',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Permanently delete this message',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showPermanentDeleteConfirmation(context, message);
                  },
                ),
              ] else ...[
                // Options for normal messages
                if (isSentByMe) ...[
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text(
                      'Delete for me',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, message, false);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: AppColors.error),
                    title: const Text(
                      'Delete for everyone',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, message, true);
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, message, false);
                    },
                  ),
                ],
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(
    BuildContext context,
    MessageModel message,
    bool deleteForEveryone,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Message',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          deleteForEveryone
              ? 'Are you sure you want to delete this message for everyone? This action cannot be undone.'
              : 'Are you sure you want to delete this message?',
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMessage(
                messageId: message.id,
                deleteForEveryone: deleteForEveryone,
              );
              Get.snackbar(
                'Success',
                deleteForEveryone
                    ? 'Message deleted for everyone'
                    : 'Message deleted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.cardBackgroundDark,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Show permanent delete confirmation dialog
  void _showPermanentDeleteConfirmation(
    BuildContext context,
    MessageModel message,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Remove Message',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'This will permanently remove this message from the chat. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.permanentlyDeleteMessage(message.id);
              Get.snackbar(
                'Success',
                'Message removed from chat',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.cardBackgroundDark,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    String formatTime(DateTime time) {
      final hour = time.hour == 0
          ? 12
          : (time.hour > 12 ? time.hour - 12 : time.hour);
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }

    if (difference.inDays == 0) {
      return formatTime(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${formatTime(timestamp)}';
    } else if (difference.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[timestamp.weekday - 1]} ${formatTime(timestamp)}';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${formatTime(timestamp)}';
    }
  }

  /// Send message handler
  void _sendMessage() {
    if (textCtrl.text.trim().isNotEmpty) {
      controller.sendMessage(textCtrl.text.trim());
      textCtrl.clear();
      // Auto-scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
}
