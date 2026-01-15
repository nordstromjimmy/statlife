import '../../domain/models/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> get();
  Future<void> save(Profile profile);
}
