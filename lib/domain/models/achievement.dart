import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

enum AchievementTier { bronze, silver, gold, diamond }

enum AchievementType {
  // Getting Started
  firstSteps,
  earlyBird,
  nightOwl,
  weekendWarrior,
  goalGetter,

  // Consistency Streaks
  threeDayStreak,
  sevenDayStreak,
  fourteenDayStreak,
  thirtyDayStreak,
  hundredDayStreak,

  // Task Completion
  tenTasksTotal,
  fiftyTasksTotal,
  hundredTasksTotal,
  fiveHundredTasksTotal,
  thousandTasksTotal,

  // Speed & Efficiency
  fiveTasksOneDay,
  tenTasksOneDay,
  twentyTasksOneDay,
  perfectWeek,
  perfectMonth,

  // XP & Leveling
  levelFive,
  levelTen,
  levelTwentyFive,
  levelFifty,
  levelHundred,
}

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required AchievementType type,
    required String title,
    required String description,
    required AchievementTier tier,
    required int xpReward,
    required String iconPath,
    DateTime? unlockedAt, // null = locked
    @Default(0) int currentProgress,
    required int targetProgress,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

// Extensions for convenience
extension AchievementX on Achievement {
  bool get isUnlocked => unlockedAt != null;
  bool get isLocked => unlockedAt == null;
  double get progressPercent =>
      targetProgress > 0 ? currentProgress / targetProgress : 0;
  bool get isComplete => currentProgress >= targetProgress;

  // Color for tier
  int get tierColor {
    switch (tier) {
      case AchievementTier.bronze:
        return 0xFFCD7F32; // Bronze
      case AchievementTier.silver:
        return 0xFFC0C0C0; // Silver
      case AchievementTier.gold:
        return 0xFFFFD700; // Gold
      case AchievementTier.diamond:
        return 0xFF00D9FF; // Cyan/Diamond
    }
  }
}
