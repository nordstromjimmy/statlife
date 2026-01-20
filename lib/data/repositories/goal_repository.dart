import '../../domain/models/goal.dart';
import '../datasources/local/local_goal_repository.dart';
import '../datasources/remote/supabase_goal_datasource.dart';

class GoalRepository {
  GoalRepository({
    required this.localRepo,
    required this.supabaseRepo,
    required this.isAuthenticated,
    this.userId,
  });

  final LocalGoalRepository localRepo;
  final SupabaseGoalDatasource supabaseRepo;
  final bool isAuthenticated;
  final String? userId;

  /// Get all goals
  /// - Guest: Fetch from local storage with guest prefix
  /// - Authenticated: Fetch from Supabase, cache locally with user prefix
  Future<List<Goal>> getAll() async {
    if (isAuthenticated && userId != null) {
      try {
        final goals = await supabaseRepo.getAllGoals();

        // Cache to local storage with user-specific key
        try {
          // Clear old local cache first to avoid conflicts
          await localRepo.clear(userId: userId);

          if (goals.isNotEmpty) {
            await localRepo.saveAll(goals, userId: userId);
          }
        } catch (cacheError) {
          print('⚠️ Failed to cache goals locally: $cacheError');
          // Continue anyway - we have the data from Supabase
        }

        return goals;
      } catch (e) {
        print('❌ Supabase fetch failed, trying local cache: $e');
        try {
          return await localRepo.getAll(userId: userId);
        } catch (localError) {
          // Clear corrupt local data
          await localRepo.clear(userId: userId);
          return [];
        }
      }
    }

    // Guest mode: use local storage only
    try {
      final goals = await localRepo.getAll(); // No userId = guest prefix
      return goals;
    } catch (e) {
      // Clear corrupt guest data
      await localRepo.clear();
      return [];
    }
  }

  /// Save/update a single goal
  Future<void> upsert(Goal goal, List<Goal> allGoals) async {
    if (isAuthenticated && userId != null) {
      // Save to local with user-specific key
      try {
        await localRepo.saveAll(allGoals, userId: userId);
      } catch (e) {
        print('⚠️ Failed to save locally: $e');
      }

      // Sync to Supabase
      try {
        await supabaseRepo.upsertGoal(goal);
      } catch (e) {
        print('❌ Supabase sync failed: $e');
      }
    } else {
      // Guest mode: save to local only
      await localRepo.saveAll(allGoals); // No userId = guest prefix
    }
  }

  /// Delete goal
  Future<void> delete(String id, List<Goal> remainingGoals) async {
    if (isAuthenticated && userId != null) {
      await localRepo.saveAll(remainingGoals, userId: userId);

      try {
        await supabaseRepo.deleteGoal(id);
      } catch (e) {
        print('❌ Supabase delete failed: $e');
      }
    } else {
      // Guest mode
      await localRepo.saveAll(remainingGoals);
    }
  }
}
