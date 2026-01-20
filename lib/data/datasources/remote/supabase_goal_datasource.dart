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

      print('📦 Raw Supabase goals response: $response');

      final goals = <Goal>[];
      for (var i = 0; i < (response as List).length; i++) {
        try {
          final json = response[i] as Map<String, dynamic>;

          // ✅ Remove user_id before parsing
          final cleanJson = Map<String, dynamic>.from(json);
          cleanJson.remove('user_id');

          print('🔍 Parsing goal $i: ${cleanJson['title']}');

          final goal = Goal.fromJson(cleanJson);
          goals.add(goal);
          print('   ✅ Successfully parsed');
        } catch (e, stack) {
          print('❌ Error parsing goal at index $i: $e');
          print('Stack trace: $stack');
        }
      }

      print('✅ Successfully parsed ${goals.length} goals');
      return goals;
    } catch (e, stack) {
      print('❌ Error fetching goals: $e');
      print('Stack trace: $stack');
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
    } catch (e, stack) {
      print('❌ Error upserting goal: $e');
      print('Stack trace: $stack');
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
    } catch (e, stack) {
      print('❌ Error deleting goal: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
