import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/widgets.dart';
import '../../savings/domain/savings_views.dart';
import '../../savings/presentation/goal_form_sheet.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/presentation/member_avatar.dart';
import '../../special_dates/domain/upcoming_dates.dart';
import '../../special_dates/presentation/special_date_sheet.dart';
import '../../special_dates/presentation/special_date_text.dart';
import '../../tasks/domain/task_views.dart';
import '../../tasks/presentation/task_row.dart';

/// Beranda: sapaan, tugas hari ini (termasuk yang terlewat), target tabungan utama,
/// dan tanggal penting terdekat (v0.2).
///
/// Semuanya dihitung dari cache lokal, jadi tetap cepat dan jalan saat offline.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  PersonFilter _person = PersonFilter.all;

  String _greeting(AppLocalizations l10n, int hour) => switch (hour) {
    >= 4 && < 11 => l10n.greetingMorning,
    >= 11 && < 15 => l10n.greetingNoon,
    >= 15 && < 19 => l10n.greetingAfternoon,
    _ => l10n.greetingNight,
  };

  /// Tanggal dan jam untuk kepala layar, di zona waktu yang sama dengan "Tugas hari ini".
  ({DateTime date, int hour}) _headerTime(DateTime now, Household? household) {
    final space = household?.shared ?? household?.personal;
    if (space == null) return (date: now, hour: now.hour);

    final wall = ref.watch(spaceClockProvider).wallClock(now, space.timezone);
    return (date: parseYmd(wall.date), hour: int.parse(wall.time.substring(0, 2)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final items = ref.watch(taskItemsProvider);
    final goals = ref.watch(goalProgressProvider);
    final upcoming = ref.watch(upcomingDatesProvider);
    final header = _headerTime(ref.watch(nowProvider), household);

    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatWeekdayLong(header.date), style: text.captionMedium),
        const SizedBox(height: AppDimens.gap2),
        Semantics(header: true, child: Text(_greeting(l10n, header.hour), style: text.homeTitle)),
      ],
    );

    if (household == null || items == null || goals == null || upcoming == null) {
      return PageBody(
        children: [
          greeting,
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 4),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
        ],
      );
    }

    return PageBody(
      onRefresh: () => refreshFromServer(ref),
      bottomPadding: AppDimens.fabClearance,
      children: [
        Row(
          children: [
            Expanded(child: greeting),
            const SizedBox(width: AppDimens.gap12),
            _HeaderAvatars(household: household),
          ],
        ),
        const SizedBox(height: AppDimens.gap12),
        _TodayCard(
          household: household,
          items: items,
          person: household.isPaired ? _person : PersonFilter.all,
          onPerson: (person) => setState(() => _person = person),
        ),
        const SizedBox(height: AppDimens.gap12),
        _SavingsCard(goal: primaryGoal(goals)),
        const SizedBox(height: AppDimens.gap12),
        _SpecialDateCard(nearest: upcoming.nearest, currentYear: header.date.year),
      ],
    );
  }
}

/// Avatar kamu dan pasangan bertumpuk; ketuk untuk membuka Pengaturan.
class _HeaderAvatars extends StatelessWidget {
  const _HeaderAvatars({required this.household});

  final Household household;

  @override
  Widget build(BuildContext context) {
    final partner = household.partner;

    return Semantics(
      container: true,
      button: true,
      label: context.l10n.homeOpenSettings,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => context.push(Routes.settings),
        child: SizedBox(
          height: AppDimens.minTouch,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyAvatar(user: household.me, size: AppDimens.avatarSmall),
              if (partner != null)
                Transform.translate(
                  offset: const Offset(-AppDimens.avatarOverlap, 0),
                  child: MemberAvatar(member: partner, size: AppDimens.avatarSmall),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.household, required this.items, required this.person, required this.onPerson});

  final Household household;
  final List<TaskItem> items;
  final PersonFilter person;
  final ValueChanged<PersonFilter> onPerson;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    final today =
        items
            .where((item) => item.isForToday)
            .where((item) => item.matches(person, meId: household.me.id, partnerId: household.partner?.id))
            .toList()
          ..sort(compareForToday);
    final done = today.where((item) => item.isCompleted).length;
    final allDone = today.isNotEmpty && done == today.length;

    return AppCard(
      semanticLabel: l10n.homeTodayTitle,
      padding: const EdgeInsets.fromLTRB(AppDimens.cardPadding, AppDimens.gap4, AppDimens.cardPadding, AppDimens.gap8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.homeTodayTitle, style: text.cardTitle)),
              TextButton(
                onPressed: () => context.go(Routes.tasks),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(l10n.commonSeeAll),
              ),
            ],
          ),
          if (today.isNotEmpty)
            Row(
              children: [
                Text(l10n.homeTodayProgress(done, today.length), style: text.caption),
                const SizedBox(width: AppDimens.gap10),
                Expanded(child: ProgressBar(fraction: done / today.length)),
              ],
            ),
          // Filter orang hanya berarti kalau sudah punya pasangan.
          if (household.isPaired) ...[
            const SizedBox(height: AppDimens.gap6),
            Semantics(
              container: true,
              label: l10n.filterPeopleLabel,
              child: Wrap(
                spacing: AppDimens.gap8,
                children: [
                  _chip(l10n.filterAll, PersonFilter.all),
                  _chip(l10n.labelMe, PersonFilter.me),
                  _chip(l10n.labelPartner, PersonFilter.partner),
                ],
              ),
            ),
          ],
          if (today.isEmpty)
            EmptyState(
              message: person == PersonFilter.all ? l10n.homeTodayEmpty : l10n.homeTodayFilterEmpty,
              icon: Symbols.task_alt_rounded,
            ),
          if (allDone)
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.gap10, bottom: AppDimens.gap4),
              child: StatusText(
                text: household.isPaired ? l10n.homeTodayAllDone : l10n.homeTodayAllDoneSolo,
                icon: Symbols.celebration_rounded,
                color: palette.ok,
              ),
            ),
          for (final (index, item) in today.indexed) ...[
            if (index > 0) const RowDivider(),
            TaskRow(
              key: ValueKey(item.task.id),
              item: item,
              household: household,
              showListName: true,
              minHeight: AppDimens.rowMinHeightTall,
              onTap: () => context.go(Routes.task(item.task.id, fromHome: true)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, PersonFilter filter) =>
      AppFilterChip(label: label, selected: person == filter, onTap: () => onPerson(filter));
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.goal});

  /// Target utama, atau `null` kalau belum ada target.
  final GoalProgress? goal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final progress = goal;

    return AppCard(
      semanticLabel: l10n.homeSavingsTitle,
      padding: const EdgeInsets.fromLTRB(AppDimens.cardPadding, AppDimens.gap4, AppDimens.cardPadding, AppDimens.gap12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.homeSavingsTitle, style: text.cardTitle)),
              TextButton(
                onPressed: () => context.go(Routes.savings),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(l10n.commonSeeAll),
              ),
            ],
          ),
          if (progress == null)
            EmptyState(
              message: l10n.homeSavingsEmpty,
              actionLabel: l10n.homeSavingsCreate,
              onAction: () => showGoalFormSheet(context),
            )
          else
            InkWell(
              onTap: () => context.go(Routes.goal(progress.goal.id, fromHome: true)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(goalTitle(progress), style: text.rowTitle)),
                      // Bar progres selalu disertai angka persen.
                      Text(l10n.percent(progress.percent), style: text.rowTitle),
                    ],
                  ),
                  const SizedBox(height: AppDimens.gap8),
                  ProgressBar(fraction: progress.fraction, height: AppDimens.progressThick),
                  const SizedBox(height: AppDimens.gap8),
                  Text(
                    l10n.savingsOf(
                      formatMoney(progress.saved, progress.goal.currency),
                      formatMoney(progress.goal.targetAmount, progress.goal.currency),
                    ),
                    style: text.caption,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Tanggal penting terdekat: hitung mundur, atau kartu ucapan di hari H.
class _SpecialDateCard extends StatelessWidget {
  const _SpecialDateCard({required this.nearest, required this.currentYear});

  /// `null` kalau belum ada tanggal penting atau ulang tahun yang diketahui.
  final UpcomingDate? nearest;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final item = nearest;
    void open() => context.push(Routes.specialDates);

    return AppCard(
      semanticLabel: l10n.homeDatesTitle,
      padding: const EdgeInsets.fromLTRB(AppDimens.cardPadding, AppDimens.gap4, AppDimens.cardPadding, AppDimens.gap12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.homeDatesTitle, style: text.cardTitle)),
              TextButton(
                onPressed: open,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(l10n.commonSeeAll),
              ),
            ],
          ),
          if (item == null)
            EmptyState(
              message: l10n.homeDatesEmpty,
              actionLabel: l10n.homeDatesAdd,
              onAction: () => showSpecialDateSheet(context),
            )
          else
            InkWell(
              onTap: open,
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: AppDimens.iconCircle,
                      height: AppDimens.iconCircle,
                      decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
                      child: Icon(
                        item.isToday ? Symbols.celebration_rounded : typeIcon(item.type),
                        size: AppDimens.iconLg,
                        color: palette.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.gap12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hari H: kartu ucapan, misalnya "Hari jadi kita ke-3. Selamat!".
                        Text(
                          item.isToday
                              ? l10n.homeDatesGreeting(upcomingTitle(l10n, item))
                              : countdownLong(l10n, item.daysLeft),
                          style: text.countdown,
                        ),
                        const SizedBox(height: AppDimens.gap2),
                        Text(
                          l10n.homeDatesCaption(
                            item.isToday ? l10n.datesToday : upcomingTitle(l10n, item),
                            upcomingDay(item, currentYear: currentYear),
                          ),
                          style: text.small,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Nama target dengan emojinya di depan, kalau ada.
String goalTitle(GoalProgress progress) {
  final goal = progress.goal;
  return goal.emoji == null ? goal.name : '${goal.emoji} ${goal.name}';
}
