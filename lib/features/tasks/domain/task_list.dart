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
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _TaskList;

  factory TaskList.fromJson(Map<String, dynamic> json) => _$TaskListFromJson(json);

  /// Daftar aktif: belum dihapus dan tidak diarsipkan.
  bool get isActive => deletedAt == null && archivedAt == null;
}
