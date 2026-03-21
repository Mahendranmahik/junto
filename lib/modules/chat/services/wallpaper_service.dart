import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class WallpaperService {
  static const String _wallpaperKey = 'chat_wallpaper_path';

  /// Save wallpaper path to SharedPreferences
  Future<bool> setWallpaper(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_wallpaperKey, imagePath);
    } catch (e) {
      return false;
    }
  }

  /// Get wallpaper path from SharedPreferences
  Future<String?> getWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_wallpaperKey);
    } catch (e) {
      return null;
    }
  }

  /// Remove wallpaper
  Future<bool> removeWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_wallpaperKey);
    } catch (e) {
      return false;
    }
  }

  /// Check if wallpaper exists and file is valid
  Future<bool> hasWallpaper() async {
    final path = await getWallpaper();
    if (path == null || path.isEmpty) return false;

    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}




