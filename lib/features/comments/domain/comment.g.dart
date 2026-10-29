// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  subjectType: json['subject_type'] as String,
  subjectId: json['subject_id'] as String,
  userId: json['user_id'] as String?,
  body: json['body'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'subject_type': instance.subjectType,
  'subject_id': instance.subjectId,
  'user_id': instance.userId,
  'body': instance.body,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_Reaction _$ReactionFromJson(Map<String, dynamic> json) => _Reaction(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  subjectType: json['subject_type'] as String,
  subjectId: json['subject_id'] as String,
  userId: json['user_id'] as String?,
  emoji: json['emoji'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$ReactionToJson(_Reaction instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'subject_type': instance.subjectType,
  'subject_id': instance.subjectId,
  'user_id': instance.userId,
  'emoji': instance.emoji,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
