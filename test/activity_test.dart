import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/l10n/generated/app_localizations_id.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/features/activity/domain/activity.dart';
import 'package:todolist/features/activity/presentation/activity_screen.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/comments/domain/comment.dart';
import 'package:todolist/features/memories/domain/memory.dart';
import 'package:todolist/features/memories/domain/memory_photo.dart';
import 'package:todolist/features/savings/domain/savings_entry.dart';
import 'package:todolist/features/savings/domain/savings_goal.dart';
import 'package:todolist/features/spaces/domain/household.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/special_dates/domain/special_date.dart';
import 'package:todolist/features/tasks/domain/task.dart';
import 'package:todolist/features/tasks/presentation/task_detail_screen.dart';
import 'package:todolist/features/trips/domain/trip.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

/// Feed aktivitas (v1.x): dihitung di HP dari data sync.
void main() {
  setUpAll(prepareAppTests);

  // 8 Oktober 2026, 19.00 WIB.
  final now = DateTime.utc(2026, 10, 8, 12);
  String at(int day, int hourUtc) => DateTime.utc(2026, 10, day, hourUtc).toIso8601String();

  final l10n = AppLocalizationsId();
  final household = Household(
    me: User.fromJson(userJson()),
    spaces: [Space.fromJson(sharedSpaceJson()), Space.fromJson(personalSpaceJson())],
  );

  List<ActivityEvent> events({
    List<Map<String, dynamic>> tasks = const [],
    List<Map<String, dynamic>> goals = const [],
    List<Map<String, dynamic>> entries = const [],
    List<Map<String, dynamic>> trips = const [],
    List<Map<String, dynamic>> dates = const [],
    List<Map<String, dynamic>> memories = const [],
    List<Map<String, dynamic>> photos = const [],
    List<Map<String, dynamic>> comments = const [],
    List<Map<String, dynamic>> reactions = const [],
    Map<String, dynamic>? shared,
  }) => activityEvents(
    shared: Space.fromJson(shared ?? {...sharedSpaceJson(), 'members': <dynamic>[]}),
    now: now,
    clock: SpaceClock(now: () => now),
    tasks: [for (final row in tasks) Task.fromJson(row)],
    goals: [for (final row in goals) SavingsGoal.fromJson(row)],
    entries: [for (final row in entries) SavingsEntry.fromJson(row)],
    trips: [for (final row in trips) Trip.fromJson(row)],
    dates: [for (final row in dates) SpecialDate.fromJson(row)],
    memories: [for (final row in memories) Memory.fromJson(row)],
    photos: [for (final row in photos) MemoryPhoto.fromJson(row)],
    comments: [for (final row in comments) Comment.fromJson(row)],
    reactions: [for (final row in reactions) Reaction.fromJson(row)],
  );

  List<String> sentences(List<ActivityEvent> events) => [
    for (final event in events) activitySentence(l10n, event, household),
  ];

  group('kejadian', () {
    test('tugas baru, titipan ke kamu atau ke pasangan, dan tugas selesai', () {
      final result = events(
        tasks: [
          {
            ...taskJson(id: 'a', title: 'Beli galon', assigneeIds: [meId]),
            'created_by': partnerId,
            'created_at': at(8, 9),
          },
          {
            ...taskJson(id: 'b', title: 'Cuci mobil', assigneeIds: [partnerId]),
            'created_at': at(8, 8),
          },
          {
            ...taskJson(id: 'c', title: 'Belanja bulanan', assigneeIds: [meId, partnerId]),
            'created_at': at(8, 7),
          },
          {
            ...taskJson(id: 'd', title: 'Bayar listrik', completedAt: at(8, 10), completedBy: partnerId),
            'created_at': at(1, 7),
          },
        ],
      );

      expect(sentences(result), [
        'Sari menyelesaikan Bayar listrik',
        'Sari menitipkan Beli galon ke kamu',
        'Kamu menitipkan Cuci mobil ke Sari',
        'Kamu menambah tugas Belanja bulanan',
        'Kamu menambah tugas Bayar listrik',
      ]);
      expect(
        [for (final event in result) event.route],
        [Routes.task('d'), Routes.task('a'), Routes.task('b'), Routes.task('c'), Routes.task('d')],
      );
    });

    test('setoran, penarikan, target baru, dan target tercapai tanpa pelaku', () {
      final result = events(
        goals: [
          {
            ...goalJson(name: 'Dana Liburan'),
            'created_by': partnerId,
            'created_at': at(2, 3),
            'achieved_at': at(8, 11),
          },
        ],
        entries: [
          {...entryJson(id: 'e1', userId: partnerId, amount: 200000), 'created_at': at(8, 10)},
          {...entryJson(id: 'e2', amount: 100000), 'type': 'withdrawal', 'created_at': at(7, 10)},
        ],
      );

      expect(sentences(result), [
        'Dana Liburan tercapai',
        'Sari menabung Rp200.000 untuk Dana Liburan',
        'Kamu mengambil Rp100.000 dari Dana Liburan',
        'Sari membuat target Dana Liburan',
      ]);
      expect(result.first.actorId, isNull);
      expect(result.every((event) => event.route == Routes.goal(goalId)), isTrue);
    });

    test('perjalanan, tanggal penting, kenangan, dan foto baru di kenangan lama digabung per hari', () {
      final result = events(
        trips: [
          {...tripJson(title: 'Liburan ke Bali'), 'created_by': partnerId, 'created_at': at(6, 1)},
        ],
        dates: [
          {...specialDateJson(title: 'Hari jadi'), 'created_at': at(5, 1)},
        ],
        memories: [
          {...memoryJson(title: 'Pantai Kuta', createdAt: at(3, 1)), 'created_by': partnerId},
        ],
        photos: [
          // Diunggah di hari kenangannya dibuat: ikut kejadian kenangan itu.
          {...memoryPhotoJson(id: 'f0'), 'created_at': at(3, 2)},
          for (final (id, hour) in [('f1', 1), ('f2', 2), ('f3', 3)])
            {...memoryPhotoJson(id: id), 'created_at': at(7, hour)},
          {...memoryPhotoJson(id: 'f4'), 'uploaded_by': meId, 'created_at': at(8, 1)},
        ],
      );

      expect(sentences(result), [
        'Kamu menambah 1 foto ke Pantai Kuta',
        'Sari menambah 3 foto ke Pantai Kuta',
        'Sari merencanakan Liburan ke Bali',
        'Kamu menambah tanggal penting Hari jadi',
        'Sari menyimpan kenangan Pantai Kuta',
      ]);
      expect(result[1].time, DateTime.parse(at(7, 3)));
      expect(
        [for (final event in result) event.route],
        [
          Routes.memory(memoryId),
          Routes.memory(memoryId),
          Routes.trip(tripId),
          Routes.specialDates,
          Routes.memory(memoryId),
        ],
      );
    });

    test('komentar dan reaksi menyebut subjeknya dan membuka bagian komentarnya', () {
      final result = events(
        tasks: [
          {...taskJson(title: 'Beli galon'), 'created_at': at(1, 1)},
        ],
        goals: [
          {...goalJson(name: 'Dana Liburan'), 'created_at': at(1, 1)},
        ],
        entries: [
          {...entryJson(amount: 200000), 'created_at': at(1, 2)},
        ],
        memories: [memoryJson(title: 'Pantai Kuta', createdAt: at(1, 3))],
        comments: [
          commentJson(id: 'k1', body: 'Sudah, ya!', createdAt: at(8, 9)),
          commentJson(id: 'k2', subjectType: 'savings_entry', subjectId: entryId, body: 'Mantap', createdAt: at(8, 8)),
          // Subjeknya sudah dihapus: tidak tampil.
          commentJson(id: 'k3', subjectId: 'tugas-terhapus', body: 'Hilang', createdAt: at(8, 7)),
        ],
        reactions: [
          reactionJson(id: 'r1', subjectType: 'memory', subjectId: memoryId, emoji: '❤️', createdAt: at(8, 6)),
        ],
      );

      expect(sentences(result).take(3), [
        'Sari mengomentari Beli galon: Sudah, ya!',
        'Sari mengomentari setoran Rp200.000: Mantap',
        'Sari memberi reaksi ❤️ ke Pantai Kuta',
      ]);
      expect(
        [for (final event in result.take(3)) event.route],
        [
          Routes.task(taskId, comments: true),
          Routes.goal(goalId, entryId: entryId),
          Routes.memory(memoryId, comments: true),
        ],
      );
    });

    test('bergabung ke Ruang Bersama', () {
      final result = events(
        shared: {
          ...sharedSpaceJson(),
          'members': [
            {...memberJson(id: meId, name: 'Iqbal', color: 'mawar', role: 'owner'), 'joined_at': at(1, 1)},
            {...memberJson(id: partnerId, name: 'Sari', color: 'ungu'), 'joined_at': at(1, 2)},
          ],
        },
      );

      expect(sentences(result), ['Sari bergabung ke Ruang Bersama', 'Kamu bergabung ke Ruang Bersama']);
      expect(result.first.route, isNull);
    });

    test('hanya Ruang Bersama, 30 hari terakhir, dan data yang belum dihapus', () {
      final result = events(
        tasks: [
          {...taskJson(id: 'pribadi', spaceId: personalSpaceId), 'created_at': at(8, 1)},
          {...taskJson(id: 'terhapus', deletedAt: at(8, 2)), 'created_at': at(8, 1)},
          {...taskJson(id: 'lama'), 'created_at': DateTime.utc(2026, 9, 7).toIso8601String()},
          // Hasil impor memakai created_at dari file: muncul di waktu aslinya.
          {
            ...taskJson(id: 'impor', title: 'Dari file lama'),
            'created_at': DateTime.utc(2026, 9, 10).toIso8601String(),
          },
        ],
      );

      expect(sentences(result), ['Kamu menambah tugas Dari file lama']);
    });
  });

  group('layar', () {
    testWidgets('lonceng di Beranda bertitik untuk kegiatan pasangan; feed per hari dengan saringan pasangan saja', (
      tester,
    ) async {
      final h = Harness();
      await h.seed(withTask: true);
      // Pasangan menyelesaikan tugas kemarin malam (7 Oktober, 20.00 WIB) dan menulis komentar tadi.
      await h.account.store.write(
        EntityType.task,
        taskJson(
          title: 'Beli galon',
          completedAt: DateTime.utc(2026, 10, 7, 13).toIso8601String(),
          completedBy: partnerId,
        ),
        serverUpdatedAt: t0,
      );
      await h.account.store.write(
        EntityType.comment,
        commentJson(body: 'Sudah, ya!', createdAt: DateTime.utc(2026, 10, 8, 9).toIso8601String()),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);

      expect(find.byTooltip('Aktivitas, ada kegiatan baru dari pasangan'), findsOneWidget);
      await tester.tap(find.byTooltip('Aktivitas, ada kegiatan baru dari pasangan'));
      await settle(tester);

      expect(find.byType(ActivityScreen), findsOneWidget);
      expect(find.text('Hari ini'), findsOneWidget);
      expect(find.text('Kemarin'), findsOneWidget);
      expect(find.text('Sari mengomentari Beli galon: Sudah, ya!'), findsOneWidget);
      expect(find.text('Sari menyelesaikan Beli galon'), findsOneWidget);
      expect(find.text('20.00'), findsOneWidget);
      expect(find.text('Kamu menambah tugas Beli galon'), findsOneWidget);

      await tester.tap(find.text('Pasangan saja'));
      await settle(tester);
      expect(find.text('Kamu menambah tugas Beli galon'), findsNothing);
      expect(find.text('Sari menyelesaikan Beli galon'), findsOneWidget);

      // Diketuk: sama dengan mengetuk notifikasinya.
      await tester.tap(find.text('Sari menyelesaikan Beli galon'));
      await settle(tester);
      expect(find.byType(TaskDetailScreen), findsOneWidget);

      container.read(routerProvider).go(Routes.home);
      await settle(tester);
      expect(find.byTooltip('Aktivitas'), findsOneWidget);
      expect(find.byTooltip('Aktivitas, ada kegiatan baru dari pasangan'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('belum berpasangan: ajakan Ajak pasangan', (tester) async {
      final h = Harness();
      await h.seedUnpaired();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.activity);
      await settle(tester);

      expect(
        find.text('Aktivitas berisi kegiatan kalian berdua di Ruang Bersama. Ajak pasanganmu dulu.'),
        findsOneWidget,
      );
      expect(find.text('Ajak pasangan'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });
}
