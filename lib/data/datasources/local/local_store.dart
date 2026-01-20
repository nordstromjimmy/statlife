import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  /// Get the storage key prefix based on user context
  /// - Guest: uses 'guest_' prefix
  /// - Authenticated: uses 'user_{userId}_' prefix
  String _getKey(String baseKey, {String? userId}) {
    if (userId != null && userId.isNotEmpty) {
      return 'user_${userId}_$baseKey';
    }
    return 'guest_$baseKey';
  }

  Future<void> writeJson(String key, Object value, {String? userId}) async {
    final storageKey = _getKey(key, userId: userId);
    final str = jsonEncode(value);
    await _prefs.setString(storageKey, str);
  }

  Map<String, dynamic>? readJsonMap(String key, {String? userId}) {
    final storageKey = _getKey(key, userId: userId);
    final str = _prefs.getString(storageKey);
    if (str == null) return null;
    final decoded = jsonDecode(str);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  List<dynamic>? readJsonList(String key, {String? userId}) {
    final storageKey = _getKey(key, userId: userId);
    final str = _prefs.getString(storageKey);
    if (str == null) return null;
    final decoded = jsonDecode(str);
    return decoded is List<dynamic> ? decoded : null;
  }

  Future<void> remove(String key, {String? userId}) {
    final storageKey = _getKey(key, userId: userId);
    return _prefs.remove(storageKey);
  }

  /// Clear all guest data (useful when logging in for the first time)
  Future<void> clearGuestData() async {
    final keys = _prefs.getKeys();
    final guestKeys = keys.where((k) => k.startsWith('guest_'));
    for (final key in guestKeys) {
      await _prefs.remove(key);
    }
  }

  /// Clear data for a specific user (useful when logging out)
  Future<void> clearUserData(String userId) async {
    final keys = _prefs.getKeys();
    final userKeys = keys.where((k) => k.startsWith('user_${userId}_'));
    for (final key in userKeys) {
      await _prefs.remove(key);
    }
  }
}
