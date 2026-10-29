// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Memory _$MemoryFromJson(Map<String, dynamic> json) => _Memory(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  tripId: json['trip_id'] as String?,
  title: json['title'] as String,
  placeName: json['place_name'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  visitedOn: json['visited_on'] as String,
  story: json['story'] as String?,
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$MemoryToJson(_Memory instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'trip_id': instance.tripId,
  'title': instance.title,
  'place_name': instance.placeName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'visited_on': instance.visitedOn,
  'story': instance.story,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
