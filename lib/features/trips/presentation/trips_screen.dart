import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/domain/user.dart';
import '../../spaces/domain/household.dart';
import '../domain/trip_views.dart';
import 'trip_form_sheet.dart';
import 'trip_text.dart';

/// Tab Liburan (v0.2): kartu untuk setiap perjalanan dengan hitung mundur dan progres
/// persiapannya. Yang sudah selesai dilipat di bawah.
class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  bool _showDone = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final household = ref.watch(householdProvider);
    final trips = ref.watch(tripItemsProvider);

    final header = Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(l10n.tripsTitle, style: context.text.homeTitle)),
        ),
        AppIconButton(
          icon: Symbols.add_rounded,
          label: l10n.tripsNew,
          outlined: true,
          iconSize: AppDimens.iconLg,
          onPressed: household == null ? null : () => showTripFormSheet(context),
        ),
      ],
    );

    if (household == null || trips == null) {
      return PageBody(
        children: [
          header,
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 2),
        ],
      );
    }

    final upcoming = trips.where((item) => !item.isDone).toList();
    final done = trips.where((item) => item.isDone).toList();

    return PageBody(
      onRefresh: () => refreshFromServer(ref),
      children: [
        header,
        const SizedBox(height: AppDimens.gap12),
        if (upcoming.isEmpty)
          EmptyState(
            message: household.isPaired ? l10n.tripsEmpty : l10n.tripsEmptySolo,
            icon: Symbols.flight_takeoff_rounded,
            actionLabel: l10n.tripsNew,
            onAction: () => showTripFormSheet(context),
          ),
        for (final item in upcoming) ...[
          TripCard(item: item, household: household),
          const SizedBox(height: AppDimens.gap12),
        ],
        if (done.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              container: true,
              button: true,
              expanded: _showDone,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.segmentItemRadius),
                onTap: () => setState(() => _showDone = !_showDone),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.tripsDoneCount(done.length),
                          style: context.text.chipSelected.copyWith(color: palette.muted),
                        ),
                        const SizedBox(width: AppDimens.gap6),
                        Icon(
                          _showDone ? Symbols.expand_less_rounded : Symbols.expand_more_rounded,
                          size: AppDimens.iconSm,
                          color: palette.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_showDone)
          for (final item in done) ...[
            TripCard(item: item, household: household),
            const SizedBox(height: AppDimens.gap12),
          ],
        const SizedBox(height: AppDimens.gap4),
        SectionTitle(l10n.tripsReminders),
        const SizedBox(height: AppDimens.gap10),
        _RemindersCard(prefs: household.me.notificationPrefs),
      ],
    );
  }
}

/// Kartu satu perjalanan: nama, status dengan ikon, tanggal dan tujuan, lalu progres persiapan.
class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.item, required this.household});

  final TripItem item;
  final Household household;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final trip = item.trip;
    final shared = household.isShared(trip.spaceId);
    final dates = tripDates(l10n, item, currentYear: currentYearOf(item));
    final details = [?dates, ?trip.destination].join(' · ');

    return AppCard(
      semanticLabel: trip.title,
      onTap: () => context.go(Routes.trip(trip.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(trip.title, style: text.rowTitle),
          const SizedBox(height: AppDimens.gap4),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusText(
              text: tripCountdown(l10n, item),
              icon: tripStatusIcon(item.status),
              color: item.isDone ? palette.muted : palette.link,
            ),
          ),
          if (details.isNotEmpty) ...[const SizedBox(height: AppDimens.gap2), Text(details, style: text.caption)],
          const SizedBox(height: AppDimens.gap10),
          if (item.total == 0)
            Text(l10n.tripChecklistNone, style: text.caption)
          else ...[
            Row(
              children: [
                Expanded(child: Text(l10n.tripChecklistProgress(item.done, item.total), style: text.caption)),
                // Bar progres selalu disertai angka persen.
                Text(l10n.percent(item.percent), style: text.captionStrong),
              ],
            ),
            const SizedBox(height: AppDimens.gap6),
            ProgressBar(fraction: item.fraction),
          ],
          // Ruang Pribadi ditandai ikon gembok, bukan hanya teks.
          if (!shared && household.isPaired) ...[
            const SizedBox(height: AppDimens.gap8),
            Row(
              children: [
                Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
                const SizedBox(width: AppDimens.gap4),
                Text(l10n.labelPersonal, style: text.smallStrong.copyWith(color: palette.muted)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Jadwal pengingat tetap (H-7 dan H-1 pukul 08.00); yang bisa diatur hanya nyala atau mati.
/// Switch ini sama dengan Pengingat perjalanan di Pengaturan.
class _RemindersCard extends ConsumerWidget {
  const _RemindersCard({required this.prefs});

  final NotificationPrefs prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
      child: SwitchRow(
        title: l10n.tripsRemindersSwitch,
        subtitle: l10n.tripsRemindersSub,
        icon: Symbols.notifications_rounded,
        value: prefs.tripReminders,
        onChanged: (value) =>
            ref.read(accountProvider)?.profile.updateNotificationPrefs(prefs.copyWith(tripReminders: value)),
      ),
    );
  }
}
