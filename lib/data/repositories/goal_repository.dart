import '../../domain/models/goal.dart';
import '../datasources/local/local_goal_repository.dart';
import '../datasources/remote/supabase_goal_datasource.dart';

class GoalRepository {
  GoalRepository({
    required this.localRepo,
    required this.supabaseRepo,
    required this.isAuthenticated,
  });

  final LocalGoalRepository localRepo;
  final SupabaseGoalDatasource supabaseRepo;
  final bool isAuthenticated;

  /// Get all goals - from Supabase if authenticated, otherwise local
  Future<List<Goal>> getAll() async {
    if (isAuthenticated) {
      try {
        final goals = await supabaseRepo.getAllGoals();

        // Also save to local for offline access
        if (goals.isNotEmpty) {
          await localRepo.saveAll(goals);
        }
        return goals;
      } catch (e) {
        print('Supabase fetch failed, using local: $e');
        return await localRepo.getAll();
      }
    }

    return await localRepo.getAll();
  }

  /// Save all goals - to both local and Supabase if authenticated
  Future<void> saveAll(List<Goal> goals) async {
    // Always save to local first for offline access
    await localRepo.saveAll(goals);

    // Also save to Supabase if authenticated
    if (isAuthenticated) {
      try {
        for (final goal in goals) {
          await supabaseRepo.upsertGoal(goal);
        }
      } catch (e) {
        print('Supabase save failed: $e');
        // Continue anyway - data is in local storage
      }
    }
  }

  /// Save/update a single goal - to both local and Supabase if authenticated
  Future<void> upsert(Goal goal, List<Goal> allGoals) async {
    // Always save to local first
    await localRepo.saveAll(allGoals);

    // Also save to Supabase if authenticated
    if (isAuthenticated) {
      try {
        await supabaseRepo.upsertGoal(goal);
      } catch (e) {
        print('Supabase upsert failed: $e');
        // Continue anyway - data is in local storage
      }
    }
  }

  /// Delete goal - from both local and Supabase if authenticated
  Future<void> delete(String id, List<Goal> remainingGoals) async {
    // Always save to local (with goal removed)
    await localRepo.saveAll(remainingGoals);

    // Also delete from Supabase if authenticated
    if (isAuthenticated) {
      try {
        await supabaseRepo.deleteGoal(id);
      } catch (e) {
        print('Supabase delete failed: $e');
        // Continue anyway - deleted from local storage
      }
    }
  }
}
