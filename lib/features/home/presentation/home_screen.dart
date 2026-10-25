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
import '../../memories/domain/memory_views.dart';
import '../../memories/presentation/memory_photo_view.dart';
import '../../savings/domain/savings_views.dart';
import '../../savings/presentation/goal_form_sheet.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/presentation/member_avatar.dart';
import '../../special_dates/domain/upcoming_dates.dart';
import '../../special_dates/presentation/special_date_sheet.dart';
import '../../special_dates/presentation/special_date_text.dart';
import '../../tasks/domain/task_views.dart';
import '../../tasks/presentation/task_row.dart';
import '../../trips/domain/trip_views.dart';
import '../../trips/presentation/trip_form_sheet.dart';
import '../../trips/presentation/trip_text.dart';

/// Beranda: sapaan, tugas hari ini (termasuk yang terlewat), target tabungan utama,
/// lalu tanggal penting terdekat dan persiapan liburan (v0.2) berdampingan.
///
/// Semuanya dihitung dari cache lokal, jadi tetap cepat dan jalan saat offline.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Paling banyak kartu "hari ini, setahun lalu" di Beranda; sisanya lewat tautan ke Kenangan.
  static const int _onThisDayShown = 2;

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
    final trips = ref.watch(tripItemsProvider);
    final memories = ref.watch(memoryItemsProvider);
    final header = _headerTime(ref.watch(nowProvider), household);

    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatWeekdayLong(header.date), style: text.captionMedium),
        const SizedBox(height: AppDimens.gap2),
        Semantics(header: true, child: Text(_greeting(l10n, header.hour), style: text.homeTitle)),
      ],
    );

    if (household == null || items == null || goals == null || upcoming == null || trips == null) {
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

    final onThisDay = memoriesOnThisDay(memories ?? const [], ymdOf(header.date));

    return PageBody(
      onRefresh: () => refreshFromServer(ref),
      bottomPadding: AppDimens.fabClearance,
      children: [
        Row(
          children: [
            Expanded(child: greeting),
            const SizedBox(width: AppDimens.gap8),
            AppIconButton(
              icon: Symbols.search_rounded,
              label: l10n.homeSearch,
              onPressed: () => context.push(Routes.search),
            ),
            const SizedBox(width: AppDimens.gap4),
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
        // "Hari ini, setahun lalu" (v1.x): hanya tampil di hari yang punya kenangan.
        for (final memory in onThisDay.take(_onThisDayShown)) ...[
          _OnThisDayCard(memory: memory, currentYear: header.date.year),
          const SizedBox(height: AppDimens.gap12),
        ],
        if (onThisDay.length > _onThisDayShown) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => context.go(Routes.memories),
              child: Text(l10n.homeOnThisDayMore(onThisDay.length - _onThisDayShown)),
            ),
          ),
          const SizedBox(height: AppDimens.gap12),
        ],
        _SavingsCard(goal: primaryGoal(goals)),
        const SizedBox(height: AppDimens.gap12),
        // Dua kartu sama tinggi, berdampingan seperti di mockup.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SpecialDateTile(nearest: upcoming.nearest, currentYear: header.date.year),
              ),
              const SizedBox(width: AppDimens.gap12),
              Expanded(child: _TripTile(trip: featuredTrip(trips))),
            ],
          ),
        ),
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

/// Kenangan dari tanggal yang sama di tahun sebelumnya: sampul (kalau ada foto), "Setahun lalu,
/// hari ini", judul, lalu tanggal dan tempat. Ketuk → Detail kenangan.
class _OnThisDayCard extends StatelessWidget {
  const _OnThisDayCard({required this.memory, required this.currentYear});

  final OnThisDay memory;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final palette = context.palette;
    final item = memory.item;
    final cover = item.cover;
    final label = l10n.homeOnThisDay(memory.yearsAgo);
    final details = [
      formatDayShort(item.memory.visitedOn, currentYear: currentYear),
      ?item.memory.placeName,
    ].join(' · ');

    return AppCard(
      semanticLabel: label,
      padding: EdgeInsets.zero,
      onTap: () => context.go(Routes.memory(item.memory.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cover != null)
            ExcludeSemantics(
              child: AspectRatio(
                aspectRatio: AppDimens.coverAspectCard,
                child: MemoryPhotoImage(photo: cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Symbols.history_rounded, size: AppDimens.iconSm, color: palette.brand),
                    const SizedBox(width: AppDimens.gap6),
                    Expanded(
                      child: Text(label, style: text.captionStrong.copyWith(color: palette.link)),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.gap4),
                Text(item.memory.title, style: text.rowTitle),
                const SizedBox(height: AppDimens.gap2),
                Text(details, style: text.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu kecil setengah lebar di bawah Beranda: ikon, satu baris besar, dan keterangan.
/// Seluruh kartu satu tombol bagi pembaca layar, yang tetap membacakan teks lengkapnya
/// walaupun judul yang sangat panjang dipotong di layar.
class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.icon,
    required this.headline,
    required this.caption,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String headline;
  final String caption;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap14, vertical: AppDimens.gap12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppDimens.iconMd, color: context.palette.brand),
            const SizedBox(height: AppDimens.gap4),
            Text(headline, style: text.countdown, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppDimens.gap4),
            Text(caption, style: text.small, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Tanggal penting terdekat: hitung mundur, atau kartu ucapan di hari H.
class _SpecialDateTile extends StatelessWidget {
  const _SpecialDateTile({required this.nearest, required this.currentYear});

  /// `null` kalau belum ada tanggal penting atau ulang tahun yang diketahui.
  final UpcomingDate? nearest;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = nearest;

    if (item == null) {
      return _HomeTile(
        icon: Symbols.favorite_rounded,
        headline: l10n.homeDatesAdd,
        caption: l10n.homeDatesEmptyCaption,
        semanticLabel: l10n.homeDatesSemantic(l10n.homeDatesAdd),
        onTap: () => showSpecialDateSheet(context),
      );
    }

    // Hari H: kartu ucapan, misalnya "Hari jadi kita ke-3. Selamat!".
    final headline = item.isToday
        ? l10n.homeDatesGreeting(upcomingTitle(l10n, item))
        : countdownLong(l10n, item.daysLeft);
    final caption = l10n.homeDatesCaption(
      item.isToday ? l10n.datesToday : upcomingTitle(l10n, item),
      upcomingDay(item, currentYear: currentYear),
    );

    return _HomeTile(
      icon: item.isToday ? Symbols.celebration_rounded : typeIcon(item.type),
      headline: headline,
      caption: caption,
      semanticLabel: l10n.homeDatesSemantic('$headline, $caption'),
      onTap: () => context.push(Routes.specialDates),
    );
  }
}

/// Persiapan perjalanan yang sedang berlangsung atau paling dekat: "7 dari 12" beres,
/// atau hitung mundurnya kalau checklist masih kosong.
class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip});

  /// `null` kalau belum ada perjalanan yang akan datang.
  final TripItem? trip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = trip;

    if (item == null) {
      return _HomeTile(
        icon: Symbols.flight_takeoff_rounded,
        headline: l10n.homeTripEmpty,
        caption: l10n.homeTripEmptyCaption,
        semanticLabel: l10n.homeTripSemantic(l10n.homeTripEmpty),
        onTap: () => showTripFormSheet(context),
      );
    }

    final title = item.trip.title;
    final hasItems = item.total > 0;
    final headline = hasItems ? l10n.homeTripProgress(item.done, item.total) : tripCountdown(l10n, item);
    final caption = hasItems ? l10n.homeTripCaption(title) : title;
    final spoken = hasItems ? '${l10n.tripChecklistProgress(item.done, item.total)}, $title' : '$headline, $title';

    return _HomeTile(
      icon: tripStatusIcon(item.status),
      headline: headline,
      caption: caption,
      semanticLabel: l10n.homeTripSemantic(spoken),
      onTap: () => context.go(Routes.trip(item.trip.id)),
    );
  }
}

/// Nama target dengan emojinya di depan, kalau ada.
String goalTitle(GoalProgress progress) {
  final goal = progress.goal;
  return goal.emoji == null ? goal.name : '${goal.emoji} ${goal.name}';
}
