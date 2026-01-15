import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  Future<void> writeJson(String key, Object value) async {
    final str = jsonEncode(value);
    await _prefs.setString(key, str);
  }

  Map<String, dynamic>? readJsonMap(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    final decoded = jsonDecode(str);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  List<dynamic>? readJsonList(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    final decoded = jsonDecode(str);
    return decoded is List<dynamic> ? decoded : null;
  }

  Future<void> remove(String key) => _prefs.remove(key);
}
