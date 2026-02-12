import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junto/modules/settings/controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value && controller.userName.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Stack(
                          children: [
                            Obx(
                              () => Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: controller.profilePictureUrl.isNotEmpty
                                      ? _buildImageFromBase64(
                                          controller.profilePictureUrl.value,
                                          context,
                                          controller.userName.value,
                                        )
                                      : _buildInitialAvatar(
                                          context,
                                          controller.userName.value,
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed: controller.showImageSourceDialog,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Text(
                            controller.userName.value,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Update Profile Picture',
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                            onTap: controller.showImageSourceDialog,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey[800],
                            indent: 16,
                            endIndent: 16,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Profile Information',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Obx(
                              () => Text(
                                controller.userName.value,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => controller.isLoading.value
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildImageFromBase64(
    String imageData,
    BuildContext context,
    String userName,
  ) {
    if (imageData.startsWith('data:image')) {
      final base64String = imageData.split(',')[1];
      final imageBytes = base64Decode(base64String);
      
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialAvatar(context, userName);
        },
      );
    } else {
      return Image.network(
        imageData,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialAvatar(context, userName);
        },
      );
    }
  }

  Widget _buildInitialAvatar(BuildContext context, String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";
    
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

