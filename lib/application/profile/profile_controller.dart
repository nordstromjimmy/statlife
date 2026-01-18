import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/logic/leveling.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/profile.dart';
import '../auth/auth_controller.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);

class ProfileController extends AsyncNotifier<Profile> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  Future<Profile> build() async {
    // WAIT for auth state to load first
    final authState = await ref.watch(authControllerProvider.future);
    final supabaseUserId = Supabase.instance.client.auth.currentUser?.id;

    // Try to get from repository (checks Supabase first if authenticated)
    final existing = await _repo.get();

    if (existing != null) {
      // If we have a local profile but now we're authenticated with different ID, fetch from Supabase
      if (authState.isAuthenticated &&
          supabaseUserId != null &&
          existing.id != supabaseUserId) {
        final supabaseProfile = await _repo
            .get(); // This will fetch from Supabase
        if (supabaseProfile != null && supabaseProfile.id == supabaseUserId) {
          return supabaseProfile;
        }
      }

      final computed = computeLevelFromTotalXp(existing.totalXp);
      final safe = existing.copyWith(level: computed.level);
      if (safe.level != existing.level) {
        await _repo.save(safe);
      }
      return safe;
    }

    // No existing profile found
    final now = DateTime.now();

    // IMPORTANT: Use Supabase user ID if authenticated
    final profileId = supabaseUserId ?? const Uuid().v4();

    final fresh = Profile(
      id: profileId,
      name: null,
      totalXp: 0,
      level: 1,
      createdAt: now,
      updatedAt: now,
    );

    // Save to local storage (Supabase already has it via trigger for authenticated users)
    await _repo.localRepo.save(fresh);

    return fresh;
  }

  Future<void> addXp(int amount) async {
    final current = state.value!;
    final nextTotal = current.totalXp + amount;
    final computed = computeLevelFromTotalXp(nextTotal);

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
