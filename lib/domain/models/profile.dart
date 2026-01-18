import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,

    // User's name (optional)
    String? name,

    // Total XP earned across all time
    @Default(0) int totalXp,

    // Cached level (we will also recompute safely)
    @Default(1) int level,

    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
