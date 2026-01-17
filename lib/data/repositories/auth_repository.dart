import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/auth_state.dart';
import '../../application/providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(sharedPrefsProvider));
});

class AuthRepository {
  AuthRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'auth_state';

  Future<AuthState?> getAuthState() async {
    final json = _prefs.getString(_key);
    if (json == null) return null;

    try {
      return AuthState.fromJson(jsonDecode(json));
    } catch (e) {
      // Invalid data, return null
      return null;
    }
  }

  Future<void> saveAuthState(AuthState state) async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
