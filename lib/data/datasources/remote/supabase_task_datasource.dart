import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/task.dart';

class SupabaseTaskDatasource {
  final SupabaseClient _client;

  SupabaseTaskDatasource(this._client);

  /// Get all tasks for the current user
  Future<List<Task>> getAllTasks() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('day', ascending: true)
          .order('start_at', ascending: true);

      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  /// Save/update a task
  Future<void> upsertTask(Task task) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    try {
      // Check if task exists
      final existing = await _client
          .from('tasks')
          .select()
          .eq('id', task.id)
          .maybeSingle();

      if (existing != null) {
        // Update existing task
        await _client
            .from('tasks')
            .update({
              'title': task.title,
              'day': task.day.toIso8601String().split('T')[0], // Date only
              'start_at': task.startAt?.toIso8601String(),
              'end_at': task.endAt?.toIso8601String(),
              'xp': task.xp,
              'goal_id': task.goalId,
              'completed_at': task.completedAt?.toIso8601String(),
              'first_completed_at': task.firstCompletedAt?.toIso8601String(),
              'updated_at': task.updatedAt.toIso8601String(),
            })
            .eq('id', task.id);
      } else {
        // Insert new task
        await _client.from('tasks').insert({
          'id': task.id,
          'user_id': userId,
          'title': task.title,
          'day': task.day.toIso8601String().split('T')[0],
          'start_at': task.startAt?.toIso8601String(),
          'end_at': task.endAt?.toIso8601String(),
          'xp': task.xp,
          'goal_id': task.goalId,
          'completed_at': task.completedAt?.toIso8601String(),
          'first_completed_at': task.firstCompletedAt?.toIso8601String(),
          'created_at': task.createdAt.toIso8601String(),
          'updated_at': task.updatedAt.toIso8601String(),
        });
      }
    } catch (e) {
      print('Error upserting task: $e');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    try {
      await _client
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', userId); // Security: only delete own tasks
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }
}
