import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';

class LocalStorageService {
  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _sessionKey = 'shatter_user_session';
  static const String _privateKeyStoreKey = 'shatter_e2e_private_key';

  /// Save the user session locally. Non-sensitive data goes to SharedPreferences,
  /// and sensitive data like private key goes to secure storage.
  Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save general profile details as JSON in SharedPreferences
    final sessionMap = {
      'uid': session.uid,
      'email': session.email,
      'username': session.username,
      'displayName': session.displayName,
      'publicKey': session.publicKey,
    };
    await prefs.setString(_sessionKey, jsonEncode(sessionMap));

    // Save private key securely in secure storage
    if (session.privateKey != null) {
      await _secureStorage.write(key: _privateKeyStoreKey, value: session.privateKey);
    }
  }

  /// Retrieve the saved user session from local storage.
  Future<UserSession?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionKey);

    if (sessionJson == null) {
      return null;
    }

    try {
      final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
      
      // Read the private key from secure storage
      final privateKey = await _secureStorage.read(key: _privateKeyStoreKey);

      return UserSession(
        uid: sessionMap['uid'] as String,
        email: sessionMap['email'] as String,
        username: sessionMap['username'] as String,
        displayName: sessionMap['displayName'] as String,
        publicKey: sessionMap['publicKey'] as String?,
        privateKey: privateKey,
      );
    } catch (e) {
      print('Error parsing local session: $e');
      return null;
    }
  }

  /// Clear the local session (used during logout).
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await _secureStorage.delete(key: _privateKeyStoreKey);
  }

  /// Save a boolean setting (e.g. location shared, push notifications).
  Future<void> saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Get a boolean setting, with a fallback default value.
  Future<bool> getBoolSetting(String key, bool defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }
}
