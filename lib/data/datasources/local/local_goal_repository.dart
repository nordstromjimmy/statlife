import '../../../domain/models/goal.dart';
import 'local_store.dart';

class LocalGoalRepository {
  LocalGoalRepository(this._store);

  final LocalStore _store;
  static const _key = 'goals';

  Future<List<Goal>> getAll({String? userId}) async {
    final list = _store.readJsonList(_key, userId: userId);
    if (list == null || list.isEmpty) return [];

    return list.cast<Map<String, dynamic>>().map(Goal.fromJson).toList();
  }

  Future<void> saveAll(List<Goal> goals, {String? userId}) async {
    await _store.writeJson(
      _key,
      goals.map((g) => g.toJson()).toList(),
      userId: userId,
    );
  }

  Future<void> clear({String? userId}) async {
    await _store.remove(_key, userId: userId);
  }
}
