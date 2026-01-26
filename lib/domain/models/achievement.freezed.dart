// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  AchievementType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  AchievementTier get tier => throw _privateConstructorUsedError;
  int get xpReward => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;
  DateTime? get unlockedAt =>
      throw _privateConstructorUsedError; // null = locked
  int get currentProgress => throw _privateConstructorUsedError;
  int get targetProgress => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
    Achievement value,
    $Res Function(Achievement) then,
  ) = _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call({
    AchievementType type,
    String title,
    String description,
    AchievementTier tier,
    int xpReward,
    String iconPath,
    DateTime? unlockedAt,
    int currentProgress,
    int targetProgress,
  });
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? tier = null,
    Object? xpReward = null,
    Object? iconPath = null,
    Object? unlockedAt = freezed,
    Object? currentProgress = null,
    Object? targetProgress = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AchievementType,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as AchievementTier,
            xpReward: null == xpReward
                ? _value.xpReward
                : xpReward // ignore: cast_nullable_to_non_nullable
                      as int,
            iconPath: null == iconPath
                ? _value.iconPath
                : iconPath // ignore: cast_nullable_to_non_nullable
                      as String,
            unlockedAt: freezed == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            currentProgress: null == currentProgress
                ? _value.currentProgress
                : currentProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            targetProgress: null == targetProgress
                ? _value.targetProgress
                : targetProgress // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
    _$AchievementImpl value,
    $Res Function(_$AchievementImpl) then,
  ) = __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AchievementType type,
    String title,
    String description,
    AchievementTier tier,
    int xpReward,
    String iconPath,
    DateTime? unlockedAt,
    int currentProgress,
    int targetProgress,
  });
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
    _$AchievementImpl _value,
    $Res Function(_$AchievementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? tier = null,
    Object? xpReward = null,
    Object? iconPath = null,
    Object? unlockedAt = freezed,
    Object? currentProgress = null,
    Object? targetProgress = null,
  }) {
    return _then(
      _$AchievementImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AchievementType,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as AchievementTier,
        xpReward: null == xpReward
            ? _value.xpReward
            : xpReward // ignore: cast_nullable_to_non_nullable
                  as int,
        iconPath: null == iconPath
            ? _value.iconPath
            : iconPath // ignore: cast_nullable_to_non_nullable
                  as String,
        unlockedAt: freezed == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        currentProgress: null == currentProgress
            ? _value.currentProgress
            : currentProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        targetProgress: null == targetProgress
            ? _value.targetProgress
            : targetProgress // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl({
    required this.type,
    required this.title,
    required this.description,
    required this.tier,
    required this.xpReward,
    required this.iconPath,
    this.unlockedAt,
    this.currentProgress = 0,
    required this.targetProgress,
  });

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final AchievementType type;
  @override
  final String title;
  @override
  final String description;
  @override
  final AchievementTier tier;
  @override
  final int xpReward;
  @override
  final String iconPath;
  @override
  final DateTime? unlockedAt;
  // null = locked
  @override
  @JsonKey()
  final int currentProgress;
  @override
  final int targetProgress;

  @override
  String toString() {
    return 'Achievement(type: $type, title: $title, description: $description, tier: $tier, xpReward: $xpReward, iconPath: $iconPath, unlockedAt: $unlockedAt, currentProgress: $currentProgress, targetProgress: $targetProgress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.targetProgress, targetProgress) ||
                other.targetProgress == targetProgress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    title,
    description,
    tier,
    xpReward,
    iconPath,
    unlockedAt,
    currentProgress,
    targetProgress,
  );

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(this);
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement({
    required final AchievementType type,
    required final String title,
    required final String description,
    required final AchievementTier tier,
    required final int xpReward,
    required final String iconPath,
    final DateTime? unlockedAt,
    final int currentProgress,
    required final int targetProgress,
  }) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  AchievementType get type;
  @override
  String get title;
  @override
  String get description;
  @override
  AchievementTier get tier;
  @override
  int get xpReward;
  @override
  String get iconPath;
  @override
  DateTime? get unlockedAt; // null = locked
  @override
  int get currentProgress;
  @override
  int get targetProgress;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
