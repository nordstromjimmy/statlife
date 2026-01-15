import '../../domain/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAll();
  Future<void> upsert(Task task);
  Future<void> delete(String id);
}
