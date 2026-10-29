import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
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
import '../../comments/domain/conversation.dart';
import '../../comments/presentation/comments_section.dart';
import '../../spaces/domain/household.dart';
import '../domain/savings_entry.dart';
import '../domain/savings_views.dart';
import 'deposit_sheet.dart';
import 'entry_detail_sheet.dart';
import 'goal_form_sheet.dart';
import 'reminder_sheet.dart';

enum _GoalAction { edit, archive, delete }

/// Detail tabungan: ringkasan dengan cincin progres, tombol Setor, setoran per bulan, dan riwayat.
class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId, this.fromHome = false, this.backTo, this.openEntryId});

  final String goalId;

  /// Setoran yang langsung dibuka detailnya, dari notifikasi komentar atau reaksi (v1.x).
  final String? openEntryId;

  /// Dibuka dari Beranda; tombol kembali pulang ke sana.
  final bool fromHome;

  /// Alamat yang dibuka tombol kembali, misalnya perjalanan yang menautkan target ini.
  /// Mengalahkan [fromHome].
  final String? backTo;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  /// Riwayat yang tampil sebelum "Lihat semua" diketuk.
  static const int _historyPreview = 3;

  bool _showAllHistory = false;
  bool _openedEntry = false;

  void _back() => context.go(widget.backTo ?? (widget.fromHome ? Routes.home : Routes.savings));

  Future<void> _onAction(_GoalAction action, GoalProgress progress) async {
    final l10n = context.l10n;
    final goal = progress.goal;
    final savings = ref.read(accountProvider)?.savings;

    switch (action) {
      case _GoalAction.edit:
        await showGoalFormSheet(context, goal: goal);
      case _GoalAction.archive:
        await (goal.isArchived ? savings?.unarchiveGoal(goal.id) : savings?.archiveGoal(goal.id));
      case _GoalAction.delete:
        final confirmed = await confirmDialog(
          context,
          title: l10n.goalDeleteConfirmTitle(goal.name),
          body: l10n.goalDeleteConfirmBody(progress.entries.length),
          confirmLabel: l10n.commonDelete,
          destructive: true,
        );
        if (!confirmed) return;
        await savings?.deleteGoal(goal.id);
        if (mounted) _back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final household = ref.watch(householdProvider);
    final goals = ref.watch(goalProgressProvider);
    final progress = goals?.where((item) => item.goal.id == widget.goalId).firstOrNull;

    final Widget body;

    if (household == null || goals == null) {
      body = PageBody(
        children: [
          ScreenHeader(onBack: _back),
          const SizedBox(height: AppDimens.gap12),
          const SkeletonCard(lines: 4),
        ],
      );
    } else if (progress == null) {
      // Dihapus (mungkin oleh pasangan) atau belum sampai di HP ini.
      body = PageBody(
        children: [
          ScreenHeader(onBack: _back),
          const SizedBox(height: AppDimens.gap24),
          EmptyState(
            message: l10n.goalGone,
            icon: Symbols.savings_rounded,
            actionLabel: l10n.commonBack,
            onAction: _back,
          ),
        ],
      );
    } else {
      final goal = progress.goal;
      final entries = progress.entries;
      final shown = _showAllHistory ? entries : entries.take(_historyPreview).toList();
      final shared = household.isShared(goal.spaceId);
      final conversations = shared ? ref.watch(conversationsProvider) : null;

      // Dari notifikasi komentar atau reaksi: buka detail setorannya sekali.
      final openEntryId = widget.openEntryId;
      if (openEntryId != null && !_openedEntry && shared && entries.any((entry) => entry.id == openEntryId)) {
        _openedEntry = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showEntryDetailSheet(context, goalId: goal.id, entryId: openEntryId, household: household);
        });
      }

      body = PageBody(
        onRefresh: () => refreshFromServer(ref),
        children: [
          ScreenHeader(
            title: goal.emoji == null ? goal.name : '${goal.emoji} ${goal.name}',
            onBack: _back,
            trailing: PopupMenuButton<_GoalAction>(
              tooltip: l10n.commonOptions,
              icon: const Icon(Symbols.more_vert_rounded, size: AppDimens.iconLg),
              onSelected: (action) => _onAction(action, progress),
              itemBuilder: (_) => [
                PopupMenuItem(value: _GoalAction.edit, child: Text(l10n.commonEdit)),
                PopupMenuItem(
                  value: _GoalAction.archive,
                  child: Text(goal.isArchived ? l10n.goalMenuUnarchive : l10n.goalMenuArchive),
                ),
                PopupMenuItem(value: _GoalAction.delete, child: Text(l10n.commonDelete)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap12),
          _SummaryCard(progress: progress, paired: household.isPaired),
          const SizedBox(height: AppDimens.gap12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: l10n.savingsDeposit,
                  icon: Symbols.add_rounded,
                  onPressed: () => showDepositSheet(context, goal: goal, today: progress.today, saved: progress.saved),
                ),
              ),
              // Penarikan (v1.x): hanya kalau ada yang bisa diambil.
              if (progress.available > 0) ...[
                const SizedBox(width: AppDimens.gap10),
                OutlinedButton.icon(
                  onPressed: () => showDepositSheet(
                    context,
                    goal: goal,
                    today: progress.today,
                    saved: progress.saved,
                    withdrawal: true,
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: context.palette.line),
                  ),
                  icon: const Icon(Symbols.remove_rounded, size: AppDimens.iconLg),
                  label: Text(l10n.savingsWithdraw),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.gap12),
          // Tabungan bersama: siapa menyetor berapa, beserta totalnya.
          if (household.isShared(goal.spaceId) && entries.isNotEmpty) ...[
            _ContributionsCard(progress: progress, household: household),
            const SizedBox(height: AppDimens.gap12),
          ],
          AppCard(
            semanticLabel: l10n.savingsMonthly,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.savingsMonthly, style: context.text.sectionTitle),
                const SizedBox(height: AppDimens.gap8),
                _MonthlyChart(progress: progress),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap12),
          AppCard(
            semanticLabel: l10n.savingsHistory,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppDimens.chipHeight),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.savingsHistory, style: context.text.sectionTitle)),
                      if (entries.length > _historyPreview)
                        TextButton(
                          onPressed: () => setState(() => _showAllHistory = !_showAllHistory),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(_showAllHistory ? l10n.commonShowLess : l10n.commonSeeAll),
                        ),
                    ],
                  ),
                ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.gap10),
                    child: Text(l10n.savingsHistoryEmpty, style: context.text.caption),
                  ),
                for (final entry in shown) ...[
                  const RowDivider(),
                  _EntryRow(
                    key: ValueKey(entry.id),
                    entry: entry,
                    progress: progress,
                    household: household,
                    conversation: conversationOf(conversations, entry.id),
                    // Di Ruang Bersama setoran punya reaksi dan komentar (v1.x), jadi dibuka
                    // detailnya dulu; di Ruang Pribadi langsung diubah.
                    onTap: () => shared
                        ? showEntryDetailSheet(context, goalId: goal.id, entryId: entry.id, household: household)
                        : showDepositSheet(
                            context,
                            goal: goal,
                            today: progress.today,
                            saved: progress.saved,
                            entry: entry,
                          ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: body,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.progress, required this.paired});

  /// Di atas pembesaran huruf ini, cincin dan rinciannya tidak lagi muat berdampingan.
  static const double _sideBySideMaxTextScale = 1.3;

  final GoalProgress progress;
  final bool paired;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final goal = progress.goal;
    final weekly = progress.weeklyNeed;

    final ring = ProgressRing(
      fraction: progress.fraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.percent(progress.percent), style: text.homeTitle),
          Text(l10n.savingsCollected, style: text.small),
        ],
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nominal tidak pernah terpotong di tengah angka: mengecil kalau tidak muat.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(formatMoney(progress.saved, goal.currency), style: text.amountLarge, maxLines: 1),
        ),
        Text(l10n.savingsFrom(formatMoney(goal.targetAmount, goal.currency)), style: text.caption),
        const SizedBox(height: AppDimens.gap6),
        Text(l10n.savingsRemaining(formatMoney(progress.remaining, goal.currency)), style: text.captionStrong),
        if (goal.targetDate != null)
          Text(l10n.savingsTargetDate(formatDateMedium(goal.targetDate!)), style: text.caption),
        // Hanya kalau target punya tanggal yang belum lewat.
        if (weekly != null) Text(l10n.savingsWeekly(formatMoney(weekly, goal.currency)), style: text.caption),
      ],
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Huruf sistem diperbesar: cincin pindah ke atas, supaya nominal mendapat lebar penuh.
          if (context.textScale > _sideBySideMaxTextScale) ...[
            Center(child: ring),
            const SizedBox(height: AppDimens.gap12),
            details,
          ] else
            Row(
              children: [
                ring,
                const SizedBox(width: AppDimens.gap16),
                Expanded(child: details),
              ],
            ),
          // Target yang tercapai atau diarsipkan tidak diingatkan (kontrak, Pengingat setor rutin).
          if (!progress.isAchieved && !goal.isArchived) ...[
            const SizedBox(height: AppDimens.gap8),
            const RowDivider(),
            SavingsReminderRow(goal: goal, today: progress.today),
          ],
          if (progress.isAchieved) ...[
            const SizedBox(height: AppDimens.gap12),
            const RowDivider(),
            const SizedBox(height: AppDimens.gap12),
            _Celebration(
              child: StatusText(
                text: paired ? l10n.savingsAchieved(goal.name) : l10n.savingsAchievedSolo(goal.name),
                icon: Symbols.celebration_rounded,
                color: palette.ok,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kontribusi tiap orang di target bersama: satu bar dibagi warna diri masing-masing, lalu
/// baris per orang dengan persen dan nominalnya, dan totalnya. Warna selalu ditemani label
/// dan persen, jadi tidak hanya mengandalkan warna.
class _ContributionsCard extends StatelessWidget {
  const _ContributionsCard({required this.progress, required this.household});

  final GoalProgress progress;
  final Household household;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final currency = progress.goal.currency;
    final contributions = progress.contributions(meId: household.me.id, partnerId: household.partner?.id);

    Color colorOf(Contributor who) => switch (who) {
      Contributor.me => context.personColor(household.me.color),
      Contributor.partner => context.personColor(household.colorOf(household.partner?.id)),
      Contributor.former => palette.muted,
    };

    String labelOf(Contributor who) => switch (who) {
      Contributor.me => l10n.labelMe,
      Contributor.partner => l10n.labelPartner,
      Contributor.former => l10n.savingsContributionFormer,
    };

    Widget row({Color? color, required String label, String? share, required int amount}) => MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightHistory),
        child: Row(
          children: [
            if (color != null) ...[
              ColorDot(color: color, size: AppDimens.dotLarge),
              const SizedBox(width: AppDimens.gap10),
            ],
            Expanded(child: Text(label, style: text.bodyStrong)),
            if (share != null) ...[Text(share, style: text.captionStrong), const SizedBox(width: AppDimens.gap10)],
            Text(formatMoney(amount, currency), style: text.amount),
          ],
        ),
      ),
    );

    return AppCard(
      semanticLabel: l10n.savingsContributions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.savingsContributions, style: text.sectionTitle),
          const SizedBox(height: AppDimens.gap10),
          ExcludeSemantics(
            child: _SplitBar(
              parts: [
                for (final item in contributions)
                  if (item.amount > 0) (amount: item.amount, color: colorOf(item.who)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.gap6),
          for (final item in contributions)
            row(
              color: colorOf(item.who),
              label: labelOf(item.who),
              // Setoran kecil yang dibulatkan ke 0% tetap terlihat ada.
              share: item.percent == 0 && item.amount > 0 ? l10n.percentUnderOne : l10n.percent(item.percent),
              amount: item.amount,
            ),
          const RowDivider(),
          row(label: l10n.savingsContributionTotal, amount: progress.saved),
        ],
      ),
    );
  }
}

/// Bar progres yang dibagi beberapa warna sesuai nominal tiap bagian.
class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.parts});

  final List<({int amount, Color color})> parts;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AppDimens.progressThick / 2),
    child: SizedBox(
      height: AppDimens.progressThick,
      child: parts.isEmpty
          ? ColoredBox(color: context.palette.track)
          : Row(
              // Tanpa stretch, ColoredBox tanpa anak setinggi 0 dan bar tidak terlihat.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final part in parts)
                  // Bagian sekecil apa pun tetap terlihat setipis mungkin.
                  Expanded(
                    flex: math.max(1, part.amount * 1000 ~/ _total),
                    child: ColoredBox(color: part.color),
                  ),
              ],
            ),
    ),
  );

  int get _total => math.max(1, parts.fold(0, (sum, part) => sum + part.amount));
}

/// Perayaan kecil saat target tercapai: teksnya muncul dengan sedikit membesar.
class _Celebration extends StatelessWidget {
  const _Celebration({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (_, scale, animated) => Transform.scale(scale: scale, alignment: Alignment.centerLeft, child: animated),
      child: child,
    );
  }
}

/// Grafik batang setoran lima bulan terakhir; bulan berjalan memakai warna `brand`.
class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.progress});

  /// Label grafik berhenti membesar di sini: lima batang tidak punya ruang untuk label yang lebih besar.
  /// Nominal lengkapnya tetap terbaca di riwayat dan oleh pembaca layar.
  static const double _maxTextScale = 1.3;

  final GoalProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final currency = progress.goal.currency;
    final months = progress.monthlyTotals();
    final highest = months.fold<int>(0, (max, month) => month.amount > max ? month.amount : max);
    // Ruang label ikut membesar bersama hurufnya, supaya tidak terpotong.
    final scale = math.min(context.textScale, _maxTextScale);
    final labelSpace = AppDimens.chartLabelSpace * scale;

    final summary = [
      for (final month in months)
        l10n.savingsMonthlySemantic(formatMonthShort(month.year, month.month), formatMoney(month.amount, currency)),
    ].join(', ');

    return Semantics(
      label: summary,
      child: ExcludeSemantics(
        child: SizedBox(
          height: AppDimens.chartHeight + labelSpace,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: _maxTextScale,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                // Ruang di atas batang tertinggi untuk label nominalnya.
                maxY: highest == 0 ? 1 : highest * (1 + 0.3 * scale),
                barTouchData: const BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: labelSpace / 2,
                      getTitlesWidget: (value, meta) {
                        final month = months[value.toInt()];
                        return SideTitleWidget(
                          meta: meta,
                          space: AppDimens.gap4,
                          child: Text(
                            formatMonthShort(month.year, month.month),
                            style: month.isCurrent ? text.smallStrong : text.small,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (final (index, month) in months.indexed)
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: month.amount.toDouble(),
                          width: AppDimens.chartBarWidth,
                          color: month.isCurrent ? palette.brand : palette.accent,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppDimens.chartBarRadiusTop),
                            bottom: Radius.circular(AppDimens.chartBarRadiusBottom),
                          ),
                          label: BarChartRodLabel(
                            show: month.amount > 0,
                            text: formatMoneyCompact(month.amount, currency),
                            style: month.isCurrent ? text.axisStrong : text.axis,
                            offset: const Offset(0, AppDimens.gap4),
                          ),
                        ),
                      ],
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

/// Satu baris riwayat: siapa dan catatannya, tanggal, dan nominal "+Rp200.000", atau
/// "Aku mengambil" dan "−Rp200.000" untuk penarikan (v1.x).
class _EntryRow extends StatelessWidget {
  const _EntryRow({
    super.key,
    required this.conversation,
    required this.entry,
    required this.progress,
    required this.household,
    required this.onTap,
  });

  final SavingsEntry entry;
  final GoalProgress progress;
  final Household household;
  final VoidCallback onTap;

  /// Reaksi dan komentar setoran ini (v1.x); kosong di Ruang Pribadi.
  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;
    final mine = entry.userId == null || entry.userId == household.me.id;
    // Label yang sama seperti di chip penanggung jawab: "Aku" atau "Pasangan · sisa gajian".
    final who = mine ? l10n.labelMe : l10n.labelPartner;
    final note = entry.note;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightHistory),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.gap6),
          child: Row(
            children: [
              ColorDot(color: context.personColor(household.colorOf(entry.userId)), size: AppDimens.dotLarge),
              const SizedBox(width: AppDimens.gap10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.isWithdrawal
                          ? (note == null
                                ? l10n.savingsHistoryWithdrawal(who)
                                : l10n.savingsHistoryWithdrawalNote(who, note))
                          : (note == null ? who : l10n.savingsHistoryWho(who, note)),
                      style: text.bodyStrong,
                    ),
                    Text(
                      formatDayShort(entry.entryDate, currentYear: parseYmd(progress.today).year),
                      style: text.small,
                    ),
                    if (!conversation.isEmpty) ...[
                      const SizedBox(height: AppDimens.gap2),
                      ConversationBadge(conversation: conversation),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.gap8),
              Text(formatMoney(entry.signedAmount, progress.goal.currency, withSign: true), style: text.amount),
            ],
          ),
        ),
      ),
    );
  }
}
