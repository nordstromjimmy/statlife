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

  /// Returns the user ID but doesn't update state yet (for migration)
  Future<String?> signUpWithoutStateUpdate({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return response.user!.id;
      }
      return null;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Update auth state after signup/migration is complete
  Future<void> updateAuthState({
    required String userId,
    required String email,
  }) async {
    final newState = AuthState(
      userType: UserType.authenticated,
      userId: userId,
      email: email,
      hasSeenWelcome: true,
    );

    state = AsyncData(newState);
    await _repo.saveAuthState(newState);
  }

  /// Original signUp method (for non-migration cases)
  Future<void> signUp({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // Update auth state
        final newState = AuthState(
          userType: UserType.authenticated,
          userId: userId,
          email: email,
          hasSeenWelcome: true,
        );

        state = AsyncData(newState);
        await _repo.saveAuthState(newState);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Sign in with email/password
  /// Note: Migration should be handled in the UI before calling this
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // Update auth state
        final newState = AuthState(
          userType: UserType.authenticated,
          userId: userId,
          email: email,
          hasSeenWelcome: true,
        );

        state = AsyncData(newState);
        await _repo.saveAuthState(newState);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
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
}
