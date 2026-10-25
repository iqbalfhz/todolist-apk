import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/features/memories/domain/memory.dart';
import 'package:todolist/features/memories/domain/memory_views.dart';
import 'package:todolist/features/memories/presentation/memory_detail_screen.dart';
import 'package:todolist/features/spaces/domain/space.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

String _memoryId(int n) => '01m4dr8c50jk2mt7xw3pq9vb${n.toString().padLeft(2, '0')}';

MemoryItem _item(String visitedOn, {int n = 0}) => MemoryItem(
  memory: Memory.fromJson(memoryJson(id: _memoryId(n), visitedOn: visitedOn)),
  space: Space.fromJson(sharedSpaceJson()),
  photos: const [],
);

List<(String, int)> _onThisDay(List<String> visited, String today) {
  final items = [for (final (n, date) in visited.indexed) _item(date, n: n)]..sort(compareMemories);
  return [for (final match in memoriesOnThisDay(items, today)) (match.item.memory.visitedOn, match.yearsAgo)];
}

void main() {
  setUpAll(prepareAppTests);

  group('kenangan hari ini di tahun-tahun lalu', () {
    test('tanggal dan bulan sama di tahun sebelumnya, yang paling baru dulu', () {
      expect(_onThisDay(['2023-10-08', '2025-10-08', '2026-10-08', '2025-10-09', '2024-11-08'], '2026-10-08'), [
        ('2025-10-08', 1),
        ('2023-10-08', 3),
      ]);
      expect(_onThisDay(['2025-10-07'], '2026-10-08'), isEmpty);
    });

    test('kenangan 29 Februari muncul di 28 Februari tahun yang bukan kabisat', () {
      expect(_onThisDay(['2024-02-29', '2025-02-28'], '2027-02-28'), [('2025-02-28', 2), ('2024-02-29', 3)]);
      expect(_onThisDay(['2024-02-29'], '2028-02-28'), isEmpty, reason: '2028 kabisat, jadi tunggu 29 Februari');
      expect(_onThisDay(['2024-02-29'], '2028-02-29'), [('2024-02-29', 4)]);
    });
  });

  group('Beranda', () {
    testWidgets('kartu "Setahun lalu, hari ini" membuka Detail kenangan', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(
        EntityType.memory,
        memoryJson(id: _memoryId(1), title: 'Piknik di Kebun Raya', placeName: 'Bogor', visitedOn: '2025-10-08'),
        serverUpdatedAt: t0,
      );
      await h.account.store.write(
        EntityType.memory,
        memoryJson(id: _memoryId(2), title: 'Bukan hari ini', visitedOn: '2025-10-09'),
        serverUpdatedAt: t0,
      );
      await pumpApp(tester, h);

      expect(find.text('Setahun lalu, hari ini'), findsOneWidget);
      expect(find.text('Piknik di Kebun Raya'), findsOneWidget);
      expect(find.text('Rab, 8 Okt 2025 · Bogor'), findsOneWidget);
      expect(find.text('Bukan hari ini'), findsNothing);

      await tester.tap(find.text('Piknik di Kebun Raya'));
      await settle(tester);
      expect(find.byType(MemoryDetailScreen), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('tanpa kenangan di tanggal ini: tidak ada kartu; lebih dari dua: tautan ke Kenangan', (tester) async {
      final h = Harness();
      await h.seed();
      await pumpApp(tester, h);
      expect(find.textContaining('lalu, hari ini'), findsNothing);

      for (final (n, year) in [2025, 2024, 2023, 2020].indexed) {
        await h.account.store.write(
          EntityType.memory,
          memoryJson(id: _memoryId(n), title: 'Kenangan $year', visitedOn: '$year-10-08'),
          serverUpdatedAt: t0,
        );
      }
      await settle(tester);

      expect(find.text('Setahun lalu, hari ini'), findsOneWidget);
      expect(find.text('2 tahun lalu, hari ini'), findsOneWidget);
      expect(find.text('Kenangan 2023'), findsNothing);
      expect(find.text('2 kenangan lain di tanggal ini'), findsOneWidget);

      await tester.tap(find.text('2 kenangan lain di tanggal ini'));
      await settle(tester);
      expect(find.text('Kenangan 2020'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
