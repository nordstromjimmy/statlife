// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthStateImpl _$$AuthStateImplFromJson(Map<String, dynamic> json) =>
    _$AuthStateImpl(
      userType: $enumDecode(_$UserTypeEnumMap, json['userType']),
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      hasSeenWelcome: json['hasSeenWelcome'] as bool? ?? false,
    );

Map<String, dynamic> _$$AuthStateImplToJson(_$AuthStateImpl instance) =>
    <String, dynamic>{
      'userType': _$UserTypeEnumMap[instance.userType]!,
      'userId': instance.userId,
      'email': instance.email,
      'hasSeenWelcome': instance.hasSeenWelcome,
    };

const _$UserTypeEnumMap = {
  UserType.guest: 'guest',
  UserType.authenticated: 'authenticated',
};
