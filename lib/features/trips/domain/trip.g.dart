// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trip _$TripFromJson(Map<String, dynamic> json) => _Trip(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  title: json['title'] as String,
  destination: json['destination'] as String?,
  startDate: json['start_date'] as String?,
  endDate: json['end_date'] as String?,
  notes: json['notes'] as String?,
  savingsGoalId: json['savings_goal_id'] as String?,
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$TripToJson(_Trip instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'title': instance.title,
  'destination': instance.destination,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'notes': instance.notes,
  'savings_goal_id': instance.savingsGoalId,
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
