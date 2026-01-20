import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/models/task.dart';
import '../providers.dart';

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, List<Task>>(TaskController.new);

class TaskController extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    // ✅ Watch both auth state AND userId to rebuild when either changes
    ref.watch(isAuthenticatedProvider);
    ref.watch(currentUserIdProvider);

    final all = await _fetchAndSort();
    return all;
  }

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  Future<List<Task>> _fetchAndSort() async {
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
    // Save to repository FIRST
    await _repo.upsert(task);

    // Then refetch to ensure consistency
    final updated = await _fetchAndSort();
    state = AsyncData(updated);
  }

  Future<void> delete(String id) async {
    // Delete from repository FIRST
    await _repo.delete(id);

    // Then refetch to ensure consistency
    final updated = await _fetchAndSort();
    state = AsyncData(updated);
  }
}
