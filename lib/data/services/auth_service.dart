// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = "auth_token";
  static const String _profileCompletedKey = "profile_completed";

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Save profile completion status
  static Future<void> setProfileCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileCompletedKey, completed);
  }

  // Check profile completed
  static Future<bool> isProfileCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileCompletedKey) ?? false;
  }
}
