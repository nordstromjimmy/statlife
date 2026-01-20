import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../application/auth/auth_controller.dart';
import '../data/datasources/local/local_goal_repository.dart';
import '../data/datasources/local/local_store.dart';
import '../data/datasources/local/local_task_repository.dart';
import '../data/datasources/local/local_profile_repository.dart';
import '../data/datasources/remote/supabase_goal_datasource.dart';
import '../data/datasources/remote/supabase_profile_datasource.dart';
import '../data/datasources/remote/supabase_task_datasource.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../domain/models/auth_state.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart');
});

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore(ref.watch(sharedPrefsProvider));
});

// ============================================================================
// AUTH STATE HELPER
// ============================================================================

/// Helper provider to get current authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider).value;
  return authState?.isAuthenticated ?? false;
});

// ============================================================================
// TASK REPOSITORY
// ============================================================================

// Local task repository
final localTaskRepositoryProvider = Provider<LocalTaskRepository>((ref) {
  return LocalTaskRepository(ref.read(localStoreProvider));
});

// Supabase task datasource
final supabaseTaskDatasourceProvider = Provider<SupabaseTaskDatasource>((ref) {
  return SupabaseTaskDatasource(Supabase.instance.client);
});

// Main task repository (coordinates local + Supabase)
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final localRepo = ref.read(localTaskRepositoryProvider);
  final supabaseRepo = ref.read(supabaseTaskDatasourceProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return TaskRepository(
    localRepo: localRepo,
    supabaseRepo: supabaseRepo,
    isAuthenticated: isAuthenticated,
  );
});

// ============================================================================
// PROFILE REPOSITORY
// ============================================================================

// Local profile repository
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
  final supabaseRepo = ref.read(supabaseProfileDatasourceProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return ProfileRepository(
    localRepo: localRepo,
    supabaseRepo: supabaseRepo,
    isAuthenticated: isAuthenticated,
  );
});

// ============================================================================
// GOAL REPOSITORY
// ============================================================================

// Local goal repository
final localGoalRepositoryProvider = Provider<LocalGoalRepository>((ref) {
  return LocalGoalRepository(ref.read(localStoreProvider));
});

// Supabase goal datasource
final supabaseGoalDatasourceProvider = Provider<SupabaseGoalDatasource>((ref) {
  return SupabaseGoalDatasource(Supabase.instance.client);
});

// Main goal repository (coordinates local + Supabase)
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final localRepo = ref.read(localGoalRepositoryProvider);
  final supabaseRepo = ref.read(supabaseGoalDatasourceProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoalRepository(
    localRepo: localRepo,
    supabaseRepo: supabaseRepo,
    isAuthenticated: isAuthenticated,
  );
});
