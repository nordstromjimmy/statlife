import '../../../domain/models/task.dart';
import '../../repositories/task_repository.dart';
import 'local_store.dart';

class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository(this._store);

  final LocalStore _store;
  static const _key = 'tasks';

  @override
  Future<List<Task>> getAll() async {
    final list = _store.readJsonList(_key) ?? [];

    var tasks = list
        .whereType<Map<String, dynamic>>()
        .map(Task.fromJson)
        .toList();

    // ✅ Migration: ensure every task has a time span
    var migrated = false;
    tasks = tasks.map((t) {
      if (t.startAt != null && t.endAt != null) return t;

      // Default span for legacy tasks: 00:00–00:30 on that day.
      // (We can change later if you prefer a different default.)
      final day = DateTime(t.day.year, t.day.month, t.day.day);
      final start = DateTime(day.year, day.month, day.day, 0, 0);
      final end = start.add(const Duration(minutes: 30));

      migrated = true;
      return t.copyWith(startAt: start, endAt: end);
    }).toList();

    if (migrated) {
      await _store.writeJson(_key, tasks.map((t) => t.toJson()).toList());
    }

    return tasks;
  }

  @override
  Future<void> upsert(Task task) async {
    final all = await getAll();
    final idx = all.indexWhere((t) => t.id == task.id);
    final updated = [...all];
    if (idx == -1) {
      updated.add(task);
    } else {
      updated[idx] = task;
    }
    await _store.writeJson(_key, updated.map((t) => t.toJson()).toList());
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    final updated = all.where((t) => t.id != id).toList();
    await _store.writeJson(_key, updated.map((t) => t.toJson()).toList());
  }
}
