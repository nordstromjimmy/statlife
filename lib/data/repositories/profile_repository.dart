import '../../domain/models/profile.dart';
import '../datasources/local/local_profile_repository.dart';
import '../datasources/remote/supabase_profile_datasource.dart';

class ProfileRepository {
  ProfileRepository({
    required this.localRepo,
    required this.supabaseRepo,
    required this.isAuthenticated,
  });

  final LocalProfileRepository localRepo;
  final SupabaseProfileDatasource supabaseRepo;
  final bool isAuthenticated;

  /// Get profile - from Supabase if authenticated, otherwise local
  Future<Profile?> get() async {
    if (isAuthenticated) {
      try {
        final profile = await supabaseRepo.getProfile();

        // Also save to local for offline access
        if (profile != null) {
          await localRepo.save(profile);
        }
        return profile;
      } catch (e) {
        return await localRepo.get();
      }
    }

    return await localRepo.get();
  }

  /// Save profile - to Supabase if authenticated, otherwise local
  Future<void> save(Profile profile) async {
    // Always save to local first for offline access
    await localRepo.save(profile);

    // Also save to Supabase if authenticated
    if (isAuthenticated) {
      try {
        await supabaseRepo.saveProfile(profile);
      } catch (_) {
        // Continue anyway - data is in local storage
      }
    }
  }

  /// Update name - special method for quick name updates
  Future<void> updateName(String userId, String? name) async {
    if (isAuthenticated) {
      try {
        await supabaseRepo.updateName(userId, name);
      } catch (e) {
        print(e);
      }
    }
  }
}
