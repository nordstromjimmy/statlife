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
        print('📥 [User: $userId] Fetching goals from Supabase...');
        final goals = await supabaseRepo.getAllGoals();
        print('✅ Fetched ${goals.length} goals from Supabase');

        // Cache to local storage with user-specific key
        try {
          // Clear old local cache first to avoid conflicts
          await localRepo.clear(userId: userId);

          if (goals.isNotEmpty) {
            await localRepo.saveAll(goals, userId: userId);
            print('💾 Cached ${goals.length} goals to local storage');
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
          print('❌ Local cache also failed: $localError');
          // Clear corrupt local data
          await localRepo.clear(userId: userId);
          return [];
        }
      }
    }

    // Guest mode: use local storage only
    print('📱 [Guest] Fetching goals from local storage...');
    try {
      final goals = await localRepo.getAll(); // No userId = guest prefix
      print('✅ Fetched ${goals.length} guest goals from local');
      return goals;
    } catch (e) {
      print('❌ Failed to load guest goals: $e');
      // Clear corrupt guest data
      await localRepo.clear();
      return [];
    }
  }

  /// Save/update a single goal
  Future<void> upsert(Goal goal, List<Goal> allGoals) async {
    if (isAuthenticated && userId != null) {
      print('💾 [User: $userId] Saving goal: ${goal.title}');

      // Save to local with user-specific key
      try {
        await localRepo.saveAll(allGoals, userId: userId);
        print('✅ Saved to local cache');
      } catch (e) {
        print('⚠️ Failed to save locally: $e');
      }

      // Sync to Supabase
      try {
        await supabaseRepo.upsertGoal(goal);
        print('✅ Synced to Supabase');
      } catch (e) {
        print('❌ Supabase sync failed: $e');
      }
    } else {
      // Guest mode: save to local only
      print('💾 [Guest] Saving goal: ${goal.title}');
      await localRepo.saveAll(allGoals); // No userId = guest prefix
      print('✅ Saved to guest local storage');
    }
  }

  /// Delete goal
  Future<void> delete(String id, List<Goal> remainingGoals) async {
    if (isAuthenticated && userId != null) {
      print('🗑️ [User: $userId] Deleting goal: $id');

      await localRepo.saveAll(remainingGoals, userId: userId);
      print('✅ Deleted from local cache');

      try {
        await supabaseRepo.deleteGoal(id);
        print('✅ Deleted from Supabase');
      } catch (e) {
        print('❌ Supabase delete failed: $e');
      }
    } else {
      // Guest mode
      print('🗑️ [Guest] Deleting goal: $id');
      await localRepo.saveAll(remainingGoals);
      print('✅ Deleted from guest local storage');
    }
  }
}
