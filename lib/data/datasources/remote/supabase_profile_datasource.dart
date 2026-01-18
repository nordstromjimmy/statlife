import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/profile.dart';

class SupabaseProfileDatasource {
  final SupabaseClient _client;

  SupabaseProfileDatasource(this._client);

  /// Get the current user's profile
  Future<Profile?> getProfile() async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Save/update the profile
  Future<void> saveProfile(Profile profile) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    try {
      // First check if profile exists
      final existing = await _client
          .from('profiles')
          .select()
          .eq('id', profile.id)
          .maybeSingle();

      if (existing != null) {
        // Profile exists, UPDATE it
        await _client
            .from('profiles')
            .update({
              'name': profile.name,
              'total_xp': profile.totalXp,
              'level': profile.level,
              'updated_at': profile.updatedAt.toIso8601String(),
            })
            .eq('id', profile.id);
      } else {
        // Profile doesn't exist, INSERT it
        await _client.from('profiles').insert({
          'id': profile.id,
          'name': profile.name,
          'total_xp': profile.totalXp,
          'level': profile.level,
          'created_at': profile.createdAt.toIso8601String(),
          'updated_at': profile.updatedAt.toIso8601String(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update just the name field
  Future<void> updateName(String userId, String? name) async {
    try {
      final result = await _client
          .from('profiles')
          .update({
            'name': name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select();
    } catch (_) {
      //
      rethrow;
    }
  }
}
