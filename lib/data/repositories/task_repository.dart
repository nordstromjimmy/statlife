import '../../domain/models/task.dart';
import '../datasources/local/local_task_repository.dart';
import '../datasources/remote/supabase_task_datasource.dart';

class TaskRepository {
  TaskRepository({
    required this.localRepo,
    required this.supabaseRepo,
    required this.isAuthenticated,
    this.userId,
  });

  final LocalTaskRepository localRepo;
  final SupabaseTaskDatasource supabaseRepo;
  final bool isAuthenticated;
  final String? userId;

  /// Get all tasks
  /// - Guest: Fetch from local storage with guest prefix
  /// - Authenticated: Fetch from Supabase, cache locally with user prefix
  Future<List<Task>> getAll() async {
    if (isAuthenticated && userId != null) {
      try {
        print('📥 [User: $userId] Fetching tasks from Supabase...');
        final tasks = await supabaseRepo.getAllTasks();
        print('✅ Fetched ${tasks.length} tasks from Supabase');

        // Cache to local storage with user-specific key
        try {
          // Clear old local cache first to avoid conflicts
          await localRepo.clear(userId: userId);

          if (tasks.isNotEmpty) {
            for (final task in tasks) {
              await localRepo.upsert(task, userId: userId);
            }
            print('💾 Cached ${tasks.length} tasks to local storage');
          }
        } catch (cacheError) {
          print('⚠️ Failed to cache tasks locally: $cacheError');
          // Continue anyway - we have the data from Supabase
        }

        return tasks;
      } catch (e) {
        print('❌ Supabase fetch failed, trying local cache: $e');
        try {
          return await localRepo.getAll(userId: userId);
        } catch (localError) {
          print('❌ Local cache also failed: $localError');
          // Clear corrupt local data
          await localRepo.clear(userId: userId);
          return [];
        }
      }
    }

    // Guest mode: use local storage only
    print('📱 [Guest] Fetching tasks from local storage...');
    try {
      final tasks = await localRepo.getAll(); // No userId = guest prefix
      print('✅ Fetched ${tasks.length} guest tasks from local');
      return tasks;
    } catch (e) {
      print('❌ Failed to load guest tasks: $e');
      // Clear corrupt guest data
      await localRepo.clear();
      return [];
    }
  }

  /// Save/update task
  Future<void> upsert(Task task) async {
    if (isAuthenticated && userId != null) {
      print('💾 [User: $userId] Saving task: ${task.title}');

      // Save to local with user-specific key
      try {
        await localRepo.upsert(task, userId: userId);
        print('✅ Saved to local cache');
      } catch (e) {
        print('⚠️ Failed to save locally: $e');
      }

      // Sync to Supabase
      try {
        await supabaseRepo.upsertTask(task);
        print('✅ Synced to Supabase');
      } catch (e) {
        print('❌ Supabase sync failed: $e');
      }
    } else {
      // Guest mode: save to local only
      print('💾 [Guest] Saving task: ${task.title}');
      await localRepo.upsert(task); // No userId = guest prefix
      print('✅ Saved to guest local storage');
    }
  }

  /// Delete task
  Future<void> delete(String id) async {
    if (isAuthenticated && userId != null) {
      print('🗑️ [User: $userId] Deleting task: $id');

      await localRepo.delete(id, userId: userId);
      print('✅ Deleted from local cache');

      try {
        await supabaseRepo.deleteTask(id);
        print('✅ Deleted from Supabase');
      } catch (e) {
        print('❌ Supabase delete failed: $e');
      }
    } else {
      // Guest mode
      print('🗑️ [Guest] Deleting task: $id');
      await localRepo.delete(id);
      print('✅ Deleted from guest local storage');
    }
  }
}
