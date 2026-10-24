// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemoryPhoto _$MemoryPhotoFromJson(Map<String, dynamic> json) => _MemoryPhoto(
  id: json['id'] as String,
  memoryId: json['memory_id'] as String,
  spaceId: json['space_id'] as String,
  uploadedBy: json['uploaded_by'] as String?,
  position: (json['position'] as num).toDouble(),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  takenAt: json['taken_at'] == null ? null : DateTime.parse(json['taken_at'] as String),
  url: json['url'] as String?,
  thumbUrl: json['thumb_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$MemoryPhotoToJson(_MemoryPhoto instance) => <String, dynamic>{
  'id': instance.id,
  'memory_id': instance.memoryId,
  'space_id': instance.spaceId,
  'uploaded_by': instance.uploadedBy,
  'position': instance.position,
  'width': instance.width,
  'height': instance.height,
  'taken_at': instance.takenAt?.toIso8601String(),
  'url': instance.url,
  'thumb_url': instance.thumbUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
