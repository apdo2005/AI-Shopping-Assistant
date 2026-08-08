import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeys {
  static const String token = 'token';
  static const String name = 'name';
  static const String userId = 'userid';
  static const String tempUserId = 'temp_user_id';
  static const String onboardingComplete = 'onboarding_complete';
}

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<void> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<void> setDouble(String key, double value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<void> setStringList(String key, List<String> value) async {

    String jsonString = jsonEncode(value);
    await _storage.write(key: key, value: jsonString);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  Future<bool?> getBool(String key) async {
    String? value = await _storage.read(key: key);
    return value == null ? null : value == 'true';
  }

  Future<int?> getInt(String key) async {
    String? value = await _storage.read(key: key);
    return value == null ? null : int.tryParse(value);
  }

  Future<double?> getDouble(String key) async {
    String? value = await _storage.read(key: key);
    return value == null ? null : double.tryParse(value);
  }

  Future<List<String>?> getStringList(String key) async {
    String? value = await _storage.read(key: key);
    if (value == null) return null;
    try {
      List<dynamic> jsonList = jsonDecode(value);
      return jsonList.cast<String>();
    } catch (e) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}

class AuthStorage {
  static final AuthStorage _instance = AuthStorage._internal();
  factory AuthStorage() => _instance;
  AuthStorage._internal();

  final SecureStorage security = SecureStorage();

  String? token;
  String? userId;
  bool? isOnboardingComplete;

  Future<void> init() async {
    token = await security.getString(SecureKeys.token);
    userId = await security.getString(SecureKeys.userId);
    isOnboardingComplete = await security.getBool(SecureKeys.onboardingComplete);
  }
}