// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Space _$SpaceFromJson(Map<String, dynamic> json) => _Space(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  timezone: json['timezone'] as String,
  ownerId: json['owner_id'] as String,
  members:
      (json['members'] as List<dynamic>?)?.map((e) => SpaceMember.fromJson(e as Map<String, dynamic>)).toList() ??
      const <SpaceMember>[],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SpaceToJson(_Space instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'timezone': instance.timezone,
  'owner_id': instance.ownerId,
  'members': instance.members.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SpaceMember _$SpaceMemberFromJson(Map<String, dynamic> json) => _SpaceMember(
  id: json['id'] as String,
  name: json['name'] as String,
  color: json['color'] as String,
  avatarUrl: json['avatar_url'] as String?,
  avatarVersion: (json['avatar_version'] as num?)?.toInt() ?? 0,
  role: json['role'] as String,
  joinedAt: DateTime.parse(json['joined_at'] as String),
);

Map<String, dynamic> _$SpaceMemberToJson(_SpaceMember instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'avatar_url': instance.avatarUrl,
  'avatar_version': instance.avatarVersion,
  'role': instance.role,
  'joined_at': instance.joinedAt.toIso8601String(),
};
