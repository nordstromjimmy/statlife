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

      return (response as List).map((json) => Goal.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching goals: $e');
      return [];
    }
  }

  /// Save/update a goal
  Future<void> upsertGoal(Goal goal) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    try {
      // Check if goal exists
      final existing = await _client
          .from('goals')
          .select()
          .eq('id', goal.id)
          .maybeSingle();

      if (existing != null) {
        // Update existing goal
        await _client
            .from('goals')
            .update({
              'title': goal.title,
              'default_duration_minutes': goal.defaultDurationMinutes,
              'archived_at': goal.archivedAt?.toIso8601String(),
              'updated_at': goal.updatedAt.toIso8601String(),
            })
            .eq('id', goal.id);
      } else {
        // Insert new goal
        await _client.from('goals').insert({
          'id': goal.id,
          'user_id': userId,
          'title': goal.title,
          'default_duration_minutes': goal.defaultDurationMinutes,
          'archived_at': goal.archivedAt?.toIso8601String(),
          'created_at': goal.createdAt.toIso8601String(),
          'updated_at': goal.updatedAt.toIso8601String(),
        });
      }
    } catch (e) {
      print('Error upserting goal: $e');
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
          .eq('user_id', userId); // Security: only delete own goals
    } catch (e) {
      print('Error deleting goal: $e');
      rethrow;
    }
  }
}
