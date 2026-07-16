// auth_storage.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static final Map<String, String> _memoryUsers = {};
  static String? _lastUsername;
  static String? _lastPassword;

  static Future<void> saveUser({
    required String name,
    required String username,
    required String password,
    required double age,
    required String country,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedPassword = password.trim();

    _memoryUsers[normalizedUsername.toLowerCase()] = normalizedPassword;
    _lastUsername = normalizedUsername;
    _lastPassword = normalizedPassword;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registeredUsername', normalizedUsername);
    await prefs.setString('registeredPassword', normalizedPassword);
    await prefs.setString('lastRegisteredUsername', normalizedUsername);
    await prefs.setString('lastRegisteredPassword', normalizedPassword);
    await prefs.setString('username', normalizedUsername);
    await prefs.setString('password', normalizedPassword);
    await prefs.setString('name', name);
    await prefs.setDouble('age', age);
    await prefs.setString('country', country);
    await prefs.setString(
      'currentUser',
      jsonEncode({
        'name': name,
        'username': normalizedUsername,
        'password': normalizedPassword,
        'age': age,
        'country': country,
      }),
    );
  }

  static Future<Map<String, String?>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final storedUsername = prefs.getString('registeredUsername') ??
        prefs.getString('lastRegisteredUsername') ??
        prefs.getString('username') ??
        _lastUsername;
    final storedPassword = prefs.getString('registeredPassword') ??
        prefs.getString('lastRegisteredPassword') ??
        prefs.getString('password') ??
        _memoryUsers[storedUsername?.toLowerCase() ?? ''];

    return {
      'username': storedUsername,
      'password': storedPassword,
    };
  }
}
