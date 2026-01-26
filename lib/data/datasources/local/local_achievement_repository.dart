import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/achievement.dart';
import '../../../domain/services/achievement_definitions.dart';

class LocalAchievementRepository {
  LocalAchievementRepository({required this.prefs});

  final SharedPreferences prefs;

  /// Get storage key based on user authentication
  String _getKey(String? userId) {
    if (userId == null) {
      return 'guest_achievements'; // Guests don't track achievements
    }
    return 'user_${userId}_achievements';
  }

  /// Get all achievements for user (with progress)
  Future<List<Achievement>> getAll({String? userId}) async {
    final key = _getKey(userId);
    final json = prefs.getString(key);

    if (json == null) {
      // No saved data - return all achievements with default state
      return AchievementDefinitions.getAll();
    }

    try {
      final List<dynamic> list = jsonDecode(json);
      final savedData = <AchievementType, Map<String, dynamic>>{};

      // Build map of saved achievement data
      for (final item in list) {
        final type = AchievementType.values.byName(item['achievement_type']);
        savedData[type] = item;
      }

      // Merge saved data with definitions
      return AchievementDefinitions.getAll().map((definition) {
        final saved = savedData[definition.type];
        if (saved == null) return definition;

        return definition.copyWith(
          currentProgress: saved['current_progress'] ?? 0,
          unlockedAt: saved['unlocked_at'] != null
              ? DateTime.parse(saved['unlocked_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      // Corrupted data - return defaults
      return AchievementDefinitions.getAll();
    }
  }

  /// Save achievement progress
  Future<void> save(Achievement achievement, {String? userId}) async {
    final key = _getKey(userId);
    final current = await getAll(userId: userId);

    // Update or add achievement
    final updated = current.map((a) {
      if (a.type == achievement.type) {
        return achievement;
      }
      return a;
    }).toList();

    // Convert to storage format (only save changed achievements)
    final toSave = updated
        .where((a) => a.currentProgress > 0 || a.isUnlocked)
        .map(
          (a) => {
            'achievement_type': a.type.name,
            'current_progress': a.currentProgress,
            'unlocked_at': a.unlockedAt?.toIso8601String(),
          },
        )
        .toList();

    await prefs.setString(key, jsonEncode(toSave));
  }

  /// Batch save multiple achievements
  Future<void> saveAll(List<Achievement> achievements, {String? userId}) async {
    final key = _getKey(userId);

    final toSave = achievements
        .where((a) => a.currentProgress > 0 || a.isUnlocked)
        .map(
          (a) => {
            'achievement_type': a.type.name,
            'current_progress': a.currentProgress,
            'unlocked_at': a.unlockedAt?.toIso8601String(),
          },
        )
        .toList();

    await prefs.setString(key, jsonEncode(toSave));
  }

  /// Clear all achievement data
  Future<void> clear({String? userId}) async {
    final key = _getKey(userId);
    await prefs.remove(key);
  }
}
