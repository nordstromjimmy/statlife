import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/goal.dart';

class SupabaseGoalDatasource {
  final SupabaseClient _client;

  SupabaseGoalDatasource(this._client);

  /// Get all goals for the current user
  Future<List<Goal>> getAllGoals() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final goals = <Goal>[];
      for (var i = 0; i < (response as List).length; i++) {
        try {
          final json = response[i];

          // ✅ Remove user_id before parsing
          final cleanJson = Map<String, dynamic>.from(json);
          cleanJson.remove('user_id');

          final goal = Goal.fromJson(cleanJson);
          goals.add(goal);
        } catch (e, stackTrace) {
          // Skip corrupted items but log in debug mode
          if (kDebugMode) {
            debugPrint('⚠️ Skipped corrupted goal at index $i: $e');
            debugPrint('Stack trace: $stackTrace');
          }
          // TODO: Add error tracking service here
          // errorTracker.recordError(e, stackTrace, reason: 'Failed to parse goal');
          continue;
        }
      }

      return goals;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching goals: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // TODO: Add error tracking service here
      // errorTracker.recordError(e, stackTrace, reason: 'Failed to fetch goals');
      return [];
    }
  }

  /// Save/update a goal
  Future<void> upsertGoal(Goal goal) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    try {
      final existing = await _client
          .from('goals')
          .select()
          .eq('id', goal.id)
          .maybeSingle();

      final goalData = {
        'title': goal.title,
        'default_duration_minutes': goal.defaultDurationMinutes,
        'archived_at': goal.archivedAt?.toIso8601String(),
        'updated_at': goal.updatedAt.toIso8601String(),
      };

      if (existing != null) {
        await _client.from('goals').update(goalData).eq('id', goal.id);
      } else {
        await _client.from('goals').insert({
          'id': goal.id,
          'user_id': userId,
          ...goalData,
          'created_at': goal.createdAt.toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    try {
      await _client
          .from('goals')
          .delete()
          .eq('id', goalId)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
