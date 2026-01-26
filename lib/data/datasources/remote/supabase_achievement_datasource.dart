import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/achievement.dart';
import '../../../domain/services/achievement_definitions.dart';

class SupabaseAchievementDatasource {
  final SupabaseClient _client;

  SupabaseAchievementDatasource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Get all achievements for current user
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final response = await _client
          .from('user_achievements')
          .select()
          .order('created_at', ascending: true);

      final List<dynamic> data = response as List<dynamic>;

      // Build map of saved achievement data
      final savedData = <AchievementType, Map<String, dynamic>>{};
      for (final item in data) {
        try {
          final type = AchievementType.values.byName(item['achievement_type']);
          savedData[type] = item;
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ Skipped unknown achievement type: ${item['achievement_type']}',
            );
          }
          continue;
        }
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching achievements: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // Return default achievements on error
      return AchievementDefinitions.getAll();
    }
  }

  /// Upsert achievement (update progress or unlock)
  Future<void> upsertAchievement(Achievement achievement) async {
    try {
      await _client.from('user_achievements').upsert({
        'user_id': _client.auth.currentUser!.id,
        'achievement_type': achievement.type.name,
        'current_progress': achievement.currentProgress,
        'unlocked_at': achievement.unlockedAt?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ Error upserting achievement ${achievement.type.name}: $e',
        );
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Batch upsert multiple achievements
  Future<void> upsertAchievements(List<Achievement> achievements) async {
    try {
      final userId = _client.auth.currentUser!.id;
      final now = DateTime.now().toIso8601String();

      final data = achievements
          .where((a) => a.currentProgress > 0 || a.isUnlocked)
          .map(
            (a) => {
              'user_id': userId,
              'achievement_type': a.type.name,
              'current_progress': a.currentProgress,
              'unlocked_at': a.unlockedAt?.toIso8601String(),
              'updated_at': now,
            },
          )
          .toList();

      if (data.isEmpty) return;

      await _client.from('user_achievements').upsert(data);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error batch upserting achievements: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Delete all achievements for current user (for testing)
  Future<void> deleteAllAchievements() async {
    try {
      await _client
          .from('user_achievements')
          .delete()
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting achievements: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
