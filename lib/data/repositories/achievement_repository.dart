import '../../domain/models/achievement.dart';
import '../datasources/local/local_achievement_repository.dart';
import '../datasources/remote/supabase_achievement_datasource.dart';

class AchievementRepository {
  AchievementRepository({
    required this.localRepo,
    required this.supabaseDatasource,
    required this.isAuthenticated,
    this.userId,
  });

  final LocalAchievementRepository localRepo;
  final SupabaseAchievementDatasource supabaseDatasource;
  final bool isAuthenticated;
  final String? userId;

  /// Get all achievements with current progress
  Future<List<Achievement>> getAll() async {
    if (isAuthenticated && userId != null) {
      // Authenticated: Fetch from Supabase, then cache locally
      try {
        final achievements = await supabaseDatasource.getAllAchievements();

        // Cache locally
        await localRepo.saveAll(achievements, userId: userId);

        return achievements;
      } catch (e) {
        // Fallback to local cache if Supabase fails
        return await localRepo.getAll(userId: userId);
      }
    } else {
      // Guest: Return default achievements (no progress tracking)
      return await localRepo.getAll(userId: null);
    }
  }

  /// Update achievement progress
  Future<void> updateProgress(Achievement achievement) async {
    if (!isAuthenticated || userId == null) {
      // Guests don't track achievements
      return;
    }

    // Save locally first (fast)
    await localRepo.save(achievement, userId: userId);

    // Then sync to Supabase (can fail without blocking)
    try {
      await supabaseDatasource.upsertAchievement(achievement);
    } catch (e) {
      // Silently fail - will sync next time
    }
  }

  /// Batch update multiple achievements
  Future<void> updateMultiple(List<Achievement> achievements) async {
    if (!isAuthenticated || userId == null) {
      return;
    }

    // Save locally first
    await localRepo.saveAll(achievements, userId: userId);

    // Then sync to Supabase
    try {
      await supabaseDatasource.upsertAchievements(achievements);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all achievement data (for testing or sign out)
  Future<void> clear() async {
    await localRepo.clear(userId: userId);
  }
}
