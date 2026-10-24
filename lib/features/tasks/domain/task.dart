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

    /// Aturan ulang (v1.0): `daily`, `weekly`, `monthly`, `yearly`, atau `null`. Baca lewat [repeat].
    String? repeatFrequency,

    /// Setiap berapa hari, minggu, bulan, atau tahun (1–99); `null` kalau tidak berulang.
    int? repeatInterval,
    DateTime? remindAt,
    DateTime? completedAt,
    String? completedBy,

    /// Tugas berikutnya yang dibuat server saat tugas berulang ini selesai (v1.0).
    String? nextTaskId,
    String? createdBy,
    String? updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  bool get isCompleted => completedAt != null;

  bool get isImportant => priority >= priorityImportant;

  /// Aturan ulang yang dikenal app, atau `null` kalau tidak berulang.
  TaskRepeat? get repeat => TaskRepeat.tryFrom(repeatFrequency, repeatInterval);
}

/// Seberapa sering tugas diulang. Namanya sama dengan nilai `repeat_frequency` di kontrak.
enum RepeatFrequency { daily, weekly, monthly, yearly }

/// Aturan ulang tugas (v1.0): setiap [interval] hari, minggu, bulan, atau tahun, dengan
/// `due_date` sebagai patokan. Tugas berikutnya dibuat server saat tugas ini selesai.
class TaskRepeat {
  const TaskRepeat(this.frequency, [this.interval = 1]);

  final RepeatFrequency frequency;
  final int interval;

  /// Batas `repeat_interval` di kontrak.
  static const int maxInterval = 99;

  /// Aturan yang tidak dikenal atau di luar batas dianggap tidak ada. Tanpa `repeat_interval`,
  /// bawaannya 1, sama dengan server.
  static TaskRepeat? tryFrom(String? frequency, int? interval) {
    final parsed = RepeatFrequency.values.where((value) => value.name == frequency).firstOrNull;
    final every = interval ?? 1;
    if (parsed == null || every < 1 || every > maxInterval) return null;
    return TaskRepeat(parsed, every);
  }

  @override
  bool operator ==(Object other) => other is TaskRepeat && other.frequency == frequency && other.interval == interval;

  @override
  int get hashCode => Object.hash(frequency, interval);

  @override
  String toString() => 'TaskRepeat($frequency, $interval)';
}
