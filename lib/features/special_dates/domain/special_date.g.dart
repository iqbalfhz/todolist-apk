// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'special_date.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpecialDate _$SpecialDateFromJson(Map<String, dynamic> json) => _SpecialDate(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  type: json['type'] as String,
  title: json['title'] as String,
  date: json['date'] as String,
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SpecialDateToJson(_SpecialDate instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'type': instance.type,
  'title': instance.title,
  'date': instance.date,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
