import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/logic/leveling.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/profile.dart';
import '../auth/auth_controller.dart';
import '../providers.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);

class ProfileController extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() async {
    // ✅ Watch both auth state AND userId to rebuild when either changes
    ref.watch(isAuthenticatedProvider);
    final userId = ref.watch(currentUserIdProvider);

    // ✅ Get fresh repository instance with current auth state
    final repo = ref.read(profileRepositoryProvider);

    final isAuthenticated = userId != null;

    print(
      '🔧 ProfileController.build() - isAuth: $isAuthenticated, userId: $userId',
    );

    // Try to get from repository (checks Supabase first if authenticated)
    final existing = await repo.get();

    if (existing != null) {
      print(
        '📋 Found existing profile: ID=${existing.id}, Level=${existing.level}, XP=${existing.totalXp}',
      );

      // If authenticated and profile ID doesn't match user ID, it's stale - create fresh profile
      if (isAuthenticated && existing.id != userId) {
        print(
          '⚠️ Profile ID mismatch! existing.id=${existing.id}, userId=$userId',
        );
        print('🆕 Creating fresh user profile...');

        final now = DateTime.now();
        final fresh = Profile(
          id: userId,
          name: null,
          totalXp: 0,
          level: 1,
          createdAt: now,
          updatedAt: now,
        );

        await repo.save(fresh);
        return fresh;
      }

      // Recompute level from totalXp (in case leveling logic changed)
      final computed = computeLevelFromTotalXp(existing.totalXp);
      if (computed.level != existing.level) {
        print('🔄 Level recomputed: ${existing.level} → ${computed.level}');
        final safe = existing.copyWith(level: computed.level);
        await repo.save(safe);
        return safe;
      }

      return existing;
    }

    // No existing profile found - create new one
    final now = DateTime.now();

    // IMPORTANT: Use Supabase user ID if authenticated, otherwise generate guest ID
    final profileId = userId ?? const Uuid().v4();

    print(
      '🆕 Creating new profile with ID: $profileId (${isAuthenticated ? "User" : "Guest"})',
    );

    final fresh = Profile(
      id: profileId,
      name: null,
      totalXp: 0,
      level: 1,
      createdAt: now,
      updatedAt: now,
    );

    // Save to appropriate storage
    await repo.save(fresh);

    return fresh;
  }

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  Future<void> addXp(int amount) async {
    final current = state.value!;
    final nextTotal = current.totalXp + amount;
    final computed = computeLevelFromTotalXp(nextTotal);

    print(
      '➕ Adding $amount XP: ${current.totalXp} → $nextTotal (Level ${computed.level})',
    );

    final updated = current.copyWith(
      totalXp: nextTotal,
      level: computed.level,
      updatedAt: DateTime.now(),
    );

    state = AsyncData(updated);
    await _repo.save(updated);
  }

  Future<void> updateName(String? name) async {
    final current = state.value!;
    final updated = current.copyWith(
      name: name?.trim().isEmpty ?? true ? null : name?.trim(),
      updatedAt: DateTime.now(),
    );

    state = AsyncData(updated);
    await _repo.save(updated);

    // Also update in Supabase if authenticated
    final authState = ref.read(authControllerProvider).value;

    if (authState?.isAuthenticated ?? false) {
      try {
        await _repo.updateName(current.id, updated.name);
      } catch (_) {
        //
      }
    }
  }
}
