import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/task.dart';
import '../tasks/task_controller.dart';
import '../profile/profile_controller.dart';
import 'achievement_controller.dart';

class AchievementService {
  AchievementService(this.ref);

  final Ref ref;

  /// Check for newly unlocked achievements after task completion
  Future<List<Achievement>> checkAfterTaskCompletion(Task completedTask) async {
    final achievements = ref.read(achievementControllerProvider).value ?? [];
    final tasks = ref.read(taskControllerProvider).value ?? [];
    final profile = ref.read(profileControllerProvider).value;

    if (profile == null) return [];

    final newlyUnlocked = <Achievement>[];
    final toUpdate = <Achievement>[];

    // Get completed tasks count
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final totalCompleted = completedTasks.length;

    // Get tasks completed today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedToday = completedTasks
        .where((t) => _isSameDay(t.completedAt ?? t.day, today))
        .length;

    // ========================================
    // CHECK GETTING STARTED ACHIEVEMENTS
    // ========================================

    // First Steps - Complete first task
    final firstSteps = _getAchievement(
      achievements,
      AchievementType.firstSteps,
    );
    if (firstSteps != null && firstSteps.isLocked && totalCompleted >= 1) {
      newlyUnlocked.add(
        firstSteps.copyWith(unlockedAt: DateTime.now(), currentProgress: 1),
      );
    }

    // Early Bird - Complete task before 9 AM
    if (completedTask.startAt != null && completedTask.startAt!.hour < 9) {
      final earlyBird = _getAchievement(
        achievements,
        AchievementType.earlyBird,
      );
      if (earlyBird != null && earlyBird.isLocked) {
        newlyUnlocked.add(
          earlyBird.copyWith(unlockedAt: DateTime.now(), currentProgress: 1),
        );
      }
    }

    // Night Owl - Complete task after 9 PM
    if (completedTask.startAt != null && completedTask.startAt!.hour >= 21) {
      final nightOwl = _getAchievement(achievements, AchievementType.nightOwl);
      if (nightOwl != null && nightOwl.isLocked) {
        newlyUnlocked.add(
          nightOwl.copyWith(unlockedAt: DateTime.now(), currentProgress: 1),
        );
      }
    }

    // Weekend Warrior - Complete task on weekend
    if (completedTask.day.weekday >= 6) {
      final weekendWarrior = _getAchievement(
        achievements,
        AchievementType.weekendWarrior,
      );
      if (weekendWarrior != null && weekendWarrior.isLocked) {
        newlyUnlocked.add(
          weekendWarrior.copyWith(
            unlockedAt: DateTime.now(),
            currentProgress: 1,
          ),
        );
      }
    }

    // ========================================
    // CHECK TASK COMPLETION ACHIEVEMENTS
    // ========================================

    final completionAchievements = [
      (AchievementType.tenTasksTotal, 10),
      (AchievementType.fiftyTasksTotal, 50),
      (AchievementType.hundredTasksTotal, 100),
      (AchievementType.fiveHundredTasksTotal, 500),
      (AchievementType.thousandTasksTotal, 1000),
    ];

    for (final (type, target) in completionAchievements) {
      final achievement = _getAchievement(achievements, type);
      if (achievement != null) {
        if (achievement.isLocked && totalCompleted >= target) {
          newlyUnlocked.add(
            achievement.copyWith(
              unlockedAt: DateTime.now(),
              currentProgress: totalCompleted,
            ),
          );
        } else if (achievement.isLocked) {
          // Update progress
          toUpdate.add(achievement.copyWith(currentProgress: totalCompleted));
        }
      }
    }

    // ========================================
    // CHECK DAILY TASK ACHIEVEMENTS
    // ========================================

    final dailyAchievements = [
      (AchievementType.fiveTasksOneDay, 5),
      (AchievementType.tenTasksOneDay, 10),
      (AchievementType.twentyTasksOneDay, 20),
    ];

    for (final (type, target) in dailyAchievements) {
      final achievement = _getAchievement(achievements, type);
      if (achievement != null &&
          achievement.isLocked &&
          completedToday >= target) {
        newlyUnlocked.add(
          achievement.copyWith(
            unlockedAt: DateTime.now(),
            currentProgress: completedToday,
          ),
        );
      }
    }

    // ========================================
    // CHECK LEVEL ACHIEVEMENTS
    // ========================================

    final levelAchievements = [
      (AchievementType.levelFive, 5),
      (AchievementType.levelTen, 10),
      (AchievementType.levelTwentyFive, 25),
      (AchievementType.levelFifty, 50),
      (AchievementType.levelHundred, 100),
    ];

    for (final (type, target) in levelAchievements) {
      final achievement = _getAchievement(achievements, type);
      if (achievement != null) {
        if (achievement.isLocked && profile.level >= target) {
          newlyUnlocked.add(
            achievement.copyWith(
              unlockedAt: DateTime.now(),
              currentProgress: profile.level,
            ),
          );
        } else if (achievement.isLocked) {
          // Update progress
          toUpdate.add(achievement.copyWith(currentProgress: profile.level));
        }
      }
    }

    // ========================================
    // SAVE UPDATES
    // ========================================

    final allUpdates = [...newlyUnlocked, ...toUpdate];
    if (allUpdates.isNotEmpty) {
      await ref
          .read(achievementControllerProvider.notifier)
          .updateMultiple(allUpdates);
    }

    return newlyUnlocked;
  }

  /// Check for achievements after creating a goal
  Future<List<Achievement>> checkAfterGoalCreation() async {
    final achievements = ref.read(achievementControllerProvider).value ?? [];
    final goalGetter = _getAchievement(
      achievements,
      AchievementType.goalGetter,
    );

    if (goalGetter != null && goalGetter.isLocked) {
      final unlocked = goalGetter.copyWith(
        unlockedAt: DateTime.now(),
        currentProgress: 1,
      );

      await ref.read(achievementControllerProvider.notifier).updateMultiple([
        unlocked,
      ]);

      return [unlocked];
    }

    return [];
  }

  /// Check for level achievements after XP gain
  Future<List<Achievement>> checkAfterLevelUp(int newLevel) async {
    final achievements = ref.read(achievementControllerProvider).value ?? [];
    final newlyUnlocked = <Achievement>[];

    final levelAchievements = [
      (AchievementType.levelFive, 5),
      (AchievementType.levelTen, 10),
      (AchievementType.levelTwentyFive, 25),
      (AchievementType.levelFifty, 50),
      (AchievementType.levelHundred, 100),
    ];

    for (final (type, target) in levelAchievements) {
      final achievement = _getAchievement(achievements, type);
      if (achievement != null && achievement.isLocked && newLevel >= target) {
        newlyUnlocked.add(
          achievement.copyWith(
            unlockedAt: DateTime.now(),
            currentProgress: newLevel,
          ),
        );
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await ref
          .read(achievementControllerProvider.notifier)
          .updateMultiple(newlyUnlocked);
    }

    return newlyUnlocked;
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  Achievement? _getAchievement(
    List<Achievement> achievements,
    AchievementType type,
  ) {
    try {
      return achievements.firstWhere((a) => a.type == type);
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Provider for AchievementService
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService(ref);
});
