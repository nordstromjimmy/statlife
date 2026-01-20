import '../../domain/models/task.dart';
import '../datasources/local/local_task_repository.dart';
import '../datasources/remote/supabase_task_datasource.dart';

class TaskRepository {
  TaskRepository({
    required this.localRepo,
    required this.supabaseRepo,
    required this.isAuthenticated,
  });

  final LocalTaskRepository localRepo;
  final SupabaseTaskDatasource supabaseRepo;
  final bool isAuthenticated;

  /// Get all tasks - from Supabase if authenticated, otherwise local
  Future<List<Task>> getAll() async {
    if (isAuthenticated) {
      try {
        final tasks = await supabaseRepo.getAllTasks();

        // Also save to local for offline access
        if (tasks.isNotEmpty) {
          for (final task in tasks) {
            await localRepo.upsert(task);
          }
        }
        return tasks;
      } catch (e) {
        print('Supabase fetch failed, using local: $e');
        return await localRepo.getAll();
      }
    }

    return await localRepo.getAll();
  }

  /// Save/update task - to Supabase if authenticated, otherwise local
  Future<void> upsert(Task task) async {
    // Always save to local first for offline access
    await localRepo.upsert(task);

    // Also save to Supabase if authenticated
    if (isAuthenticated) {
      try {
        await supabaseRepo.upsertTask(task);
      } catch (e) {
        print('Supabase upsert failed: $e');
        // Continue anyway - data is in local storage
      }
    }
  }

  /// Delete task - from Supabase if authenticated, otherwise local
  Future<void> delete(String id) async {
    // Always delete from local
    await localRepo.delete(id);

    // Also delete from Supabase if authenticated
    if (isAuthenticated) {
      try {
        await supabaseRepo.deleteTask(id);
      } catch (e) {
        print('Supabase delete failed: $e');
        // Continue anyway - deleted from local storage
      }
    }
  }
}
