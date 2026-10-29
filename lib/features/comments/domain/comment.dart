import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

/// Jenis subjek komentar dan reaksi (v1.x), sama dengan nilai `subject_type` di kontrak.
enum SubjectType {
  task('task'),

  /// Setoran atau penarikan.
  savingsEntry('savings_entry'),
  memory('memory');

  const SubjectType(this.value);

  final String value;

  static SubjectType? tryParse(String? value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// Data yang dikomentari atau diberi reaksi. Hanya data di Ruang Bersama.
class Subject {
  const Subject(this.type, this.id);

  final SubjectType type;
  final String id;

  @override
  bool operator ==(Object other) => other is Subject && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

/// Sumber komentar di kontrak (v1.x). Hanya penulisnya yang boleh mengubah dan menghapus.
@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String spaceId,
    required String subjectType,
    required String subjectId,

    /// Penulis; diisi server.
    String? userId,
    required String body,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}

extension CommentEdited on Comment {
  /// Sudah diubah setelah ditulis: `updated_at` lebih baru dari `created_at` (kontrak).
  bool get isEdited => updatedAt.isAfter(createdAt);
}

/// Sumber reaksi di kontrak (v1.x). Satu reaksi per orang per subjek; tanpa `PATCH`, jadi
/// mengganti emoji berarti reaksi baru dengan ID baru.
@freezed
abstract class Reaction with _$Reaction {
  const factory Reaction({
    required String id,
    required String spaceId,
    required String subjectType,
    required String subjectId,

    /// Pemilik reaksi; diisi server.
    String? userId,
    required String emoji,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Reaction;

  factory Reaction.fromJson(Map<String, dynamic> json) => _$ReactionFromJson(json);
}
