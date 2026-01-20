import '../../domain/models/profile.dart';
import '../datasources/local/local_profile_repository.dart';
import '../datasources/remote/supabase_profile_datasource.dart';

class ProfileRepository {
  ProfileRepository({
    required this.localRepo,
    required this.supabaseRepo,
    required this.isAuthenticated,
    this.userId,
  }) {
    print(
      '🏗️ ProfileRepository created: isAuth=$isAuthenticated, userId=$userId',
    );
  }

  final LocalProfileRepository localRepo;
  final SupabaseProfileDatasource supabaseRepo;
  final bool isAuthenticated;
  final String? userId;

  /// Get profile
  /// - Guest: Fetch from local storage with guest prefix
  /// - Authenticated: Fetch from Supabase, cache locally with user prefix
  Future<Profile?> get() async {
    print(
      '📖 ProfileRepository.get() called: isAuth=$isAuthenticated, userId=$userId',
    );

    if (isAuthenticated && userId != null) {
      try {
        print('📥 [User: $userId] Fetching profile from Supabase...');
        final profile = await supabaseRepo.getProfile();
        print(
          '✅ Fetched profile from Supabase: Level ${profile?.level}, XP ${profile?.totalXp}',
        );

        // Cache to local storage with user-specific key
        if (profile != null) {
          try {
            print('💾 Caching to local with userId: $userId');
            await localRepo.save(profile, userId: userId);
            print('✅ Cached profile to local storage');
          } catch (e) {
            print('⚠️ Failed to cache profile: $e');
          }
        }
        return profile;
      } catch (e) {
        print('❌ Supabase fetch failed, using local cache: $e');
        try {
          return await localRepo.get(userId: userId);
        } catch (localError) {
          print('❌ Local cache also failed: $localError');
          return null;
        }
      }
    }

    // Guest mode: use local storage only
    print('📱 [Guest] Fetching profile from local storage...');
    try {
      final profile = await localRepo.get(); // No userId = guest prefix
      if (profile != null) {
        print(
          '✅ Fetched guest profile: Level ${profile.level}, XP ${profile.totalXp}',
        );
      } else {
        print('ℹ️ No guest profile found');
      }
      return profile;
    } catch (e) {
      print('❌ Failed to load guest profile: $e');
      return null;
    }
  }

  /// Save profile
  /// - Guest: Save to local only
  /// - Authenticated: Save to local + sync to Supabase
  Future<void> save(Profile profile) async {
    print(
      '💾 ProfileRepository.save() called: isAuth=$isAuthenticated, userId=$userId',
    );
    print(
      '   Profile to save: ID=${profile.id}, Level=${profile.level}, XP=${profile.totalXp}',
    );

    if (isAuthenticated && userId != null) {
      print('💾 [User: $userId] Saving profile...');

      // Save to local with user-specific key
      try {
        print('   Saving to local with userId: $userId');
        await localRepo.save(profile, userId: userId);
        print('✅ Saved to local cache (user)');
      } catch (e) {
        print('⚠️ Failed to save locally: $e');
      }

      // Sync to Supabase
      try {
        await supabaseRepo.saveProfile(profile);
        print('✅ Synced to Supabase');
      } catch (e) {
        print('❌ Supabase sync failed: $e');
      }
    } else {
      // Guest mode: save to local only
      print('💾 [Guest] Saving profile...');
      print('   Saving to local WITHOUT userId (guest mode)');
      await localRepo.save(profile); // No userId = guest prefix
      print('✅ Saved to guest local storage');
    }
  }

  /// Update name - special method for quick name updates
  Future<void> updateName(String userId, String? name) async {
    if (isAuthenticated) {
      try {
        await supabaseRepo.updateName(userId, name);
      } catch (e) {
        print('❌ Failed to update name: $e');
      }
    }
  }
}
