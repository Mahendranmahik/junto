import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:junto/modules/settings/services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = SettingsService();

  var isLoading = false.obs;
  var userName = ''.obs;
  var profilePictureUrl = ''.obs;
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      
      final userData = await _settingsService.getCurrentUserData();
      
      if (userData != null) {
        userName.value = userData['name'] ?? '';
        profilePictureUrl.value = userData['photo'] ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await _uploadAndUpdateProfilePicture();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await _uploadAndUpdateProfilePicture();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }

  Future<void> _uploadAndUpdateProfilePicture() async {
    if (selectedImage.value == null) return;

    try {
      isLoading.value = true;
      
      final imageUrl = await _settingsService.uploadProfilePicture(
        selectedImage.value!,
      );
      
      await _settingsService.updateProfilePicture(imageUrl);
      
      profilePictureUrl.value = imageUrl;
      
      Get.snackbar('Success', 'Profile picture updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile picture: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Select Image Source',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Camera',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

