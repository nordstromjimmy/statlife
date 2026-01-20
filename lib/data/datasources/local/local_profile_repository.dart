import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/profile.dart';
import 'local_store.dart';

class LocalProfileRepository {
  LocalProfileRepository(this._prefs) : _store = LocalStore(_prefs);

  final SharedPreferences _prefs;
  final LocalStore _store;
  static const _key = 'profile';

  Future<Profile?> get({String? userId}) async {
    final map = _store.readJsonMap(_key, userId: userId);
    if (map == null) return null;
    return Profile.fromJson(map);
  }

  Future<void> save(Profile profile, {String? userId}) async {
    await _store.writeJson(_key, profile.toJson(), userId: userId);
  }

  Future<void> clear({String? userId}) async {
    await _store.remove(_key, userId: userId);
  }
}
