// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingsEntry _$SavingsEntryFromJson(Map<String, dynamic> json) => _SavingsEntry(
  id: json['id'] as String,
  savingsGoalId: json['savings_goal_id'] as String,
  spaceId: json['space_id'] as String,
  userId: json['user_id'] as String?,
  type: json['type'] as String? ?? 'deposit',
  amount: (json['amount'] as num).toInt(),
  entryDate: json['entry_date'] as String,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SavingsEntryToJson(_SavingsEntry instance) => <String, dynamic>{
  'id': instance.id,
  'savings_goal_id': instance.savingsGoalId,
  'space_id': instance.spaceId,
  'user_id': instance.userId,
  'type': instance.type,
  'amount': instance.amount,
  'entry_date': instance.entryDate,
  'note': instance.note,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
