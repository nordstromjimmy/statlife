import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/profile_repository.dart';
import '../../domain/logic/leveling.dart';
import '../../domain/models/profile.dart';
import '../providers.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);

class ProfileController extends AsyncNotifier<Profile> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  Future<Profile> build() async {
    final existing = await _repo.get();
    if (existing != null) {
      final computed = computeLevelFromTotalXp(existing.totalXp);
      final safe = existing.copyWith(level: computed.level);
      if (safe.level != existing.level) {
        await _repo.save(safe);
      }
      return safe;
    }

    final now = DateTime.now();
    final fresh = Profile(
      id: const Uuid().v4(),
      name: null,
      totalXp: 0,
      level: 1,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.save(fresh);
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
  }
}
