import '../models/achievement.dart';

/// Master list of all achievements in the app
/// This is the single source of truth for achievement definitions
class AchievementDefinitions {
  /// Get icon path based on tier
  static String _getIconPath(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'assets/achievements/bronze.png';
      case AchievementTier.silver:
        return 'assets/achievements/silver.png';
      case AchievementTier.gold:
        return 'assets/achievements/gold.png';
      case AchievementTier.diamond:
        return 'assets/achievements/diamond.png';
    }
  }

  /// Get all achievement definitions (25 total)
  static List<Achievement> getAll() {
    return [
      // ========================================
      // GETTING STARTED (5)
      // ========================================
      Achievement(
        type: AchievementType.firstSteps,
        title: 'First Steps',
        description: 'Complete your first task',
        tier: AchievementTier.bronze,
        xpReward: 50,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 1,
      ),

      Achievement(
        type: AchievementType.earlyBird,
        title: 'Early Bird',
        description: 'Complete a task before 9 AM',
        tier: AchievementTier.bronze,
        xpReward: 50,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 1,
      ),

      Achievement(
        type: AchievementType.nightOwl,
        title: 'Night Owl',
        description: 'Complete a task after 9 PM',
        tier: AchievementTier.bronze,
        xpReward: 50,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 1,
      ),

      Achievement(
        type: AchievementType.weekendWarrior,
        title: 'Weekend Warrior',
        description: 'Complete a task on Saturday or Sunday',
        tier: AchievementTier.bronze,
        xpReward: 50,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 1,
      ),

      Achievement(
        type: AchievementType.goalGetter,
        title: 'Goal Getter',
        description: 'Create your first goal',
        tier: AchievementTier.bronze,
        xpReward: 50,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 1,
      ),

      // ========================================
      // CONSISTENCY STREAKS (5)
      // ========================================
      Achievement(
        type: AchievementType.threeDayStreak,
        title: "Three's Company",
        description: 'Complete all tasks 3 days in a row',
        tier: AchievementTier.bronze,
        xpReward: 75,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 3,
      ),

      Achievement(
        type: AchievementType.sevenDayStreak,
        title: 'Lucky Seven',
        description: 'Complete all tasks 7 days in a row',
        tier: AchievementTier.silver,
        xpReward: 100,
        iconPath: _getIconPath(AchievementTier.silver),
        targetProgress: 7,
      ),

      Achievement(
        type: AchievementType.fourteenDayStreak,
        title: 'Two Week Wonder',
        description: 'Complete all tasks 14 days in a row',
        tier: AchievementTier.silver,
        xpReward: 150,
        iconPath: _getIconPath(AchievementTier.silver),
        targetProgress: 14,
      ),

      Achievement(
        type: AchievementType.thirtyDayStreak,
        title: 'Monthly Master',
        description: 'Complete all tasks 30 days in a row',
        tier: AchievementTier.gold,
        xpReward: 250,
        iconPath: _getIconPath(AchievementTier.gold),
        targetProgress: 30,
      ),

      Achievement(
        type: AchievementType.hundredDayStreak,
        title: 'Century Club',
        description: 'Complete all tasks 100 days in a row',
        tier: AchievementTier.diamond,
        xpReward: 1000,
        iconPath: _getIconPath(AchievementTier.diamond),
        targetProgress: 100,
      ),

      // ========================================
      // TASK COMPLETION (5)
      // ========================================
      Achievement(
        type: AchievementType.tenTasksTotal,
        title: 'Getting the Hang of It',
        description: 'Complete 10 tasks total',
        tier: AchievementTier.bronze,
        xpReward: 50,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 10,
      ),

      Achievement(
        type: AchievementType.fiftyTasksTotal,
        title: 'Productive',
        description: 'Complete 50 tasks total',
        tier: AchievementTier.silver,
        xpReward: 100,
        iconPath: _getIconPath(AchievementTier.silver),
        targetProgress: 50,
      ),

      Achievement(
        type: AchievementType.hundredTasksTotal,
        title: 'Task Master',
        description: 'Complete 100 tasks total',
        tier: AchievementTier.silver,
        xpReward: 150,
        iconPath: _getIconPath(AchievementTier.silver),
        targetProgress: 100,
      ),

      Achievement(
        type: AchievementType.fiveHundredTasksTotal,
        title: 'Unstoppable',
        description: 'Complete 500 tasks total',
        tier: AchievementTier.gold,
        xpReward: 250,
        iconPath: _getIconPath(AchievementTier.gold),
        targetProgress: 500,
      ),

      Achievement(
        type: AchievementType.thousandTasksTotal,
        title: 'Legend',
        description: 'Complete 1000 tasks total',
        tier: AchievementTier.diamond,
        xpReward: 500,
        iconPath: _getIconPath(AchievementTier.diamond),
        targetProgress: 1000,
      ),

      // ========================================
      // SPEED & EFFICIENCY (5)
      // ========================================
      Achievement(
        type: AchievementType.fiveTasksOneDay,
        title: 'Quick Draw',
        description: 'Complete 5 tasks in one day',
        tier: AchievementTier.bronze,
        xpReward: 75,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 5,
      ),

      Achievement(
        type: AchievementType.tenTasksOneDay,
        title: 'Power Hour',
        description: 'Complete 10 tasks in one day',
        tier: AchievementTier.silver,
        xpReward: 100,
        iconPath: _getIconPath(AchievementTier.silver),
        targetProgress: 10,
      ),

      Achievement(
        type: AchievementType.twentyTasksOneDay,
        title: 'Marathon',
        description: 'Complete 20 tasks in one day',
        tier: AchievementTier.gold,
        xpReward: 200,
        iconPath: _getIconPath(AchievementTier.gold),
        targetProgress: 20,
      ),

      Achievement(
        type: AchievementType.perfectWeek,
        title: 'Perfect Week',
        description: 'Complete all scheduled tasks Monday-Sunday',
        tier: AchievementTier.gold,
        xpReward: 250,
        iconPath: _getIconPath(AchievementTier.gold),
        targetProgress: 7,
      ),

      Achievement(
        type: AchievementType.perfectMonth,
        title: 'Perfect Month',
        description: 'Complete all scheduled tasks for a full month',
        tier: AchievementTier.diamond,
        xpReward: 500,
        iconPath: _getIconPath(AchievementTier.diamond),
        targetProgress: 30,
      ),

      // ========================================
      // XP & LEVELING (5)
      // ========================================
      Achievement(
        type: AchievementType.levelFive,
        title: 'Novice',
        description: 'Reach level 5',
        tier: AchievementTier.bronze,
        xpReward: 50,
        iconPath: _getIconPath(AchievementTier.bronze),
        targetProgress: 5,
      ),

      Achievement(
        type: AchievementType.levelTen,
        title: 'Intermediate',
        description: 'Reach level 10',
        tier: AchievementTier.silver,
        xpReward: 100,
        iconPath: _getIconPath(AchievementTier.silver),
        targetProgress: 10,
      ),

      Achievement(
        type: AchievementType.levelTwentyFive,
        title: 'Advanced',
        description: 'Reach level 25',
        tier: AchievementTier.gold,
        xpReward: 250,
        iconPath: _getIconPath(AchievementTier.gold),
        targetProgress: 25,
      ),

      Achievement(
        type: AchievementType.levelFifty,
        title: 'Expert',
        description: 'Reach level 50',
        tier: AchievementTier.gold,
        xpReward: 500,
        iconPath: _getIconPath(AchievementTier.gold),
        targetProgress: 50,
      ),

      Achievement(
        type: AchievementType.levelHundred,
        title: 'Legendary',
        description: 'Reach level 100',
        tier: AchievementTier.diamond,
        xpReward: 2000,
        iconPath: _getIconPath(AchievementTier.diamond),
        targetProgress: 100,
      ),
    ];
  }

  /// Get achievement definition by type
  static Achievement getByType(AchievementType type) {
    return getAll().firstWhere((a) => a.type == type);
  }

  /// Get achievements by tier
  static List<Achievement> getByTier(AchievementTier tier) {
    return getAll().where((a) => a.tier == tier).toList();
  }
}
