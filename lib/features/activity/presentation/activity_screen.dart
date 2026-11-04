import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/widgets.dart';
import '../../comments/domain/comment.dart';
import '../../home/presentation/main_shell.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/presentation/member_avatar.dart';
import '../domain/activity.dart';

/// Aktivitas (v1.x): kegiatan di Ruang Bersama selama 30 hari terakhir, terbaru di atas, per hari
/// menurut zona waktu ruang. Dibuka dari ikon lonceng di kepala Beranda; membukanya menandai
/// kegiatan pasangan sudah dilihat.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool _partnerOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markSeen());
  }

  /// Simpan waktu feed dilihat, supaya titik di lonceng Beranda hilang.
  void _markSeen() {
    if (!mounted) return;
    final account = ref.read(accountProvider);
    final now = ref.read(spaceClockProvider).now();
    account?.store.setMeta(activitySeenKey, now.toUtc().toIso8601String()).ignore();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final events = ref.watch(activityEventsProvider);
    // Kegiatan yang masuk selagi layar ini terbuka juga dianggap sudah dilihat.
    ref.listen(activityEventsProvider.select((events) => events?.firstOrNull?.key), (_, _) => _markSeen());

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.activityTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap10),
          if (household == null || events == null)
            const SkeletonCard(lines: 4)
          else if (!household.isPaired)
            EmptyState(
              icon: Symbols.group_rounded,
              message: l10n.activityUnpaired,
              actionLabel: l10n.activityInvite,
              onAction: () => context.push(Routes.pairing),
            )
          else
            ..._feed(context, household, events),
        ],
      ),
    );
  }

  List<Widget> _feed(BuildContext context, Household household, List<ActivityEvent> events) {
    final l10n = context.l10n;
    final text = context.text;
    final partner = household.partner;
    final shown = _partnerOnly && partner != null
        ? events.where((event) => event.actorId == partner.id).toList()
        : events;

    final clock = ref.watch(spaceClockProvider);
    final timezone = household.shared!.timezone;
    final today = clock.wallClock(ref.watch(nowProvider), timezone);
    final days = <String, List<ActivityEvent>>{};
    for (final event in shown) {
      days.putIfAbsent(clock.wallClock(event.time, timezone).date, () => []).add(event);
    }

    return [
      Text(l10n.activityWindowNote, style: text.caption),
      const SizedBox(height: AppDimens.gap10),
      if (partner != null)
        Wrap(
          spacing: AppDimens.gap8,
          children: [
            AppFilterChip(
              label: l10n.activityAll,
              selected: !_partnerOnly,
              onTap: () => setState(() => _partnerOnly = false),
            ),
            AppFilterChip(
              label: l10n.activityPartnerOnly,
              selected: _partnerOnly,
              onTap: () => setState(() => _partnerOnly = true),
            ),
          ],
        ),
      const SizedBox(height: AppDimens.gap12),
      if (shown.isEmpty)
        EmptyState(
          icon: Symbols.notifications_rounded,
          message: _partnerOnly && partner != null ? l10n.activityEmptyPartner(partner.name) : l10n.activityEmpty,
        )
      else
        for (final MapEntry(key: day, value: dayEvents) in days.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.gap8, bottom: AppDimens.gap6),
            child: Semantics(
              header: true,
              child: Text(_dayLabel(l10n, day, today.date, today.year), style: text.sectionTitle),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
            child: Column(
              children: [
                for (final (index, event) in dayEvents.indexed) ...[
                  if (index > 0) const RowDivider(),
                  _ActivityRow(
                    event: event,
                    household: household,
                    time: formatClock(clock.wallClock(event.time, timezone).time),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap8),
        ],
    ];
  }

  static String _dayLabel(AppLocalizations l10n, String day, String today, int currentYear) {
    if (day == today) return l10n.activityToday;
    if (day == addDays(today, -1)) return l10n.activityYesterday;
    final date = parseYmd(day);
    return DateFormat(date.year == currentYear ? 'EEEE, d MMMM' : 'EEEE, d MMMM y', dateLocale).format(date);
  }
}

/// Satu kejadian: avatar pelakunya, kalimatnya, dan jamnya. Diketuk → layar yang sama dengan
/// notifikasinya.
class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.event, required this.household, required this.time});

  final ActivityEvent event;
  final Household household;
  final String time;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final route = event.route;

    final Widget leading;
    final actorId = event.actorId;
    final partner = household.partner;
    if (actorId == null) {
      leading = Container(
        width: AppDimens.avatarComment,
        height: AppDimens.avatarComment,
        decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
        child: Icon(Symbols.celebration_rounded, size: AppDimens.iconMd, color: palette.brand),
      );
    } else if (actorId == household.me.id) {
      leading = MyAvatar(user: household.me, size: AppDimens.avatarComment);
    } else if (partner != null && actorId == partner.id) {
      leading = MemberAvatar(member: partner, size: AppDimens.avatarComment);
    } else {
      leading = PersonAvatar(name: '?', colorKey: household.me.color, size: AppDimens.avatarComment);
    }

    return MergeSemantics(
      child: InkWell(
        onTap: route == null ? null : () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.gap10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: AppDimens.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activitySentence(l10n, event, household),
                      style: text.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimens.gap2),
                    Text(time, style: text.small),
                  ],
                ),
              ),
              if (route != null) ...[
                const SizedBox(width: AppDimens.gap8),
                Icon(Symbols.chevron_right_rounded, size: AppDimens.iconMd, color: palette.muted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Kalimat satu kejadian: "Kamu" untuk kegiatan sendiri, nama pasangan untuk kegiatannya.
String activitySentence(AppLocalizations l10n, ActivityEvent event, Household household) {
  final partner = household.partner;
  String nameOf(String? id) {
    if (id == household.me.id) return l10n.activityYou;
    if (partner != null && id == partner.id) return partner.name;
    return l10n.activitySomeone;
  }

  final actor = nameOf(event.actorId);
  final title = event.title ?? '';
  final amount = event.amount ?? '';

  String subject() => switch (event.subjectType) {
    SubjectType.savingsEntry =>
      event.subjectEntryType == 'withdrawal'
          ? l10n.activityWithdrawalSubject(amount)
          : l10n.activityEntrySubject(amount),
    _ => title,
  };

  return switch (event.kind) {
    ActivityKind.taskAdded => l10n.activityTaskAdded(actor, title),
    ActivityKind.taskAssigned =>
      event.assigneeId == household.me.id
          ? l10n.activityTaskAssignedToYou(actor, title)
          : l10n.activityTaskAssignedTo(actor, title, nameOf(event.assigneeId)),
    ActivityKind.taskCompleted => l10n.activityTaskCompleted(actor, title),
    ActivityKind.deposit => l10n.activityDeposit(actor, amount, title),
    ActivityKind.withdrawal => l10n.activityWithdrawal(actor, amount, title),
    ActivityKind.goalCreated => l10n.activityGoalCreated(actor, title),
    ActivityKind.goalAchieved => l10n.activityGoalAchieved(title),
    ActivityKind.tripPlanned => l10n.activityTripPlanned(actor, title),
    ActivityKind.specialDateAdded => l10n.activityDateAdded(actor, title),
    ActivityKind.memorySaved => l10n.activityMemorySaved(actor, title),
    ActivityKind.photosAdded => l10n.activityPhotosAdded(actor, event.count, title),
    ActivityKind.commented => l10n.activityCommented(actor, subject(), event.text ?? ''),
    ActivityKind.reacted => l10n.activityReacted(actor, event.text ?? '', subject()),
    ActivityKind.joined => l10n.activityJoined(actor),
  };
}
