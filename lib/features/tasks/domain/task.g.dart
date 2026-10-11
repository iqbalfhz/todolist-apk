// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  taskListId: json['task_list_id'] as String,
  spaceId: json['space_id'] as String,
  title: json['title'] as String,
  notes: json['notes'] as String?,
  dueDate: json['due_date'] as String?,
  dueTime: json['due_time'] as String?,
  priority: (json['priority'] as num?)?.toInt() ?? priorityNone,
  position: (json['position'] as num).toDouble(),
  assigneeIds: (json['assignee_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  remindAt: json['remind_at'] == null ? null : DateTime.parse(json['remind_at'] as String),
  completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at'] as String),
  completedBy: json['completed_by'] as String?,
  createdBy: json['created_by'] as String?,
  updatedBy: json['updated_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null ? null : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'task_list_id': instance.taskListId,
  'space_id': instance.spaceId,
  'title': instance.title,
  'notes': instance.notes,
  'due_date': instance.dueDate,
  'due_time': instance.dueTime,
  'priority': instance.priority,
  'position': instance.position,
  'assignee_ids': instance.assigneeIds,
  'remind_at': instance.remindAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'completed_by': instance.completedBy,
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
