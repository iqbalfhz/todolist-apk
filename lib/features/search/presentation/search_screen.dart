import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/widgets.dart';
import '../../home/presentation/main_shell.dart';
import '../../memories/domain/memory_views.dart';
import '../../savings/domain/savings_entry.dart';
import '../../savings/domain/savings_views.dart';
import '../../spaces/domain/household.dart';
import '../../special_dates/domain/upcoming_dates.dart';
import '../../special_dates/presentation/special_date_text.dart';
import '../../tasks/domain/task_views.dart';
import '../../tasks/presentation/task_text.dart';
import '../../trips/domain/trip_views.dart';
import '../../trips/presentation/trip_text.dart';
import '../domain/search.dart';

/// Cari (v1.x): satu kolom pencarian untuk tugas, tabungan, setoran, liburan, kenangan,
/// dan tanggal penting di HP ini. Hasil dikelompokkan per jenis; ketuk membuka detailnya.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller = TextEditingController(text: ref.read(searchTextProvider));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.home);

  void _clear() {
    _controller.clear();
    ref.read(searchTextProvider.notifier).set('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = SearchQuery.parse(ref.watch(searchTextProvider));
    // Kata kunci yang diganti dari luar kolom ini (misalnya akun berganti) ikut tampil.
    ref.listen(searchTextProvider, (_, next) {
      if (_controller.text != next) _controller.text = next;
    });

    return AppScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageSide - AppDimens.gap10,
              AppDimens.gap12,
              AppDimens.pageSide,
              AppDimens.gap8,
            ),
            child: Row(
              children: [
                BackIconButton(label: l10n.commonBack, onPressed: _back),
                const SizedBox(width: AppDimens.gap4),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: context.text.input,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Symbols.search_rounded, size: AppDimens.iconXl),
                      suffixIcon: query.text.isEmpty
                          ? null
                          : AppIconButton(icon: Symbols.close_rounded, label: l10n.searchClear, onPressed: _clear),
                    ),
                    onChanged: (value) => ref.read(searchTextProvider.notifier).set(value),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _Results(query: query)),
        ],
      ),
    );
  }
}

/// Satu kelompok hasil: judul, ikon, dan barisnya.
class _Section {
  const _Section({required this.title, required this.icon, required this.rows});

  final String title;
  final IconData icon;
  final List<_Row> rows;
}

class _Row {
  const _Row({required this.key, required this.hit, required this.subtitle, required this.route});

  final String key;
  final SearchHit<Object> hit;
  final String subtitle;
  final String route;
}

class _Results extends ConsumerWidget {
  const _Results({required this.query});

  final SearchQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = context.text;
    final household = ref.watch(householdProvider);
    final tasks = ref.watch(taskItemsProvider);
    final goals = ref.watch(goalProgressProvider);
    final trips = ref.watch(tripItemsProvider);
    final memories = ref.watch(memoryItemsProvider);
    final dates = ref.watch(upcomingDatesProvider);

    final padding = const EdgeInsets.fromLTRB(
      AppDimens.pageSide,
      AppDimens.gap8,
      AppDimens.pageSide,
      AppDimens.pageBottom,
    );

    if (!query.isSearchable) {
      return ListView(
        padding: padding,
        children: [EmptyState(message: l10n.searchIntro, icon: Symbols.manage_search_rounded)],
      );
    }

    if (household == null || tasks == null || goals == null || trips == null || memories == null || dates == null) {
      return ListView(padding: padding, children: const [SkeletonCard(lines: 3)]);
    }

    final currentYear = parseYmd(ref.watch(spaceClockProvider).today(household.me.timezone)).year;
    final sections = [
      _tasks(l10n, tasks),
      _goals(l10n, goals),
      _entries(l10n, goals, currentYear),
      _trips(l10n, trips),
      _memories(l10n, memories, currentYear),
      _dates(l10n, dates, currentYear),
    ].where((section) => section.rows.isNotEmpty).toList();
    final total = sections.fold(0, (sum, section) => sum + section.rows.length);

    return ListView(
      padding: padding,
      children: [
        // Jumlah hasil dibacakan setiap berubah.
        Semantics(liveRegion: true, child: Text(total == 0 ? '' : l10n.searchCount(total), style: text.caption)),
        if (total == 0) EmptyState(message: l10n.searchEmpty(query.text), icon: Symbols.search_off_rounded),
        for (final section in sections) ...[
          const SizedBox(height: AppDimens.gap8),
          _SectionView(key: ValueKey(section.title), section: section, tokens: query.tokens),
        ],
      ],
    );
  }

  _Section _tasks(AppLocalizations l10n, List<TaskItem> items) {
    // Yang belum selesai dulu, lalu yang terakhir diubah.
    final sorted = [...items]
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return b.task.updatedAt.compareTo(a.task.updatedAt);
      });
    final hits = searchItems(sorted, query, title: (item) => item.task.title, others: (item) => [item.task.notes]);

    return _Section(
      title: l10n.navTasks,
      icon: Symbols.task_alt_rounded,
      rows: [
        for (final hit in hits)
          _Row(
            key: hit.item.task.id,
            hit: hit,
            subtitle: [
              hit.item.list.name,
              if (hit.item.isCompleted) l10n.statusDone else if (hit.item.task.dueDate != null) dueText(l10n, hit.item),
            ].join(' · '),
            route: hit.item.list.tripId == null
                ? Routes.task(hit.item.task.id)
                : Routes.tripTask(hit.item.list.tripId!, hit.item.task.id),
          ),
      ],
    );
  }

  _Section _goals(AppLocalizations l10n, List<GoalProgress> goals) {
    final hits = searchItems(goals, query, title: (progress) => progress.goal.name);

    return _Section(
      title: l10n.navSavings,
      icon: Symbols.savings_rounded,
      rows: [
        for (final hit in hits)
          _Row(
            key: hit.item.goal.id,
            hit: hit,
            subtitle: [
              l10n.percent(hit.item.percent),
              l10n.savingsOf(
                formatMoney(hit.item.saved, hit.item.goal.currency),
                formatMoney(hit.item.goal.targetAmount, hit.item.goal.currency),
              ),
              if (hit.item.goal.isArchived) l10n.listArchivedSection,
            ].join(' · '),
            route: Routes.goal(hit.item.goal.id),
          ),
      ],
    );
  }

  /// Setoran dicari dari catatannya; yang terbaru dulu.
  _Section _entries(AppLocalizations l10n, List<GoalProgress> goals, int currentYear) {
    final entries = [
      for (final progress in goals)
        for (final entry in progress.entries)
          if (entry.note != null) (entry: entry, progress: progress),
    ]..sort((a, b) => b.entry.entryDate.compareTo(a.entry.entryDate));
    final hits = searchItems<({SavingsEntry entry, GoalProgress progress})>(
      entries,
      query,
      title: (item) => item.entry.note!,
    );

    return _Section(
      title: l10n.searchSectionEntries,
      icon: Symbols.payments_rounded,
      rows: [
        for (final hit in hits)
          _Row(
            key: hit.item.entry.id,
            hit: hit,
            subtitle: [
              formatMoney(hit.item.entry.amount, hit.item.progress.goal.currency, withSign: true),
              formatDayShort(hit.item.entry.entryDate, currentYear: currentYear),
              hit.item.progress.goal.name,
            ].join(' · '),
            route: Routes.goal(hit.item.progress.goal.id),
          ),
      ],
    );
  }

  _Section _trips(AppLocalizations l10n, List<TripItem> trips) {
    final hits = searchItems(
      trips,
      query,
      title: (item) => item.trip.title,
      others: (item) => [item.trip.destination, item.trip.notes],
    );

    return _Section(
      title: l10n.navTrips,
      icon: Symbols.flight_takeoff_rounded,
      rows: [
        for (final hit in hits)
          _Row(
            key: hit.item.trip.id,
            hit: hit,
            subtitle: [
              ?hit.item.trip.destination,
              tripDates(l10n, hit.item, currentYear: currentYearOf(hit.item)) ?? l10n.tripUndated,
            ].join(' · '),
            route: Routes.trip(hit.item.trip.id),
          ),
      ],
    );
  }

  _Section _memories(AppLocalizations l10n, List<MemoryItem> memories, int currentYear) {
    final hits = searchItems(
      memories,
      query,
      title: (item) => item.memory.title,
      others: (item) => [item.memory.placeName, item.memory.story],
    );

    return _Section(
      title: l10n.navMemories,
      icon: Symbols.photo_library_rounded,
      rows: [
        for (final hit in hits)
          _Row(
            key: hit.item.memory.id,
            hit: hit,
            subtitle: [
              formatDayShort(hit.item.memory.visitedOn, currentYear: currentYear),
              ?hit.item.memory.placeName,
            ].join(' · '),
            route: Routes.memory(hit.item.memory.id),
          ),
      ],
    );
  }

  /// Tanggal penting dan ulang tahun anggota, yang paling dekat dulu.
  _Section _dates(AppLocalizations l10n, UpcomingDates dates, int currentYear) {
    final hits = searchItems(dates.items, query, title: (item) => upcomingTitle(l10n, item));

    return _Section(
      title: l10n.datesTitle,
      icon: Symbols.favorite_rounded,
      rows: [
        for (final hit in hits)
          _Row(
            key: hit.item.key,
            hit: hit,
            subtitle: [
              upcomingDay(hit.item, currentYear: currentYear),
              countdownLong(l10n, hit.item.daysLeft),
            ].join(' · '),
            route: Routes.specialDates,
          ),
      ],
    );
  }
}

/// Kelompok hasil: judul dengan ikon dan jumlahnya, lalu kartu berisi paling banyak
/// [_shown] baris; sisanya dibuka dengan "Tampilkan semua".
class _SectionView extends StatefulWidget {
  const _SectionView({super.key, required this.section, required this.tokens});

  final _Section section;
  final List<String> tokens;

  @override
  State<_SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<_SectionView> {
  static const int _shown = 5;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final section = widget.section;
    final rows = _expanded ? section.rows : section.rows.take(_shown).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.gap6),
          child: Row(
            children: [
              Icon(section.icon, size: AppDimens.iconMd, color: palette.brand),
              const SizedBox(width: AppDimens.gap8),
              Expanded(
                child: Semantics(header: true, child: Text(section.title, style: context.text.sectionTitle)),
              ),
              Text(l10n.searchCount(section.rows.length), style: context.text.caption),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gap8),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0) const RowDivider(),
                _ResultRow(key: ValueKey(row.key), row: row, tokens: widget.tokens),
              ],
            ],
          ),
        ),
        if (!_expanded && section.rows.length > _shown)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => setState(() => _expanded = true),
              child: Text(l10n.searchShowAll(section.rows.length)),
            ),
          ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({super.key, required this.row, required this.tokens});

  final _Row row;
  final List<String> tokens;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final palette = context.palette;
    final snippet = row.hit.snippet;

    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => context.go(row.route),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightTall),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.gap10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HighlightedText(row.hit.title, tokens: tokens, style: text.rowTitle),
                  const SizedBox(height: AppDimens.gap2),
                  Text(row.subtitle, style: text.caption),
                  if (snippet != null) ...[
                    const SizedBox(height: AppDimens.gap4),
                    HighlightedText(
                      snippet,
                      tokens: tokens,
                      style: text.caption.copyWith(color: palette.muted),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Teks dengan bagian yang cocok dengan kata kunci ditebalkan dan diberi latar `soft`.
class HighlightedText extends StatelessWidget {
  const HighlightedText(this.text, {super.key, required this.tokens, required this.style, this.maxLines});

  final String text;
  final List<String> tokens;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final strong = style.copyWith(
      fontWeight: FontWeight.w700,
      color: context.palette.text,
      backgroundColor: context.palette.soft,
    );
    final spans = <TextSpan>[];
    var at = 0;
    for (final (start, end) in matchRanges(text, tokens)) {
      if (start > at) spans.add(TextSpan(text: text.substring(at, start)));
      spans.add(TextSpan(text: text.substring(start, end), style: strong));
      at = end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
