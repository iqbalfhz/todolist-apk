// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingsGoal _$SavingsGoalFromJson(Map<String, dynamic> json) => _SavingsGoal(
  id: json['id'] as String,
  spaceId: json['space_id'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String?,
  targetAmount: (json['target_amount'] as num).toInt(),
  currency: json['currency'] as String,
  targetDate: json['target_date'] as String?,
  reminderFrequency: json['reminder_frequency'] as String?,
  reminderDay: (json['reminder_day'] as num?)?.toInt(),
  achievedAt: json['achieved_at'] == null ? null : DateTime.parse(json['achieved_at'] as String),
  archivedAt: json['archived_at'] == null ? null : DateTime.parse(json['archived_at'] as String),
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SavingsGoalToJson(_SavingsGoal instance) => <String, dynamic>{
  'id': instance.id,
  'space_id': instance.spaceId,
  'name': instance.name,
  'emoji': instance.emoji,
  'target_amount': instance.targetAmount,
  'currency': instance.currency,
  'target_date': instance.targetDate,
  'reminder_frequency': instance.reminderFrequency,
  'reminder_day': instance.reminderDay,
  'achieved_at': instance.achievedAt?.toIso8601String(),
  'archived_at': instance.archivedAt?.toIso8601String(),
  'created_by': instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
