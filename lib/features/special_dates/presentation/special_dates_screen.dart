import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/domain/user.dart';
import '../../home/presentation/main_shell.dart';
import '../../spaces/domain/household.dart';
import '../domain/upcoming_dates.dart';
import 'special_date_sheet.dart';
import 'special_date_text.dart';

/// Tanggal penting (v0.2): sudah berapa lama bersama, tanggal yang akan datang
/// beserta hitung mundurnya, dan pengingatnya.
class SpecialDatesScreen extends ConsumerWidget {
  const SpecialDatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final upcoming = ref.watch(upcomingDatesProvider);

    final header = ScreenHeader(
      title: l10n.datesTitle,
      onBack: () => context.canPop() ? context.pop() : context.go(Routes.settings),
    );

    if (household == null || upcoming == null) {
      return AppScaffold(
        child: PageBody(
          children: [
            header,
            const SizedBox(height: AppDimens.gap12),
            const SkeletonCard(lines: 2),
            const SizedBox(height: AppDimens.gap12),
            const SkeletonCard(lines: 3),
          ],
        ),
      );
    }

    final zone = (household.shared ?? household.personal)?.timezone ?? household.me.timezone;
    final currentYear = ref.watch(spaceClockProvider).wallClock(ref.watch(nowProvider), zone).year;
    final together = upcoming.together;

    return AppScaffold(
      child: Column(
        children: [
          Expanded(
            child: PageBody(
              onRefresh: () => refreshFromServer(ref),
              bottomPadding: AppDimens.gap12,
              children: [
                header,
                const SizedBox(height: AppDimens.gap12),
                if (together != null) ...[_TogetherCard(together: together), const SizedBox(height: AppDimens.gap10)],
                SectionTitle(l10n.datesUpcoming),
                const SizedBox(height: AppDimens.gap10),
                _UpcomingCard(items: upcoming.items, household: household, currentYear: currentYear),
                if (household.me.birthDate == null) ...[
                  const SizedBox(height: AppDimens.gap10),
                  const _BirthDateHint(),
                ],
                const SizedBox(height: AppDimens.gap10),
                SectionTitle(l10n.datesReminders),
                const SizedBox(height: AppDimens.gap10),
                _RemindersCard(prefs: household.me.notificationPrefs, paired: household.isPaired),
                if (household.isPaired) ...[const SizedBox(height: AppDimens.gap12), const _PrivacyNote()],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageSide,
              AppDimens.gap8,
              AppDimens.pageSide,
              AppDimens.pageBottom,
            ),
            child: PrimaryButton(
              label: l10n.datesAdd,
              icon: Symbols.add_rounded,
              onPressed: () => showSpecialDateSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Bersama sejak 20 Okt 2023 · 1.084 hari · Hari jadi kita ke-3 tinggal 12 hari lagi".
class _TogetherCard extends StatelessWidget {
  const _TogetherCard({required this.together});

  final TogetherSince together;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final anniversary = together.anniversary;
    final title = upcomingTitle(l10n, anniversary);

    final next = switch (anniversary.daysLeft) {
      0 => l10n.datesTogetherNextToday(title),
      1 => l10n.datesTogetherNextTomorrow(title),
      final days => l10n.datesTogetherNextDays(title, days),
    };

    return AppCard(
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: AppDimens.featureCircle,
              height: AppDimens.featureCircle,
              decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
              child: Icon(Symbols.favorite_rounded, size: AppDimens.iconFeature, color: palette.brand),
            ),
          ),
          const SizedBox(width: AppDimens.gap14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.datesTogetherSince(formatDateMedium(together.since)), style: text.caption),
                const SizedBox(height: AppDimens.gap2),
                Text(
                  l10n.datesTogetherDays(NumberFormat.decimalPattern(dateLocale).format(together.days)),
                  style: text.countdownLarge,
                ),
                const SizedBox(height: AppDimens.gap2),
                Text(next, style: text.link),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.items, required this.household, required this.currentYear});

  final List<UpcomingDate> items;
  final Household household;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        child: EmptyState(message: context.l10n.datesEmpty, icon: Symbols.favorite_rounded),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0) const RowDivider(),
            UpcomingRow(
              key: ValueKey(item.key),
              item: item,
              household: household,
              currentYear: currentYear,
              onTap: _tapFor(context, item),
            ),
          ],
        ],
      ),
    );
  }

  /// Tanggal penting dibuka untuk diubah; ulang tahun sendiri diubah di Profil;
  /// ulang tahun pasangan hanya bisa diubah pasangan.
  VoidCallback? _tapFor(BuildContext context, UpcomingDate item) {
    final special = item.specialDate;
    if (special != null) return () => showSpecialDateSheet(context, date: special);
    if (item.isMine) return () => context.push(Routes.profile);
    return null;
  }
}

/// Satu baris "Akan datang": ikon jenis, nama, hari dan ruangnya, lalu hitung mundur.
class UpcomingRow extends StatelessWidget {
  const UpcomingRow({super.key, required this.item, required this.household, required this.currentYear, this.onTap});

  final UpcomingDate item;
  final Household household;
  final int currentYear;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    final title = upcomingTitle(l10n, item);
    final day = upcomingDay(item, currentYear: currentYear);
    final where = item.isPrivate ? l10n.datesInPrivate : (household.isPaired ? l10n.datesInShared : null);
    final countdown = countdownShort(l10n, item.daysLeft);

    // Spasi tak terputus sebelum "·", supaya titiknya tidak tertinggal sendirian di awal baris.
    const nbsp = ' ';
    final subtitle = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: where == null ? day : '$day$nbsp·$nbsp'),
          if (item.isPrivate)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimens.gap2),
                child: Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: palette.muted),
              ),
            ),
          if (where != null) TextSpan(text: where),
        ],
      ),
      style: text.small,
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label: l10n.datesRowSemantic(title, where == null ? day : '$day, $where', countdown),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
            child: Row(
              children: [
                UpcomingIcon(item: item),
                const SizedBox(width: AppDimens.gap12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.rowTitle),
                      const SizedBox(height: AppDimens.gap2),
                      subtitle,
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.gap12),
                Text(countdown, style: text.sectionTitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ulang tahun sendiri diambil dari Profil; tanpa itu pasangan tidak diingatkan.
class _BirthDateHint extends StatelessWidget {
  const _BirthDateHint();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
      onTap: () => context.push(Routes.profile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightTall),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: AppDimens.iconCircle,
                height: AppDimens.iconCircle,
                decoration: BoxDecoration(color: palette.soft, shape: BoxShape.circle),
                child: Icon(Symbols.cake_rounded, size: AppDimens.iconLg, color: palette.brand),
              ),
            ),
            const SizedBox(width: AppDimens.gap12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.datesBirthdayMissing, style: text.rowTitle),
                  Text(l10n.datesBirthdayMissingSub, style: text.small),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right_rounded, size: AppDimens.iconMd),
          ],
        ),
      ),
    );
  }
}

/// Jadwal pengingat tetap di v0.2 (H-7, H-1, hari H pukul 08.00); yang bisa diatur hanya nyala atau mati.
class _RemindersCard extends ConsumerWidget {
  const _RemindersCard({required this.prefs, required this.paired});

  final NotificationPrefs prefs;
  final bool paired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchRow(
            title: l10n.datesRemindersSwitch,
            subtitle: l10n.notifSpecialDatesSub,
            icon: Symbols.notifications_rounded,
            value: prefs.specialDates,
            onChanged: (value) =>
                ref.read(accountProvider)?.profile.updateNotificationPrefs(prefs.copyWith(specialDates: value)),
          ),
          if (paired) ...[
            const RowDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.gap10),
              child: Text(l10n.datesRemindersNote, style: context.text.small),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: AppDimens.gap2),
        child: Icon(Symbols.lock_rounded, size: AppDimens.iconXs, color: context.palette.muted),
      ),
      const SizedBox(width: AppDimens.gap6),
      Expanded(child: Text(context.l10n.datesPrivacyNote, style: context.text.small)),
    ],
  );
}
