import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../spaces/domain/household.dart';
import 'comment.dart';

/// Pilihan reaksi di app. Server menerima emoji apa pun (1–16 code point), jadi reaksi lain
/// yang datang dari server tetap tampil.
const List<String> reactionChoices = ['❤️', '😂', '😍', '👍', '🥺', '🎉'];

/// Satu emoji beserta orang yang memberinya, urut siapa yang lebih dulu.
class ReactionGroup {
  const ReactionGroup({required this.emoji, required this.userIds});

  final String emoji;
  final List<String> userIds;
}

/// Komentar dan reaksi satu subjek.
class Conversation {
  const Conversation({required this.comments, required this.reactions, this.mine});

  static const Conversation empty = Conversation(comments: [], reactions: []);

  /// Yang terlama dulu (kontrak: urut `created_at`).
  final List<Comment> comments;

  /// Urut kemunculan emojinya.
  final List<ReactionGroup> reactions;

  /// Reaksiku, kalau ada.
  final Reaction? mine;

  bool get isEmpty => comments.isEmpty && reactions.isEmpty;

  int get reactionCount => reactions.fold(0, (sum, group) => sum + group.userIds.length);
}

/// Kelompokkan komentar dan reaksi per subjek.
///
/// Satu orang hanya punya satu reaksi per subjek. Selama reaksi lama belum terhapus di HP
/// (misalnya reaksi baru masih di antrean saat sync menarik yang lama), yang terbaru yang
/// dipakai. Reaksi dan komentar tanpa `user_id` dianggap milik [meId], seperti setoran.
Map<String, Conversation> buildConversations({
  required List<Comment> comments,
  required List<Reaction> reactions,
  required String meId,
}) {
  final commentsBySubject = <String, List<Comment>>{};
  for (final comment in comments) {
    if (comment.deletedAt == null) commentsBySubject.putIfAbsent(comment.subjectId, () => []).add(comment);
  }

  // Reaksi terbaru tiap orang per subjek.
  final latest = <String, Map<String, Reaction>>{};
  for (final reaction in reactions) {
    if (reaction.deletedAt != null) continue;
    final byUser = latest.putIfAbsent(reaction.subjectId, () => {});
    final user = reaction.userId ?? meId;
    final current = byUser[user];
    if (current == null || _compare(reaction, current) > 0) byUser[user] = reaction;
  }

  final subjects = {...commentsBySubject.keys, ...latest.keys};
  return {
    for (final subjectId in subjects)
      subjectId: _conversation(commentsBySubject[subjectId] ?? const [], latest[subjectId] ?? const {}, meId),
  };
}

Conversation _conversation(List<Comment> comments, Map<String, Reaction> byUser, String meId) {
  final sortedComments = [...comments]
    ..sort((a, b) {
      final byTime = a.createdAt.compareTo(b.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });

  final kept = byUser.values.toList()..sort(_compare);
  final groups = <String, List<String>>{};
  for (final reaction in kept) {
    groups.putIfAbsent(reaction.emoji, () => []).add(reaction.userId ?? meId);
  }

  return Conversation(
    comments: sortedComments,
    reactions: [for (final entry in groups.entries) ReactionGroup(emoji: entry.key, userIds: entry.value)],
    mine: byUser[meId],
  );
}

/// Urutan reaksi: yang lebih dulu dibuat dulu; ID ULID memecah seri.
int _compare(Reaction a, Reaction b) {
  final byTime = a.createdAt.compareTo(b.createdAt);
  return byTime != 0 ? byTime : a.id.compareTo(b.id);
}

/// Komentar dan reaksi semua subjek, per `subject_id`; `null` selama cache belum terbaca.
final conversationsProvider = Provider<Map<String, Conversation>?>((ref) {
  final comments = ref.watch(commentsProvider).value;
  final reactions = ref.watch(reactionsProvider).value;
  final household = ref.watch(householdProvider);
  if (comments == null || reactions == null || household == null) return null;
  return buildConversations(comments: comments, reactions: reactions, meId: household.me.id);
});

/// Percakapan satu subjek; kosong selama belum ada atau cache belum terbaca.
Conversation conversationOf(Map<String, Conversation>? conversations, String subjectId) =>
    conversations?[subjectId] ?? Conversation.empty;
