import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/auth_state.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<AuthState> build() async {
    // Load saved auth state
    final saved = await _repo.getAuthState();

    // If authenticated, verify session is still valid
    if (saved != null && saved.isAuthenticated) {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        // Session expired, revert to guest
        final guestState = saved.copyWith(
          userType: UserType.guest,
          userId: null,
          email: null,
        );
        await _repo.saveAuthState(guestState);
        return guestState;
      }
    }

    return saved ?? kInitialAuthState;
  }

  /// User chooses to continue as guest
  Future<void> continueAsGuest() async {
    final updated = state.value!.copyWith(
      userType: UserType.guest,
      hasSeenWelcome: true,
    );
    state = AsyncData(updated);
    await _repo.saveAuthState(updated);
  }

  /// Sign up with email/password
  Future<void> signUp({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      final updated = state.value!.copyWith(
        userType: UserType.authenticated,
        userId: response.user!.id,
        email: email,
        hasSeenWelcome: true,
      );

      state = AsyncData(updated);
      await _repo.saveAuthState(updated);

      // TODO: Migrate local data to Supabase here
      // await _migrateGuestDataToCloud();
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email/password
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      final updated = state.value!.copyWith(
        userType: UserType.authenticated,
        userId: response.user!.id,
        email: email,
        hasSeenWelcome: true,
      );

      state = AsyncData(updated);
      await _repo.saveAuthState(updated);

      // Sync data from cloud
      // await _syncCloudData();
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();

    final updated = state.value!.copyWith(
      userType: UserType.guest,
      userId: null,
      email: null,
    );

    state = AsyncData(updated);
    await _repo.saveAuthState(updated);
  }

  /// Upgrade from guest to authenticated
  Future<void> upgradeAccount({
    required String email,
    required String password,
  }) async {
    if (!state.value!.isGuest) return;

    try {
      await signUp(email: email, password: password);

      // Migrate guest data to Supabase
      await _migrateGuestDataToCloud();
    } catch (e) {
      rethrow;
    }
  }

  /// Migrate local guest data to Supabase
  Future<void> _migrateGuestDataToCloud() async {
    // TODO: Implement migration logic
    // 1. Get all local tasks
    // 2. Get all local goals
    // 3. Upload to Supabase
    // 4. Update local references with Supabase IDs

    // This will be implemented when we wire up Supabase repositories
  }
}
