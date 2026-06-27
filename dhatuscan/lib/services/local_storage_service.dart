import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyAuthToken = 'authToken';
  static const String _keyUserId = 'userId';
  static const String _keyUserData = 'userData';
  static const String _keyAssessmentProgress = 'assessmentProgress';
  static const String _keyVKAnswers = 'vkAnswers';
  static const String _keySarataAnswers = 'sarataAnswers';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Inject a [SharedPreferences] instance directly — used in tests.
  @visibleForTesting
  static void initWithPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }

  static SharedPreferences get _instance {
    if (_prefs == null) throw Exception('LocalStorageService not initialized');
    return _prefs!;
  }

  // Auth methods
  static Future<void> setLoggedIn(bool value) async {
    await _instance.setBool(_keyIsLoggedIn, value);
  }

  static bool get isLoggedIn => _instance.getBool(_keyIsLoggedIn) ?? false;

  static Future<void> setAuthToken(String token) async {
    await _instance.setString(_keyAuthToken, token);
  }

  static String? get authToken => _instance.getString(_keyAuthToken);

  static Future<void> setUserId(String id) async {
    await _instance.setString(_keyUserId, id);
  }

  static String? get userId => _instance.getString(_keyUserId);

  // User data
  static Future<void> setUserData(Map<String, dynamic> data) async {
    await _instance.setString(_keyUserData, jsonEncode(data));
  }

  static Map<String, dynamic>? get userData {
    final str = _instance.getString(_keyUserData);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  // Assessment progress persistence
  static Future<void> saveVKAnswers(Map<String, dynamic> answers) async {
    await _instance.setString(_keyVKAnswers, jsonEncode(answers));
  }

  static Map<String, dynamic>? get savedVKAnswers {
    final str = _instance.getString(_keyVKAnswers);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  static Future<void> saveSarataAnswers(Map<String, dynamic> answers) async {
    await _instance.setString(_keySarataAnswers, jsonEncode(answers));
  }

  static Map<String, dynamic>? get savedSarataAnswers {
    final str = _instance.getString(_keySarataAnswers);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  static Future<void> clearAssessmentProgress() async {
    await _instance.remove(_keyVKAnswers);
    await _instance.remove(_keySarataAnswers);
    await _instance.remove(_keyAssessmentProgress);
  }

  // Clear all on logout
  static Future<void> clearAll() async {
    await _instance.clear();
  }

  static Future<void> logout() async {
    await _instance.remove(_keyIsLoggedIn);
    await _instance.remove(_keyAuthToken);
    await _instance.remove(_keyUserId);
    await _instance.remove(_keyUserData);
    await clearAssessmentProgress();
  }
}
