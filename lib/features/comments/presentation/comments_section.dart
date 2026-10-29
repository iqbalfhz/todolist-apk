import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/time/space_clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/presentation/member_avatar.dart';
import '../../tasks/presentation/task_actions.dart';
import '../../tasks/presentation/task_text.dart';
import '../domain/comment.dart';
import '../domain/conversation.dart';

/// Nama orang di komentar dan reaksi, sama seperti di riwayat setoran: "Aku" atau "Pasangan".
String personLabel(AppLocalizations l10n, Household household, String? userId) {
  if (userId == null || userId == household.me.id) return l10n.labelMe;
  if (userId == household.partner?.id) return l10n.labelPartner;
  return l10n.savingsContributionFormer;
}

/// Reaksi dan komentar satu subjek di Ruang Bersama (v1.x): baris reaksi emoji, daftar
/// komentar (yang terlama dulu), dan kolom untuk menulis komentar. Semuanya lewat antrean,
/// jadi tetap bisa dipakai saat offline.
class CommentsSection extends ConsumerStatefulWidget {
  const CommentsSection({super.key, required this.subject, required this.spaceId, required this.household});

  final Subject subject;
  final String spaceId;
  final Household household;

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final TextEditingController _draft = TextEditingController();
  bool _picking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _draft.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _draft.text.trim();
    if (body.isEmpty) return;
    if (textLength(body) > Limits.commentBody) {
      setState(() => _error = context.l10n.commentTooLong);
      return;
    }

    final account = ref.read(accountProvider);
    if (account == null) return;
    _draft.clear();
    setState(() => _error = null);
    await account.comments.addComment(subject: widget.subject, spaceId: widget.spaceId, body: body);
  }

  Future<void> _react(String emoji, Conversation conversation) async {
    final account = ref.read(accountProvider);
    if (account == null) return;
    setState(() => _picking = false);

    // Mengetuk reaksiku sendiri berarti mencabutnya.
    if (conversation.mine?.emoji == emoji) {
      await account.comments.removeReaction(widget.subject.id);
    } else {
      await account.comments.react(subject: widget.subject, spaceId: widget.spaceId, emoji: emoji);
    }
  }

  Future<void> _edit(Comment comment) async {
    final body = await showAppSheet<String>(context, builder: (_) => _EditCommentSheet(initial: comment.body));
    if (body == null) return;
    await ref.read(accountProvider)?.comments.editComment(comment.id, body);
  }

  Future<void> _delete(Comment comment) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final account = ref.read(accountProvider);
    final opId = await account?.comments.deleteComment(comment.id);
    if (opId == null || account == null) return;

    showUndoSnackBar(
      messenger,
      message: l10n.commentDeleted,
      undoLabel: l10n.commonUndo,
      onUndo: () => account.comments.undo(opId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final household = widget.household;
    final conversation = conversationOf(ref.watch(conversationsProvider), widget.subject.id);
    final clock = ref.watch(spaceClockProvider);
    final timezone = household.timezoneOf(widget.spaceId);
    final today = clock.today(timezone);
    final comments = conversation.comments;
    final draft = _draft.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: SectionTitle(l10n.commentsTitle)),
            if (comments.isNotEmpty) Text(l10n.commentsCount(comments.length), style: text.caption),
          ],
        ),
        const SizedBox(height: AppDimens.gap10),
        AppCard(
          semanticLabel: l10n.commentsTitle,
          padding: const EdgeInsets.fromLTRB(
            AppDimens.cardPadding,
            AppDimens.gap12,
            AppDimens.cardPadding,
            AppDimens.gap12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppDimens.gap8,
                runSpacing: AppDimens.gap8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final group in conversation.reactions)
                    _ReactionChip(group: group, household: household, onTap: () => _react(group.emoji, conversation)),
                  AppIconButton(
                    icon: _picking ? Symbols.close_rounded : Symbols.add_reaction_rounded,
                    label: _picking ? l10n.reactionClose : l10n.reactionAdd,
                    outlined: true,
                    iconSize: AppDimens.iconLg,
                    onPressed: () => setState(() => _picking = !_picking),
                  ),
                ],
              ),
              if (_picking) ...[
                const SizedBox(height: AppDimens.gap8),
                Wrap(
                  spacing: AppDimens.gap4,
                  runSpacing: AppDimens.gap4,
                  children: [
                    for (final emoji in reactionChoices)
                      _EmojiChoice(
                        emoji: emoji,
                        selected: conversation.mine?.emoji == emoji,
                        onTap: () => _react(emoji, conversation),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppDimens.gap10),
              const RowDivider(),
              if (comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.gap12),
                  child: Text(l10n.commentsEmpty, style: text.caption),
                ),
              for (final (index, comment) in comments.indexed) ...[
                if (index > 0) const RowDivider(),
                _CommentRow(
                  key: ValueKey(comment.id),
                  comment: comment,
                  household: household,
                  when: _when(l10n, clock.wallClock(comment.createdAt, timezone), today),
                  onEdit: () => _edit(comment),
                  onDelete: () => _delete(comment),
                ),
              ],
              const SizedBox(height: AppDimens.gap8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _draft,
                      style: text.input,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(hintText: l10n.commentHint, errorText: _error),
                    ),
                  ),
                  const SizedBox(width: AppDimens.gap8),
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.gap4),
                    child: AppIconButton(
                      icon: Symbols.send_rounded,
                      label: l10n.commentSend,
                      outlined: true,
                      iconSize: AppDimens.iconLg,
                      onPressed: draft.isEmpty ? null : _send,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// "Hari ini, 19.00", "Kemarin, 08.12", atau "Sel, 6 Okt, 19.00", di zona waktu ruangnya.
  static String _when(AppLocalizations l10n, ZonedNow wall, String today) =>
      l10n.dueWithTime(dayLabel(l10n, wall.date, today: today), formatClock(wall.time));
}

/// Satu emoji yang sudah diberikan, dengan titik warna orang yang memberinya. Reaksiku
/// ditandai seperti chip terpilih; mengetuknya mencabut reaksiku, mengetuk reaksi pasangan
/// memberi emoji yang sama.
class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.group, required this.household, required this.onTap});

  final ReactionGroup group;
  final Household household;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final mine = group.userIds.contains(household.me.id);
    final people = [for (final userId in group.userIds) personLabel(l10n, household, userId)];

    // Node sendiri, supaya tiap chip bisa dipilih pembaca layar, bukan tergabung ke kartunya.
    return Semantics(
      container: true,
      button: true,
      selected: mine,
      label: l10n.reactionBy(group.emoji, people.join(l10n.listAnd)),
      excludeSemantics: true,
      child: Material(
        color: mine ? palette.soft : palette.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: mine ? palette.primary : palette.line,
            width: mine ? AppDimens.borderWidthSelected : AppDimens.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimens.chipHeight, minWidth: AppDimens.minTouch),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(group.emoji, style: context.text.reaction),
                  const SizedBox(width: AppDimens.gap6),
                  PersonDots(
                    colors: [for (final userId in group.userIds) context.personColor(household.colorOf(userId))],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pilihan emoji saat memberi reaksi.
class _EmojiChoice extends StatelessWidget {
  const _EmojiChoice({required this.emoji, required this.selected, required this.onTap});

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: context.l10n.reactionPick(emoji),
      excludeSemantics: true,
      child: Material(
        color: selected ? palette.soft : Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: AppDimens.minTouch,
            height: AppDimens.minTouch,
            child: Center(child: Text(emoji, style: context.text.reactionLarge)),
          ),
        ),
      ),
    );
  }
}

/// Satu komentar: avatar, nama dan waktunya (dengan "diedit"), lalu isinya. Komentarku punya
/// menu Ubah dan Hapus; komentar pasangan tidak bisa diubah (kontrak).
class _CommentRow extends StatelessWidget {
  const _CommentRow({
    super.key,
    required this.comment,
    required this.household,
    required this.when,
    required this.onEdit,
    required this.onDelete,
  });

  final Comment comment;
  final Household household;
  final String when;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final userId = comment.userId;
    final mine = userId == null || userId == household.me.id;
    final partner = household.partner;
    final meta = [when, if (comment.isEdited) l10n.commentEdited].join(' · ');

    final avatar = mine
        ? MyAvatar(user: household.me, size: AppDimens.avatarComment)
        : partner != null && partner.id == userId
        ? MemberAvatar(member: partner, size: AppDimens.avatarComment)
        : PersonAvatar(
            name: l10n.savingsContributionFormer,
            colorKey: household.colorOf(userId),
            size: AppDimens.avatarComment,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.gap10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: avatar),
          const SizedBox(width: AppDimens.gap10),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: personLabel(l10n, household, userId), style: text.bodyStrong),
                        TextSpan(text: '  $meta', style: text.small),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.gap2),
                  Text(comment.body, style: text.body.copyWith(color: context.palette.text)),
                ],
              ),
            ),
          ),
          if (mine)
            PopupMenuButton<_CommentAction>(
              tooltip: l10n.commentOptions,
              icon: const Icon(Symbols.more_vert_rounded, size: AppDimens.iconMd),
              onSelected: (action) => switch (action) {
                _CommentAction.edit => onEdit(),
                _CommentAction.delete => onDelete(),
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: _CommentAction.edit, child: Text(l10n.commonEdit)),
                PopupMenuItem(value: _CommentAction.delete, child: Text(l10n.commonDelete)),
              ],
            ),
        ],
      ),
    );
  }
}

enum _CommentAction { edit, delete }

/// Lembar Ubah komentar. Mengembalikan isi baru, atau `null` kalau batal.
class _EditCommentSheet extends StatefulWidget {
  const _EditCommentSheet({required this.initial});

  final String initial;

  @override
  State<_EditCommentSheet> createState() => _EditCommentSheetState();
}

class _EditCommentSheetState extends State<_EditCommentSheet> {
  late final TextEditingController _body = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final body = _body.text.trim();
    final error = body.isEmpty
        ? l10n.commentRequired
        : textLength(body) > Limits.commentBody
        ? l10n.commentTooLong
        : null;
    if (error != null) return setState(() => _error = error);
    Navigator.of(context).pop(body);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppSheet(
      title: l10n.commentEditTitle,
      footer: PrimaryButton(label: l10n.commonSave, onPressed: _save),
      children: [
        TextField(
          controller: _body,
          autofocus: true,
          style: context.text.input,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(errorText: _error),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ],
    );
  }
}

/// Ringkasan percakapan untuk baris daftar: emoji reaksi (paling banyak tiga) dan jumlah
/// komentar, misalnya "❤️😂 · 💬 2". Kosong kalau belum ada apa-apa. Labelnya sengaja ikut
/// tergabung ke baris atau kartu induknya, supaya satu item dibacakan utuh.
class ConversationBadge extends StatelessWidget {
  const ConversationBadge({super.key, required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    if (conversation.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final emojis = conversation.reactions.take(3).map((group) => group.emoji).join();
    final count = conversation.comments.length;

    return Semantics(
      label: l10n.conversationSummary(conversation.reactionCount, count),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emojis.isNotEmpty) Text(emojis, style: text.small),
          if (emojis.isNotEmpty && count > 0) const SizedBox(width: AppDimens.gap8),
          if (count > 0) ...[
            Icon(Symbols.chat_bubble_rounded, size: AppDimens.iconXs, color: palette.muted),
            const SizedBox(width: AppDimens.gap2),
            Text('$count', style: text.smallStrong.copyWith(color: palette.muted)),
          ],
        ],
      ),
    );
  }
}

/// Gulir ke bagian Komentar saat layar dibuka dari notifikasi komentar atau reaksi.
///
/// Bagian itu ada di bawah daftar yang dibangun bertahap, jadi daftarnya digulir ke ujung
/// dulu sampai bagian berkunci [key] terbangun, lalu bagian itu dipastikan tampil.
Future<void> scrollToComments(ScrollController controller, GlobalKey key) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    final target = key.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(target, duration: _scrollDuration);
      return;
    }
    if (!controller.hasClients) return;
    controller.jumpTo(controller.position.maxScrollExtent);
    await WidgetsBinding.instance.endOfFrame;
  }
}

const Duration _scrollDuration = Duration(milliseconds: 300);
