import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/savings/domain/savings_entry.dart';
import '../../features/savings/domain/savings_goal.dart';
import '../../features/spaces/domain/space.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_list.dart';
import 'app_database.dart';

/// Pemetaan antara baris drift dan model freezed.
///
/// Waktu disimpan sebagai teks ISO 8601 UTC, jadi mikrodetik dari server tidak hilang.

String _iso(DateTime value) => value.toUtc().toIso8601String();

String? _isoOrNull(DateTime? value) => value == null ? null : _iso(value);

DateTime _time(String value) => DateTime.parse(value);

DateTime? _timeOrNull(String? value) => value == null ? null : DateTime.parse(value);

Value<String?> _serverStamp(String? serverUpdatedAt) =>
    serverUpdatedAt == null ? const Value.absent() : Value(serverUpdatedAt);

extension SpaceRowMapper on SpaceRow {
  Space toModel() => Space(
    id: id,
    name: name,
    type: type,
    timezone: timezone,
    ownerId: ownerId,
    members: [
      for (final member in jsonDecode(members) as List<dynamic>) SpaceMember.fromJson(member as Map<String, dynamic>),
    ],
    createdAt: _time(createdAt),
    updatedAt: _time(updatedAt),
    deletedAt: _timeOrNull(deletedAt),
  );
}

SpacesCompanion spaceCompanion(Space space, {String? serverUpdatedAt}) => SpacesCompanion(
  id: Value(space.id),
  name: Value(space.name),
  type: Value(space.type),
  timezone: Value(space.timezone),
  ownerId: Value(space.ownerId),
  members: Value(jsonEncode([for (final member in space.members) member.toJson()])),
  createdAt: Value(_iso(space.createdAt)),
  updatedAt: Value(_iso(space.updatedAt)),
  deletedAt: Value(_isoOrNull(space.deletedAt)),
  serverUpdatedAt: _serverStamp(serverUpdatedAt),
);

extension TaskListRowMapper on TaskListRow {
  TaskList toModel() => TaskList(
    id: id,
    spaceId: spaceId,
    name: name,
    emoji: emoji,
    color: color,
    position: position,
    archivedAt: _timeOrNull(archivedAt),
    createdBy: createdBy,
    createdAt: _time(createdAt),
    updatedAt: _time(updatedAt),
    deletedAt: _timeOrNull(deletedAt),
  );
}

TaskListsCompanion taskListCompanion(TaskList list, {String? serverUpdatedAt}) => TaskListsCompanion(
  id: Value(list.id),
  spaceId: Value(list.spaceId),
  name: Value(list.name),
  emoji: Value(list.emoji),
  color: Value(list.color),
  position: Value(list.position),
  archivedAt: Value(_isoOrNull(list.archivedAt)),
  createdBy: Value(list.createdBy),
  createdAt: Value(_iso(list.createdAt)),
  updatedAt: Value(_iso(list.updatedAt)),
  deletedAt: Value(_isoOrNull(list.deletedAt)),
  serverUpdatedAt: _serverStamp(serverUpdatedAt),
);

extension TaskRowMapper on TaskRow {
  Task toModel() => Task(
    id: id,
    taskListId: taskListId,
    spaceId: spaceId,
    title: title,
    notes: notes,
    dueDate: dueDate,
    dueTime: dueTime,
    priority: priority,
    position: position,
    assigneeIds: (jsonDecode(assigneeIds) as List<dynamic>).cast<String>(),
    remindAt: _timeOrNull(remindAt),
    completedAt: _timeOrNull(completedAt),
    completedBy: completedBy,
    createdBy: createdBy,
    updatedBy: updatedBy,
    createdAt: _time(createdAt),
    updatedAt: _time(updatedAt),
    deletedAt: _timeOrNull(deletedAt),
  );
}

TasksCompanion taskCompanion(Task task, {String? serverUpdatedAt}) => TasksCompanion(
  id: Value(task.id),
  taskListId: Value(task.taskListId),
  spaceId: Value(task.spaceId),
  title: Value(task.title),
  notes: Value(task.notes),
  dueDate: Value(task.dueDate),
  dueTime: Value(task.dueTime),
  priority: Value(task.priority),
  position: Value(task.position),
  assigneeIds: Value(jsonEncode(task.assigneeIds)),
  remindAt: Value(_isoOrNull(task.remindAt)),
  completedAt: Value(_isoOrNull(task.completedAt)),
  completedBy: Value(task.completedBy),
  createdBy: Value(task.createdBy),
  updatedBy: Value(task.updatedBy),
  createdAt: Value(_iso(task.createdAt)),
  updatedAt: Value(_iso(task.updatedAt)),
  deletedAt: Value(_isoOrNull(task.deletedAt)),
  serverUpdatedAt: _serverStamp(serverUpdatedAt),
);

extension SavingsGoalRowMapper on SavingsGoalRow {
  SavingsGoal toModel() => SavingsGoal(
    id: id,
    spaceId: spaceId,
    name: name,
    emoji: emoji,
    targetAmount: targetAmount,
    currency: currency,
    targetDate: targetDate,
    achievedAt: _timeOrNull(achievedAt),
    archivedAt: _timeOrNull(archivedAt),
    createdBy: createdBy,
    createdAt: _time(createdAt),
    updatedAt: _time(updatedAt),
    deletedAt: _timeOrNull(deletedAt),
  );
}

SavingsGoalsCompanion savingsGoalCompanion(SavingsGoal goal, {String? serverUpdatedAt}) => SavingsGoalsCompanion(
  id: Value(goal.id),
  spaceId: Value(goal.spaceId),
  name: Value(goal.name),
  emoji: Value(goal.emoji),
  targetAmount: Value(goal.targetAmount),
  currency: Value(goal.currency),
  targetDate: Value(goal.targetDate),
  achievedAt: Value(_isoOrNull(goal.achievedAt)),
  archivedAt: Value(_isoOrNull(goal.archivedAt)),
  createdBy: Value(goal.createdBy),
  createdAt: Value(_iso(goal.createdAt)),
  updatedAt: Value(_iso(goal.updatedAt)),
  deletedAt: Value(_isoOrNull(goal.deletedAt)),
  serverUpdatedAt: _serverStamp(serverUpdatedAt),
);

extension SavingsEntryRowMapper on SavingsEntryRow {
  SavingsEntry toModel() => SavingsEntry(
    id: id,
    savingsGoalId: savingsGoalId,
    spaceId: spaceId,
    userId: userId,
    type: type,
    amount: amount,
    entryDate: entryDate,
    note: note,
    createdAt: _time(createdAt),
    updatedAt: _time(updatedAt),
    deletedAt: _timeOrNull(deletedAt),
  );
}

SavingsEntriesCompanion savingsEntryCompanion(SavingsEntry entry, {String? serverUpdatedAt}) => SavingsEntriesCompanion(
  id: Value(entry.id),
  savingsGoalId: Value(entry.savingsGoalId),
  spaceId: Value(entry.spaceId),
  userId: Value(entry.userId),
  type: Value(entry.type),
  amount: Value(entry.amount),
  entryDate: Value(entry.entryDate),
  note: Value(entry.note),
  createdAt: Value(_iso(entry.createdAt)),
  updatedAt: Value(_iso(entry.updatedAt)),
  deletedAt: Value(_isoOrNull(entry.deletedAt)),
  serverUpdatedAt: _serverStamp(serverUpdatedAt),
);
