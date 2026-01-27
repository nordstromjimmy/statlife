import '../../../domain/models/task.dart';
import 'local_store.dart';

class LocalTaskRepository {
  LocalTaskRepository(this._store);

  final LocalStore _store;
  static const _key = 'tasks';

  Future<List<Task>> getAll({String? userId}) async {
    final list = _store.readJsonList(_key, userId: userId) ?? [];

    var tasks = list
        .whereType<Map<String, dynamic>>()
        .map(Task.fromJson)
        .toList();

    // Migration: ensure every task has a time span
    var migrated = false;
    tasks = tasks.map((t) {
      if (t.startAt != null && t.endAt != null) return t;

      final day = DateTime(t.day.year, t.day.month, t.day.day);
      final start = DateTime(day.year, day.month, day.day, 0, 0);
      final end = start.add(const Duration(minutes: 30));

      migrated = true;
      return t.copyWith(startAt: start, endAt: end);
    }).toList();

    if (migrated) {
      await _store.writeJson(
        _key,
        tasks.map((t) => t.toJson()).toList(),
        userId: userId,
      );
    }

    return tasks;
  }

  Future<void> upsert(Task task, {String? userId}) async {
    final all = await getAll(userId: userId);
    final idx = all.indexWhere((t) => t.id == task.id);
    final updated = [...all];
    if (idx == -1) {
      updated.add(task);
    } else {
      updated[idx] = task;
    }
    await _store.writeJson(
      _key,
      updated.map((t) => t.toJson()).toList(),
      userId: userId,
    );
  }

  Future<void> delete(String id, {String? userId}) async {
    final all = await getAll(userId: userId);
    final updated = all.where((t) => t.id != id).toList();
    await _store.writeJson(
      _key,
      updated.map((t) => t.toJson()).toList(),
      userId: userId,
    );
  }

  /// Clear all local tasks for a specific user or guest
  Future<void> clear({String? userId}) async {
    await _store.remove(_key, userId: userId);
  }
}
