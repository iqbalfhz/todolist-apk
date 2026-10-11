import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// `priority` untuk "Tandai penting". Prioritas 1 dan 2 belum dipakai di UI v0.1.
const int priorityImportant = 3;
const int priorityNone = 0;

/// Sumber tugas di kontrak.
@freezed
abstract class Task with _$Task {
  const Task._();

  const factory Task({
    required String id,
    required String taskListId,
    required String spaceId,
    required String title,
    String? notes,

    /// `YYYY-MM-DD` menurut zona waktu ruang.
    String? dueDate,

    /// `HH:MM` menurut zona waktu ruang; butuh [dueDate].
    String? dueTime,
    @Default(priorityNone) int priority,
    required double position,

    /// Satu ID berarti satu orang; dua ID berarti "Kita".
    @Default(<String>[]) List<String> assigneeIds,
    DateTime? remindAt,
    DateTime? completedAt,
    String? completedBy,
    String? createdBy,
    String? updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  bool get isCompleted => completedAt != null;

  bool get isImportant => priority >= priorityImportant;
}
