import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_list.freezed.dart';
part 'task_list.g.dart';

/// Sumber daftar di kontrak.
@freezed
abstract class TaskList with _$TaskList {
  const TaskList._();

  const factory TaskList({
    required String id,
    required String spaceId,
    required String name,
    String? emoji,
    @Default('mawar') String color,
    required double position,
    DateTime? archivedAt,

    /// Perjalanan yang checklist persiapannya adalah daftar ini (v0.2).
    String? tripId,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TaskList;

  factory TaskList.fromJson(Map<String, dynamic> json) => _$TaskListFromJson(json);

  /// Daftar aktif: belum dihapus dan tidak diarsipkan. Termasuk checklist perjalanan,
  /// supaya tugas di dalamnya tetap tampil di Tugas hari ini.
  bool get isActive => deletedAt == null && archivedAt == null;

  /// Checklist persiapan perjalanan: tidak tampil di daftar biasa, tidak dipakai tambah cepat,
  /// dan tidak dihitung sebagai daftar aktif terakhir.
  bool get isChecklist => tripId != null;

  /// Daftar aktif yang bukan checklist perjalanan.
  bool get isRegularActive => isActive && !isChecklist;
}
