import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/profile.dart';
import '../../data/datasources/local/local_task_repository.dart';
import '../../data/datasources/local/local_goal_repository.dart';
import '../../data/datasources/local/local_profile_repository.dart';
import '../../data/datasources/remote/supabase_task_datasource.dart';
import '../../data/datasources/remote/supabase_goal_datasource.dart';
import '../../data/datasources/remote/supabase_profile_datasource.dart';
import '../providers.dart';

class DataMigrationService {
  DataMigrationService({
    required this.localTaskRepo,
    required this.localGoalRepo,
    required this.localProfileRepo,
    required this.supabaseTaskDatasource,
    required this.supabaseGoalDatasource,
    required this.supabaseProfileDatasource,
  });

  final LocalTaskRepository localTaskRepo;
  final LocalGoalRepository localGoalRepo;
  final LocalProfileRepository localProfileRepo;
  final SupabaseTaskDatasource supabaseTaskDatasource;
  final SupabaseGoalDatasource supabaseGoalDatasource;
  final SupabaseProfileDatasource supabaseProfileDatasource;

  /// Migrate guest data to user account
  /// Returns true if migration was successful
  /// Migrate guest data to user account
  /// Returns true if migration was successful
  Future<bool> migrateGuestDataToUser(String userId) async {
    try {
      // Get all guest data
      final guestTasks = await localTaskRepo.getAll(); // No userId = guest
      final guestGoals = await localGoalRepo.getAll();
      final guestProfile = await localProfileRepo.get();

      // Check if user already has data in Supabase
      try {
        final existingProfile = await supabaseProfileDatasource.getProfile();
        final existingTasks = await supabaseTaskDatasource.getAllTasks();
        final existingGoals = await supabaseGoalDatasource.getAllGoals();

        if (existingTasks.isNotEmpty ||
            existingGoals.isNotEmpty ||
            (existingProfile?.totalXp ?? 0) > 0) {
          return false;
        }
      } catch (e) {
        debugPrint('ℹ️ No existing data found (expected for new users): $e');
      }

      // Migrate tasks
      for (final task in guestTasks) {
        try {
          await supabaseTaskDatasource.upsertTask(task);
        } catch (e) {
          debugPrint('   ❌ Failed to migrate task: ${task.id} - $e');
        }
      }

      // Also save tasks with user-specific key in local storage
      for (final task in guestTasks) {
        try {
          await localTaskRepo.upsert(task, userId: userId);
        } catch (e) {
          debugPrint('   ⚠️ Failed to cache task locally: ${task.id} - $e');
        }
      }

      // Migrate goals
      for (final goal in guestGoals) {
        try {
          await supabaseGoalDatasource.upsertGoal(goal);
        } catch (e) {
          debugPrint('   ❌ Failed to migrate goal: ${goal.id} - $e');
        }
      }

      // Save all goals with user-specific key
      if (guestGoals.isNotEmpty) {
        await localGoalRepo.saveAll(guestGoals, userId: userId);
      }

      // Migrate profile (merge XP)
      if (guestProfile != null && guestProfile.totalXp > 0) {
        final userProfile = Profile(
          id: userId,
          name: guestProfile.name,
          totalXp: guestProfile.totalXp,
          level: guestProfile.level,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await supabaseProfileDatasource.saveProfile(userProfile);

          // Also save to local storage with user key
          await localProfileRepo.save(userProfile, userId: userId);
        } catch (e, stackTrace) {
          debugPrint('   ❌ Failed to migrate profile: $e');
          debugPrint('   Stack trace: $stackTrace');
        }
      } else {
        debugPrint(
          'ℹ️ No profile data to migrate (XP: ${guestProfile?.totalXp ?? 0})',
        );
      }

      // Clear guest data (keeps local storage clean)
      await clearGuestData();

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Migration failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Clear all guest data from local storage
  /// Made public so it can be called from auth controller
  Future<void> clearGuestData() async {
    // Get all guest data
    final guestTasks = await localTaskRepo.getAll();

    // Delete each task
    for (final task in guestTasks) {
      await localTaskRepo.delete(task.id);
    }

    // Clear goals
    await localGoalRepo.saveAll([]);

    // Clear profile
    await localProfileRepo.save(
      Profile(
        id: 'guest',
        name: null,
        totalXp: 0,
        level: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Check if there's guest data to migrate
  Future<bool> hasGuestData() async {
    final tasks = await localTaskRepo.getAll();
    final goals = await localGoalRepo.getAll();
    final profile = await localProfileRepo.get();

    return tasks.isNotEmpty || goals.isNotEmpty || (profile?.totalXp ?? 0) > 0;
  }

  /// Get guest data summary for showing in migration dialog
  Future<GuestDataSummary> getGuestDataSummary() async {
    final tasks = await localTaskRepo.getAll();
    final goals = await localGoalRepo.getAll();
    final profile = await localProfileRepo.get();

    return GuestDataSummary(
      taskCount: tasks.length,
      goalCount: goals.length,
      xp: profile?.totalXp ?? 0,
    );
  }
}

/// Summary of guest data for display in migration dialog
class GuestDataSummary {
  final int taskCount;
  final int goalCount;
  final int xp;

  GuestDataSummary({
    required this.taskCount,
    required this.goalCount,
    required this.xp,
  });
}

// Provider
final dataMigrationServiceProvider = Provider<DataMigrationService>((ref) {
  return DataMigrationService(
    localTaskRepo: ref.read(localTaskRepositoryProvider),
    localGoalRepo: ref.read(localGoalRepositoryProvider),
    localProfileRepo: ref.read(localProfileRepositoryProvider),
    supabaseTaskDatasource: ref.read(supabaseTaskDatasourceProvider),
    supabaseGoalDatasource: ref.read(supabaseGoalDatasourceProvider),
    supabaseProfileDatasource: ref.read(supabaseProfileDatasourceProvider),
  );
});
