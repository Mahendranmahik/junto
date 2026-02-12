import 'package:shared_preferences/shared_preferences.dart';
import '../base/iservice.dart';

class StorageService implements IService {
  static SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear() async {
    await _prefs?.clear();
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Remove
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
}


