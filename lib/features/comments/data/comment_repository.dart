import '../../../core/database/entity_type.dart';
import '../../../core/database/local_writer.dart';
import '../../../core/utils/ulid.dart';
import '../../../core/utils/validators.dart';
import '../domain/comment.dart';

/// Komentar dan reaksi (v1.x): dibaca dari cache lokal, ditulis lewat antrean.
///
/// Hanya untuk subjek di Ruang Bersama; layarnya tidak menawarkan komentar di Ruang Pribadi.
/// Hanya penulis yang boleh mengubah dan menghapus komentarnya, dan hanya pemilik reaksi yang
/// boleh menghapusnya; server menolak yang lain dengan 403 `forbidden`.
class CommentRepository {
  CommentRepository({required this.writer, required this.userId});

  final LocalWriter writer;
  final String userId;

  Stream<List<Comment>> watchComments() => writer.store.watchComments();

  Stream<List<Reaction>> watchReactions() => writer.store.watchReactions();

  /// Tulis komentar pada [subject] di ruang [spaceId].
  Future<Comment> addComment({required Subject subject, required String spaceId, required String body}) async {
    final nowIso = writer.nowIso();
    final payload = <String, dynamic>{
      'subject_type': subject.type.value,
      'subject_id': subject.id,
      'body': _cleanBody(body),
    };
    final row = <String, dynamic>{
      ...payload,
      'id': newUlid(now: writer.now()),
      'space_id': spaceId,
      'user_id': userId,
      'created_at': nowIso,
      'updated_at': nowIso,
      'deleted_at': null,
    };

    await writer.create(EntityType.comment, row, payload);
    return Comment.fromJson(row);
  }

  /// Ubah isi komentar sendiri. `updated_at` lokal ikut diperbarui, supaya tanda "diedit"
  /// langsung tampil sebelum balasan server tiba.
  Future<void> editComment(String id, String body) =>
      writer.update(EntityType.comment, id, {'body': _cleanBody(body)}, localOnly: {'updated_at': writer.nowIso()});

  /// Hapus komentar sendiri dengan jeda Urungkan 5 detik. Mengembalikan ID operasi untuk [undo].
  Future<int?> deleteComment(String id) => writer.delete(EntityType.comment, id, undoable: true);

  /// Urungkan hapus komentar. `false` kalau operasinya sudah terlanjur dikirim.
  Future<bool> undo(int opId) => writer.outbox.undo(opId);

  /// Beri reaksi [emoji] pada [subject], menggantikan reaksiku sebelumnya di subjek itu.
  ///
  /// Server menghapus reaksi lama sendiri saat menerima yang baru, jadi di HP reaksi lama
  /// cukup ditandai terhapus. Reaksi lama yang belum sempat terkirim dibatalkan sama sekali.
  Future<void> react({required Subject subject, required String spaceId, required String emoji}) async {
    final clean = _cleanEmoji(emoji);
    await writer.store.transaction(() async {
      final mine = await writer.store.reactionsBy(userId, subject.id);
      if (mine.length == 1 && mine.single.emoji == clean) return;

      final cancelled = await writer.outbox.cancelUnsentCreates(EntityType.reaction, [
        for (final reaction in mine) reaction.id,
      ]);
      for (final reaction in mine) {
        if (!cancelled.contains(reaction.id)) {
          await writer.store.patch(EntityType.reaction, reaction.id, {'deleted_at': writer.nowIso()});
        }
      }

      final nowIso = writer.nowIso();
      final payload = <String, dynamic>{'subject_type': subject.type.value, 'subject_id': subject.id, 'emoji': clean};
      final row = <String, dynamic>{
        ...payload,
        'id': newUlid(now: writer.now()),
        'space_id': spaceId,
        'user_id': userId,
        'created_at': nowIso,
        'updated_at': nowIso,
        'deleted_at': null,
      };
      await writer.create(EntityType.reaction, row, payload);
    });
  }

  /// Hapus reaksiku pada [subjectId]. Yang belum sempat terkirim dibatalkan tanpa request.
  Future<void> removeReaction(String subjectId) => writer.store.transaction(() async {
    final mine = await writer.store.reactionsBy(userId, subjectId);
    final cancelled = await writer.outbox.cancelUnsentCreates(EntityType.reaction, [
      for (final reaction in mine) reaction.id,
    ]);
    for (final reaction in mine) {
      if (!cancelled.contains(reaction.id)) await writer.delete(EntityType.reaction, reaction.id);
    }
  });

  // ---------------------------------------------------------------- validasi

  /// Isi komentar dirapikan, 1–1.000 karakter seperti di server.
  static String _cleanBody(String body) {
    final clean = body.trim();
    if (!isValidRequiredText(clean, Limits.commentBody)) {
      throw ArgumentError.value(body, 'body', 'Komentar wajib diisi, paling banyak ${Limits.commentBody} karakter.');
    }
    return clean;
  }

  static String _cleanEmoji(String emoji) {
    final clean = emoji.trim();
    if (!isSingleEmoji(clean) || textLength(clean) > Limits.emoji) {
      throw ArgumentError.value(emoji, 'emoji', 'Reaksi harus satu emoji.');
    }
    return clean;
  }
}
