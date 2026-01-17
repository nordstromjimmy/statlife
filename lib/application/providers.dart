import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/local/local_goal_repository.dart';
import '../data/datasources/local/local_store.dart';
import '../data/datasources/local/local_task_repository.dart';
import '../data/datasources/local/local_profile_repository.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/profile_repository.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart');
});

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore(ref.watch(sharedPrefsProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return LocalTaskRepository(ref.watch(localStoreProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return LocalProfileRepository(ref.watch(localStoreProvider));
});

final localGoalRepositoryProvider = Provider<LocalGoalRepository>((ref) {
  final store = ref.read(localStoreProvider);
  return LocalGoalRepository(store);
});
