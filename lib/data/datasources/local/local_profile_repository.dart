import '../../../domain/models/profile.dart';
import '../../repositories/profile_repository.dart';
import 'local_store.dart';

class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository(this._store);

  final LocalStore _store;
  static const _key = 'profile';

  @override
  Future<Profile?> get() async {
    final map = _store.readJsonMap(_key);
    if (map == null) return null;
    return Profile.fromJson(map);
  }

  @override
  Future<void> save(Profile profile) async {
    await _store.writeJson(_key, profile.toJson());
  }
}
