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
    // ✅ FIX: Save to repository FIRST, then update state
    await _repo.upsert(task);

    // Only update state after successful save
    final current = state.value ?? [];
    state = AsyncData(_upsertInMemory(current, task));
  }

  Future<void> delete(String id) async {
    // ✅ FIX: Delete from repository FIRST, then update state
    await _repo.delete(id);

    // Only update state after successful delete
    final current = state.value ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
  }

  List<Task> _upsertInMemory(List<Task> list, Task task) {
    final idx = list.indexWhere((t) => t.id == task.id);
    final updated = [...list];
    if (idx == -1) {
      updated.add(task);
    } else {
      updated[idx] = task;
    }

    // Sort after updating
    updated.sort((a, b) {
      final d = a.day.compareTo(b.day);
      if (d != 0) return d;
      final aStart = a.startAt ?? a.day;
      final bStart = b.startAt ?? b.day;
      return aStart.compareTo(bStart);
    });

    return updated;
  }
}
