import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
//part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,

    // User's name (optional)
    String? name,

    // Total XP earned across all time
    @Default(0) @JsonKey(name: 'total_xp') int totalXp,

    // Cached level (we will also recompute safely)
    @Default(1) int level,

    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String?,
      totalXp: (json['total_xp'] as int?) ?? 0,
      level: (json['level'] as int?) ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

// Extension to add toJson method
extension ProfileJson on Profile {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_xp': totalXp,
      'level': level,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
