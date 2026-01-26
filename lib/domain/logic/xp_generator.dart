import 'dart:math';

class XpGenerator {
  static final _rng = Random();

  /// Generate XP with weighted distribution
  /// Most common: 40-80 (70% chance)
  /// Less common: 20-39 and 81-95 (25% chance)
  /// Rare: 10-19 and 96-100 (5% chance)
  static int random() {
    final roll = _rng.nextDouble();

    if (roll < 0.70) {
      // 70% chance: Middle range (20-40)
      return 20 + _rng.nextInt(21); // 20-40
    } else if (roll < 0.95) {
      // 25% chance: Lower-middle (10-19) or Upper-middle (41-48)
      if (_rng.nextBool()) {
        return 10 + _rng.nextInt(10); // 10-19
      } else {
        return 41 + _rng.nextInt(8); // 41-48
      }
    } else {
      // 5% chance: Very low (5-9) or Jackpot (49-50)
      if (_rng.nextBool()) {
        return 5 + _rng.nextInt(5); // 5-9
      } else {
        return 49 + _rng.nextInt(2); // 49-50 (JACKPOT!)
      }
    }
  }

  /// Legacy method for backward compatibility (faster leveling)
  static int randomOld({int min = 50, int max = 100}) {
    return min + _rng.nextInt(max - min + 1);
  }

  /// Generate XP based on task duration
  /// Longer tasks = more XP
  static int forDuration(Duration duration) {
    final minutes = duration.inMinutes;

    // Base XP from duration
    final baseXp = (minutes * 0.8).clamp(10, 80).round();

    // Add random variance (±20%)
    final variance = (baseXp * 0.2).round();
    final randomOffset = _rng.nextInt(variance * 2 + 1) - variance;

    return (baseXp + randomOffset).clamp(10, 100);
  }

  /// Generate bonus XP for completing on time
  static int onTimeBonus() {
    return 10 + _rng.nextInt(11); // 10-20 bonus
  }

  /// Generate bonus XP for early completion
  static int earlyCompletionBonus(Duration earlyBy) {
    final minutes = earlyBy.inMinutes;
    if (minutes < 5) return 5;
    if (minutes < 15) return 10;
    if (minutes < 30) return 15;
    return 20; // 30+ minutes early
  }

  /// Generate bonus XP for streak
  static int streakBonus(int consecutiveDays) {
    if (consecutiveDays < 3) return 0;
    if (consecutiveDays < 7) return 10;
    if (consecutiveDays < 14) return 25;
    if (consecutiveDays < 30) return 50;
    return 100; // 30+ day streak!
  }

  /// Generate XP for task difficulty (future feature)
  static int forDifficulty(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 30 + _rng.nextInt(21); // 30-50
      case TaskDifficulty.medium:
        return 50 + _rng.nextInt(31); // 50-80
      case TaskDifficulty.hard:
        return 80 + _rng.nextInt(21); // 80-100
    }
  }
}

enum TaskDifficulty { easy, medium, hard }
