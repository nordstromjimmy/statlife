import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../domain/models/achievement.dart';
import '../providers.dart';

final achievementControllerProvider =
    AsyncNotifierProvider<AchievementController, List<Achievement>>(
      AchievementController.new,
    );

class AchievementController extends AsyncNotifier<List<Achievement>> {
  @override
  Future<List<Achievement>> build() async {
    // Watch auth state to rebuild when user logs in/out
    ref.watch(isAuthenticatedProvider);
    ref.watch(currentUserIdProvider);

    return await _fetchAchievements();
  }

  AchievementRepository get _repo => ref.read(achievementRepositoryProvider);

  Future<List<Achievement>> _fetchAchievements() async {
    return await _repo.getAll();
  }

  /// Update achievement progress (doesn't unlock automatically)
  Future<void> updateProgress(AchievementType type, int newProgress) async {
    final achievements = state.value ?? [];

    final updated = achievements.map((a) {
      if (a.type == type) {
        return a.copyWith(currentProgress: newProgress);
      }
      return a;
    }).toList();

    // Update state immediately (optimistic update)
    state = AsyncData(updated);

    // Save to repository
    final achievement = updated.firstWhere((a) => a.type == type);
    await _repo.updateProgress(achievement);
  }

  /// Unlock an achievement
  Future<void> unlock(AchievementType type) async {
    final achievements = state.value ?? [];

    final updated = achievements.map((a) {
      if (a.type == type && a.isLocked) {
        return a.copyWith(
          unlockedAt: DateTime.now(),
          currentProgress: a.targetProgress,
        );
      }
      return a;
    }).toList();

    // Update state immediately
    state = AsyncData(updated);

    // Save to repository
    final achievement = updated.firstWhere((a) => a.type == type);
    await _repo.updateProgress(achievement);
  }

  /// Batch update multiple achievements (for efficiency)
  Future<void> updateMultiple(List<Achievement> achievementsToUpdate) async {
    final achievements = state.value ?? [];

    // Create a map for quick lookup
    final updateMap = {for (var a in achievementsToUpdate) a.type: a};

    final updated = achievements.map((a) {
      return updateMap[a.type] ?? a;
    }).toList();

    // Update state
    state = AsyncData(updated);

    // Save to repository
    await _repo.updateMultiple(achievementsToUpdate);
  }

  /// Get a specific achievement by type
  Achievement? getByType(AchievementType type) {
    final achievements = state.value ?? [];
    try {
      return achievements.firstWhere((a) => a.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Get all unlocked achievements
  List<Achievement> getUnlocked() {
    return (state.value ?? []).where((a) => a.isUnlocked).toList();
  }

  /// Get achievements by tier
  List<Achievement> getByTier(AchievementTier tier) {
    return (state.value ?? []).where((a) => a.tier == tier).toList();
  }
}
