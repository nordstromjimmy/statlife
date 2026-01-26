// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      tier: $enumDecode(_$AchievementTierEnumMap, json['tier']),
      xpReward: (json['xpReward'] as num).toInt(),
      iconPath: json['iconPath'] as String,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      targetProgress: (json['targetProgress'] as num).toInt(),
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'tier': _$AchievementTierEnumMap[instance.tier]!,
      'xpReward': instance.xpReward,
      'iconPath': instance.iconPath,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'currentProgress': instance.currentProgress,
      'targetProgress': instance.targetProgress,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.firstSteps: 'firstSteps',
  AchievementType.earlyBird: 'earlyBird',
  AchievementType.nightOwl: 'nightOwl',
  AchievementType.weekendWarrior: 'weekendWarrior',
  AchievementType.goalGetter: 'goalGetter',
  AchievementType.threeDayStreak: 'threeDayStreak',
  AchievementType.sevenDayStreak: 'sevenDayStreak',
  AchievementType.fourteenDayStreak: 'fourteenDayStreak',
  AchievementType.thirtyDayStreak: 'thirtyDayStreak',
  AchievementType.hundredDayStreak: 'hundredDayStreak',
  AchievementType.tenTasksTotal: 'tenTasksTotal',
  AchievementType.fiftyTasksTotal: 'fiftyTasksTotal',
  AchievementType.hundredTasksTotal: 'hundredTasksTotal',
  AchievementType.fiveHundredTasksTotal: 'fiveHundredTasksTotal',
  AchievementType.thousandTasksTotal: 'thousandTasksTotal',
  AchievementType.fiveTasksOneDay: 'fiveTasksOneDay',
  AchievementType.tenTasksOneDay: 'tenTasksOneDay',
  AchievementType.twentyTasksOneDay: 'twentyTasksOneDay',
  AchievementType.perfectWeek: 'perfectWeek',
  AchievementType.perfectMonth: 'perfectMonth',
  AchievementType.levelFive: 'levelFive',
  AchievementType.levelTen: 'levelTen',
  AchievementType.levelTwentyFive: 'levelTwentyFive',
  AchievementType.levelFifty: 'levelFifty',
  AchievementType.levelHundred: 'levelHundred',
};

const _$AchievementTierEnumMap = {
  AchievementTier.bronze: 'bronze',
  AchievementTier.silver: 'silver',
  AchievementTier.gold: 'gold',
  AchievementTier.diamond: 'diamond',
};
