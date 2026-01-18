import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../application/auth/auth_controller.dart';
import '../data/datasources/local/local_goal_repository.dart';
import '../data/datasources/local/local_store.dart';
import '../data/datasources/local/local_task_repository.dart';
import '../data/datasources/local/local_profile_repository.dart';
import '../data/datasources/remote/supabase_profile_datasource.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../domain/models/auth_state.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart');
});

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore(ref.watch(sharedPrefsProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return LocalTaskRepository(ref.watch(localStoreProvider));
});

final localGoalRepositoryProvider = Provider<LocalGoalRepository>((ref) {
  final store = ref.read(localStoreProvider);
  return LocalGoalRepository(store);
});

// Local profile repository (for local storage only)
final localProfileRepositoryProvider = Provider<LocalProfileRepository>((ref) {
  return LocalProfileRepository(ref.read(sharedPrefsProvider));
});

// Supabase profile datasource
final supabaseProfileDatasourceProvider = Provider<SupabaseProfileDatasource>((
  ref,
) {
  return SupabaseProfileDatasource(Supabase.instance.client);
});

// Main profile repository (coordinates local + Supabase)
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final localRepo = ref.read(localProfileRepositoryProvider);
  final supabaseClient = Supabase.instance.client;
  final supabaseRepo = SupabaseProfileDatasource(supabaseClient);
  final authState = ref.watch(authControllerProvider).value;

  return ProfileRepository(
    localRepo: localRepo,
    supabaseRepo: supabaseRepo,
    isAuthenticated: authState?.isAuthenticated ?? false,
  );
});
