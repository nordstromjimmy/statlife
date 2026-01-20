import '../../domain/models/profile.dart';
import '../datasources/local/local_profile_repository.dart';
import '../datasources/remote/supabase_profile_datasource.dart';

class ProfileRepository {
  ProfileRepository({
    required this.localRepo,
    required this.supabaseRepo,
    required this.isAuthenticated,
    this.userId,
  });

  final LocalProfileRepository localRepo;
  final SupabaseProfileDatasource supabaseRepo;
  final bool isAuthenticated;
  final String? userId;

  /// Get profile
  /// - Guest: Fetch from local storage with guest prefix
  /// - Authenticated: Fetch from Supabase, cache locally with user prefix
  Future<Profile?> get() async {
    if (isAuthenticated && userId != null) {
      try {
        final profile = await supabaseRepo.getProfile();

        // Cache to local storage with user-specific key
        if (profile != null) {
          try {
            await localRepo.save(profile, userId: userId);
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
          return null;
        }
      }
    }

    // Guest mode: use local storage only
    try {
      final profile = await localRepo.get(); // No userId = guest prefix
      if (profile != null) {
      } else {
        print('ℹ️ No guest profile found');
      }
      return profile;
    } catch (e) {
      return null;
    }
  }

  /// Save profile
  /// - Guest: Save to local only
  /// - Authenticated: Save to local + sync to Supabase
  Future<void> save(Profile profile) async {
    if (isAuthenticated && userId != null) {
      // Save to local with user-specific key
      try {
        await localRepo.save(profile, userId: userId);
      } catch (e) {
        print('⚠️ Failed to save locally: $e');
      }

      // Sync to Supabase
      try {
        await supabaseRepo.saveProfile(profile);
      } catch (e) {
        print('❌ Supabase sync failed: $e');
      }
    } else {
      // Guest mode: save to local only
      await localRepo.save(profile); // No userId = guest prefix
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
