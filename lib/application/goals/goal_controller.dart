import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/goal_repository.dart';
import '../../domain/models/goal.dart';
import '../providers.dart';
import '../tasks/task_controller.dart';

final goalControllerProvider =
    AsyncNotifierProvider<GoalController, List<Goal>>(GoalController.new);

class GoalController extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    // ✅ Watch both auth state AND userId to rebuild when either changes
    ref.watch(isAuthenticatedProvider);
    ref.watch(currentUserIdProvider);

    return _repo.getAll();
  }

  GoalRepository get _repo => ref.read(goalRepositoryProvider);

  Future<void> upsert(Goal goal) async {
    final current = state.value ?? [];
    final idx = current.indexWhere((g) => g.id == goal.id);
    final next = [...current];

    if (idx == -1) {
      next.add(goal);
    } else {
      next[idx] = goal;
    }

    // Save to repository FIRST
    await _repo.upsert(goal, next);

    // Then refetch to ensure consistency
    final updated = await _repo.getAll();
    state = AsyncData(updated);
  }

  Future<void> create({
    required String title,
    required int defaultDurationMinutes,
  }) async {
    final now = DateTime.now();
    final goal = Goal(
      id: const Uuid().v4(),
      title: title,
      defaultDurationMinutes: defaultDurationMinutes,
      createdAt: now,
      updatedAt: now,
    );
    await upsert(goal);
  }

  Future<void> delete(String id) async {
    // 1) Remove goal from goals list
    final currentGoals = state.value ?? [];
    final nextGoals = currentGoals.where((g) => g.id != id).toList();

    // Save to repository FIRST
    await _repo.delete(id, nextGoals);

    // Then refetch to ensure consistency
    final updated = await _repo.getAll();
    state = AsyncData(updated);

    // 2) Unlink tasks that reference this goal
    final tasks = ref.read(taskControllerProvider).value ?? [];
    final affected = tasks.where((t) => t.goalId == id).toList();
    if (affected.isEmpty) return;

    final taskNotifier = ref.read(taskControllerProvider.notifier);
    for (final t in affected) {
      await taskNotifier.upsert(
        t.copyWith(goalId: null, updatedAt: DateTime.now()),
      );
    }
  }
}
