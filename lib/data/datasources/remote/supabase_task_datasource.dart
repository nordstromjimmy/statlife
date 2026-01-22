import 'package:flutter/foundation.dart';
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
          .order('day', ascending: true);

      final tasks = <Task>[];
      for (var i = 0; i < (response as List).length; i++) {
        try {
          final json = response[i];

          // ✅ Remove user_id before parsing
          final cleanJson = Map<String, dynamic>.from(json);
          cleanJson.remove('user_id');

          final task = Task.fromJson(cleanJson);
          tasks.add(task);
        } catch (e, stackTrace) {
          // Skip corrupted items but log in debug mode
          if (kDebugMode) {
            debugPrint('⚠️ Skipped corrupted task at index $i: $e');
            debugPrint('Stack trace: $stackTrace');
          }
          // TODO: Add error tracking service here
          // errorTracker.recordError(e, stackTrace, reason: 'Failed to parse task');
          continue;
        }
      }

      return tasks;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching tasks: $e');
        debugPrint('❌ StackTrace: $stackTrace');
      }
      // TODO: Add error tracking service here
      // errorTracker.recordError(e, stackTrace, reason: 'Failed to fetch tasks');
      return [];
    }
  }

  /// Save/update a task
  Future<void> upsertTask(Task task) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    try {
      final existing = await _client
          .from('tasks')
          .select()
          .eq('id', task.id)
          .maybeSingle();

      final taskData = {
        'title': task.title,
        'day': task.day.toIso8601String().split('T')[0],
        'start_at': task.startAt?.toIso8601String(),
        'end_at': task.endAt?.toIso8601String(),
        'xp': task.xp,
        'goal_id': task.goalId,
        'completed_at': task.completedAt?.toIso8601String(),
        'first_completed_at': task.firstCompletedAt?.toIso8601String(),
        'updated_at': task.updatedAt.toIso8601String(),
      };

      if (existing != null) {
        await _client.from('tasks').update(taskData).eq('id', task.id);
      } else {
        await _client.from('tasks').insert({
          'id': task.id,
          'user_id': userId,
          ...taskData,
          'created_at': task.createdAt.toIso8601String(),
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error upserting task: $e');
        debugPrint('❌ StackTrace: $stackTrace');
      }
      // TODO: Add error tracking service here
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
          .eq('user_id', userId);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting task: $e');
        debugPrint('❌ StackTrace: $stackTrace');
      }
      // TODO: Add error tracking service here
      rethrow;
    }
  }
}
