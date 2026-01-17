import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/local/local_goal_repository.dart';
import '../../domain/models/goal.dart';
import '../providers.dart';
import '../tasks/task_controller.dart';

final goalControllerProvider =
    AsyncNotifierProvider<GoalController, List<Goal>>(GoalController.new);

class GoalController extends AsyncNotifier<List<Goal>> {
  late final LocalGoalRepository _repo;

  @override
  Future<List<Goal>> build() async {
    _repo = ref.read(localGoalRepositoryProvider);
    return _repo.getAll();
  }

  Future<void> upsert(Goal goal) async {
    final current = state.value ?? [];
    final idx = current.indexWhere((g) => g.id == goal.id);
    final next = [...current];

    if (idx == -1) {
      next.add(goal);
    } else {
      next[idx] = goal;
    }

    state = AsyncData(next);
    await _repo.saveAll(next);
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
    state = AsyncData(nextGoals);
    await _repo.saveAll(nextGoals);

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
