// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskList _$TaskListFromJson(Map<String, dynamic> json) => _TaskList(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String?,
  color: json['color'] as String? ?? 'mawar',
  position: (json['position'] as num).toDouble(),
  archivedAt: json['archived_at'] == null ? null : DateTime.parse(json['archived_at'] as String),
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$TaskListToJson(_TaskList instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'name': instance.name,
  'emoji': instance.emoji,
  'color': instance.color,
  'position': instance.position,
  'archived_at': instance.archivedAt?.toIso8601String(),
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
