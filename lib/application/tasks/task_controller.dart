import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/models/task.dart';
import '../providers.dart';

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, List<Task>>(TaskController.new);

class TaskController extends AsyncNotifier<List<Task>> {
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() async {
    final all = await _repo.getAll();
    all.sort((a, b) {
      final d = a.day.compareTo(b.day);
      if (d != 0) return d;
      final aStart = a.startAt ?? a.day;
      final bStart = b.startAt ?? b.day;
      return aStart.compareTo(bStart);
    });
    return all;
  }

  Future<void> upsert(Task task) async {
    final current = state.value ?? [];
    state = AsyncData(_upsertInMemory(current, task));
    await _repo.upsert(task);
  }

  Future<void> delete(String id) async {
    final current = state.value ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
    await _repo.delete(id);
  }

  List<Task> _upsertInMemory(List<Task> list, Task task) {
    final idx = list.indexWhere((t) => t.id == task.id);
    final updated = [...list];
    if (idx == -1) {
      updated.add(task);
    } else {
      updated[idx] = task;
      //updated.sort((a, b) => a.day.compareTo(b.day));
      updated.sort((a, b) {
        final d = a.day.compareTo(b.day);
        if (d != 0) return d;
        final aStart = a.startAt ?? a.day;
        final bStart = b.startAt ?? b.day;
        return aStart.compareTo(bStart);
      });
    }
    return updated;
  }
}
