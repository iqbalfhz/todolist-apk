import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/mappers.dart';
import 'package:todolist/core/l10n/l10n.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/core/utils/dates.dart';
import 'package:todolist/core/utils/validators.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/savings/domain/savings_entry.dart';
import 'package:todolist/features/savings/domain/savings_goal.dart';
import 'package:todolist/features/savings/domain/savings_views.dart';
import 'package:todolist/features/spaces/domain/household.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/tasks/data/task_list_repository.dart';
import 'package:todolist/features/tasks/domain/task.dart';
import 'package:todolist/features/tasks/domain/task_list.dart';
import 'package:todolist/features/tasks/domain/task_views.dart';
import 'package:todolist/features/trips/data/trip_repository.dart';
import 'package:todolist/features/trips/domain/trip.dart';
import 'package:todolist/features/trips/domain/trip_views.dart';
import 'package:todolist/features/trips/presentation/trip_text.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_api.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

/// Item checklist yang sudah beres.
const String passportTaskId = '01m4dq7ta0b4xr1n2k3m4p5q6a';

/// Item checklist yang bertenggat hari ini (8 Okt 2026).
const String sunscreenTaskId = '01m4dq7ta0b4xr1n2k3m4p5q6b';

extension TripsHarness on Harness {
  /// Liburan ke Bali (20–25 Jun 2027) dengan checklist berisi dua item: "Perpanjang paspor"
  /// sudah beres, "Beli sunscreen" bertenggat hari ini. Datanya juga ada "di server".
  Future<void> seedTrip({
    String? startDate = '2027-06-20',
    String? endDate = '2027-06-25',
    String? savingsGoalId,
  }) async {
    final rows = <(EntityType, String, Map<String, dynamic>)>[
      (EntityType.trip, 'trips', tripJson(startDate: startDate, endDate: endDate, savingsGoalId: savingsGoalId)),
      (EntityType.list, 'lists', checklistJson()),
      (
        EntityType.task,
        'tasks',
        taskJson(
          id: passportTaskId,
          taskListId: checklistId,
          title: 'Perpanjang paspor',
          completedAt: t1,
          completedBy: meId,
          position: 1024,
        ),
      ),
      (
        EntityType.task,
        'tasks',
        taskJson(id: sunscreenTaskId, taskListId: checklistId, title: 'Beli sunscreen', dueDate: '2026-10-08'),
      ),
    ];
    for (final (type, resource, row) in rows) {
      await account.store.write(type, row, serverUpdatedAt: t0);
      api.rows.putIfAbsent(resource, () => {})[row['id'] as String] = row;
    }
  }
}

void main() {
  setUpAll(prepareAppTests);

  final l10n = lookupAppLocalizations(const Locale('id'));

  Map<String, dynamic> payloadOf(OutboxRow op) => jsonDecode(op.payload!) as Map<String, dynamic>;

  // ------------------------------------------------------------------ status dan teks

  group('status perjalanan', () {
    TripItem itemOn(String today, {String? start = '2027-06-20', String? end = '2027-06-25'}) => TripItem(
      trip: Trip.fromJson(tripJson(startDate: start, endDate: end)),
      space: Space.fromJson(sharedSpaceJson()),
      today: today,
      checklist: null,
      items: const [],
      goal: null,
    );

    test('direncanakan: hitung mundur sampai hari berangkat', () {
      final item = itemOn('2027-06-08');
      expect(item.status, TripStatus.planned);
      expect(item.daysUntilStart, 12);
      expect(item.durationDays, 6);
      expect(tripCountdown(l10n, item), '12 hari lagi');
      expect(tripCountdown(l10n, itemOn('2027-06-19')), 'Besok berangkat');
    });

    test('berlangsung dari tanggal mulai sampai tanggal selesai', () {
      expect(itemOn('2027-06-20').status, TripStatus.ongoing);
      expect(tripCountdown(l10n, itemOn('2027-06-21')), 'Hari ke-2 dari 6');
      expect(tripCountdown(l10n, itemOn('2027-06-25')), 'Hari ke-6 dari 6');
      expect(itemOn('2027-06-26').status, TripStatus.done);
      expect(tripCountdown(l10n, itemOn('2027-06-26')), 'Selesai');
    });

    test('tanpa tanggal selesai: perjalanan sehari, berlangsung hanya di tanggal mulai', () {
      final day = itemOn('2027-06-20', end: null);
      expect(day.status, TripStatus.ongoing);
      expect(day.durationDays, 1);
      expect(tripCountdown(l10n, day), 'Sedang berlangsung');
      expect(itemOn('2027-06-21', end: null).status, TripStatus.done);
    });

    test('tanggal belum pasti: tetap direncanakan, tanpa hitung mundur', () {
      final undated = itemOn('2030-01-01', start: null, end: null);
      expect(undated.status, TripStatus.planned);
      expect(undated.daysUntilStart, isNull);
      expect(undated.durationDays, isNull);
      expect(tripCountdown(l10n, undated), 'Tanggal belum pasti');
      expect(tripDates(l10n, undated, currentYear: 2030), isNull);
    });

    test('rentang tanggal ringkas, tahun hanya kalau bukan tahun ini', () {
      expect(formatDateRange('2027-06-20', '2027-06-25', currentYear: 2026), '20–25 Jun 2027');
      expect(formatDateRange('2027-06-20', '2027-06-25', currentYear: 2027), '20–25 Jun');
      expect(formatDateRange('2027-06-28', '2027-07-03', currentYear: 2027), '28 Jun – 3 Jul');
      expect(formatDateRange('2026-12-28', '2027-01-03', currentYear: 2026), '28 Des 2026 – 3 Jan 2027');
      expect(formatDateRange('2027-06-20', null, currentYear: 2027), 'Min, 20 Jun');
      expect(tripDates(l10n, itemOn('2026-10-08'), currentYear: 2026), '20–25 Jun 2027 · 6 hari');
    });

    test('nama hari pengingat setor: 1 = Senin sampai 7 = Minggu', () {
      expect(
        [for (var day = 1; day <= 7; day++) weekdayName(day)],
        ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
      );
      expect(weekdayName(5, short: true), 'Jum');
    });
  });

  group('daftar perjalanan', () {
    final clock = SpaceClock(now: () => DateTime.utc(2027, 6, 21, 3));
    final household = Household(
      me: User.fromJson(userJson()),
      spaces: [Space.fromJson(sharedSpaceJson()), Space.fromJson(personalSpaceJson())],
    );

    test('urut: berlangsung, paling dekat berangkat, belum pasti, lalu yang sudah selesai', () {
      Trip trip(String id, {String? start, String? end, String createdAt = t0}) =>
          Trip.fromJson({...tripJson(id: id, title: id, startDate: start, endDate: end), 'created_at': createdAt});

      final items = buildTripItems(
        trips: [
          trip('selesai-lama', start: '2027-01-02', end: '2027-01-05'),
          trip('belum-pasti-lama', createdAt: t0),
          trip('agustus', start: '2027-08-17'),
          trip('bali', start: '2027-06-20', end: '2027-06-25'),
          trip('selesai-baru', start: '2027-05-01', end: '2027-05-03'),
          trip('juli', start: '2027-07-01'),
          trip('belum-pasti-baru', createdAt: t2),
        ],
        lists: const [],
        taskItems: const [],
        goals: const [],
        household: household,
        clock: clock,
      )..sort(compareTrips);

      expect(
        [for (final item in items) item.trip.id],
        ['bali', 'juli', 'agustus', 'belum-pasti-baru', 'belum-pasti-lama', 'selesai-baru', 'selesai-lama'],
      );
      expect(featuredTrip(items)!.trip.id, 'bali');
      expect(featuredTrip(items.where((item) => item.isDone).toList()), isNull);
    });

    test('progres dari item checklist, dan dana dari target yang ditautkan', () {
      final lists = [TaskList.fromJson(checklistJson()), TaskList.fromJson(listJson())];
      final taskItems = buildTaskItems(
        tasks: [
          Task.fromJson(taskJson(id: passportTaskId, taskListId: checklistId, completedAt: t1)),
          Task.fromJson(taskJson(id: sunscreenTaskId, taskListId: checklistId)),
          // Tugas di daftar biasa tidak ikut dihitung.
          Task.fromJson(taskJson()),
        ],
        lists: lists,
        household: household,
        clock: clock,
      );
      final goals = buildGoalProgress(
        goals: [SavingsGoal.fromJson(goalJson())],
        entries: [SavingsEntry.fromJson(entryJson(amount: 6500000))],
        household: household,
        today: clock.today,
      );

      final item = buildTripItems(
        trips: [
          Trip.fromJson(tripJson(savingsGoalId: goalId)),
          // Perjalanan terhapus dan perjalanan di ruang yang tidak dikenal tidak tampil.
          Trip.fromJson(tripJson(id: 'terhapus', deletedAt: t1)),
          Trip.fromJson(tripJson(id: 'asing', spaceId: '01m4dzzzzzzzzzzzzzzzzzzzzz')),
        ],
        lists: lists,
        taskItems: taskItems,
        goals: goals,
        household: household,
        clock: clock,
      ).single;

      expect(item.checklist!.id, checklistId);
      expect([for (final task in item.items) task.task.id], [passportTaskId, sunscreenTaskId]);
      expect((item.done, item.total, item.percent), (1, 2, 50));
      expect([for (final task in item.openItems) task.task.id], [sunscreenTaskId]);
      expect(item.goal!.percent, 65);
    });
  });

  // ------------------------------------------------------------------ data

  group('repository', () {
    late Harness h;

    setUp(() => h = Harness());
    tearDown(() => h.dispose());

    test('nama checklist mengikuti judul dan muat 50 karakter tanpa memotong emoji', () {
      expect(checklistNameFor(' Liburan ke Bali '), 'Persiapan Liburan ke Bali');

      final long = checklistNameFor('a' * 50);
      expect(long, 'Persiapan ${'a' * 39}…');
      expect(textLength(long), Limits.name);

      expect(checklistNameFor('${'a' * 38}👨‍👩‍👧 jalan'), 'Persiapan ${'a' * 38}…');
    });

    test('buat perjalanan: PUT /trips lalu PUT /lists untuk checklistnya, keduanya langsung di HP', () async {
      await h.seed();

      final trip = await h.account.trips.create(
        spaceId: sharedSpaceId,
        title: ' Liburan ke Bali ',
        destination: 'Bali',
        startDate: '2027-06-20',
        endDate: '2027-06-25',
        notes: '  ',
      );

      final ops = await h.ops();
      expect([for (final op in ops) '${op.method} ${op.entityType}'], ['PUT trip', 'PUT list']);
      expect(payloadOf(ops.first), {
        'space_id': sharedSpaceId,
        'title': 'Liburan ke Bali',
        'destination': 'Bali',
        'start_date': '2027-06-20',
        'end_date': '2027-06-25',
        'notes': null,
        'savings_goal_id': null,
      });
      expect(payloadOf(ops.last), {
        'space_id': sharedSpaceId,
        'trip_id': trip.id,
        'name': 'Persiapan Liburan ke Bali',
        'emoji': null,
        'color': 'mawar',
        'position': 2048.0,
      });

      final checklist = TaskList.fromJson((await h.local(EntityType.list, ops.last.entityId))!);
      expect(checklist.isChecklist, isTrue);
      expect(checklist.isRegularActive, isFalse);

      expect(await h.account.outbox.flush(), FlushState.idle);
      expect(h.api.log, ['PUT /trips/${trip.id}', 'PUT /lists/${checklist.id}']);
    });

    test(
      'aturan isi sama dengan server: judul wajib, tanggal pulang butuh dan tidak sebelum tanggal berangkat',
      () async {
        await h.seed();
        Future<Trip> create({String title = 'Bali', String? start, String? end, String? destination, String? notes}) =>
            h.account.trips.create(
              spaceId: sharedSpaceId,
              title: title,
              destination: destination,
              startDate: start,
              endDate: end,
              notes: notes,
            );

        await expectLater(create(title: '  '), throwsArgumentError);
        await expectLater(create(title: 'a' * 51), throwsArgumentError);
        await expectLater(create(destination: 'a' * 101), throwsArgumentError);
        await expectLater(create(notes: 'a' * 5001), throwsArgumentError);
        await expectLater(create(end: '2027-06-25'), throwsArgumentError);
        await expectLater(create(start: '2027-06-20', end: '2027-06-19'), throwsArgumentError);
        await expectLater(create(start: '2027-02-30'), throwsArgumentError);
        expect(await h.ops(), isEmpty);

        await create(title: 'a' * 50, start: '2027-06-20', end: '2027-06-20', destination: 'a' * 100);
        expect(await h.ops(), hasLength(2));
      },
    );

    test('ubah: tanggal selalu dikirim berpasangan, dan nama checklist ikut judulnya', () async {
      await h.seed();
      await h.seedTrip();

      Future<void> edit({String title = 'Liburan ke Bali', String? start = '2027-06-20', String? end = '2027-06-25'}) =>
          h.account.trips.edit(tripId, title: title, destination: 'Bali', startDate: start, endDate: end, notes: null);

      await edit();
      expect(await h.ops(), isEmpty, reason: 'tidak ada yang berubah');

      await edit(end: '2027-06-27');
      expect(payloadOf((await h.ops()).single), {'start_date': '2027-06-20', 'end_date': '2027-06-27'});

      await h.account.outbox.flush();
      await edit(title: 'Bali dan Lombok', end: '2027-06-27');
      final ops = await h.ops();
      expect([for (final op in ops) '${op.method} ${op.entityType}'], ['PATCH trip', 'PATCH list']);
      expect(payloadOf(ops.first), {'title': 'Bali dan Lombok'});
      expect(payloadOf(ops.last), {'name': 'Persiapan Bali dan Lombok'});
    });

    test('hapus: hanya DELETE /trips; checklist dan isinya ditandai terhapus di HP', () async {
      await h.seed();
      await h.seedTrip();

      await h.account.trips.delete(tripId);

      final op = (await h.ops()).single;
      expect('${op.method} ${op.entityType} ${op.entityId}', 'DELETE trip $tripId');
      expect((await h.local(EntityType.list, checklistId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.task, sunscreenTaskId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.task, passportTaskId))!['deleted_at'], isNotNull);
    });

    test('dibuat lalu dihapus saat offline: setelah DELETE terkirim, penghapusan checklist segera ditarik', () async {
      await h.seed();
      final events = <OutboxEvent>[];
      h.account.outbox.events.listen(events.add);

      final trip = await h.account.trips.create(spaceId: sharedSpaceId, title: 'Bali');
      final checklist = (await h.account.store.checklistsOf(trip.id)).single;
      await h.account.trips.delete(trip.id);
      expect(await h.account.store.checklistsOf(trip.id), isEmpty);

      expect(await h.account.outbox.flush(), FlushState.idle);
      await pumpEventQueue();

      expect(h.api.log, ['PUT /trips/${trip.id}', 'PUT /lists/${checklist.id}', 'DELETE /trips/${trip.id}']);
      // Balasan PUT checklist memunculkannya lagi; sync yang diminta membawa penghapusan dari server.
      expect(events.whereType<OutboxNeedsSync>(), hasLength(1));
      h.api.syncPages.add(
        h.api.syncPage(
          taskLists: [
            h.api.row('lists', checklist.id)!
              ..['deleted_at'] = t2
              ..['updated_at'] = t2,
          ],
        ),
      );
      await h.account.sync.sync();
      expect(await h.account.store.checklistsOf(trip.id), isEmpty);
    });

    test('tautkan dan lepas target tabungan', () async {
      await h.seed(withGoal: true);
      await h.seedTrip();

      await h.account.trips.linkGoal(tripId, goalId);
      expect(payloadOf((await h.ops()).single), {'savings_goal_id': goalId});
      await h.account.outbox.flush();

      await h.account.trips.linkGoal(tripId, null);
      expect(payloadOf((await h.ops()).single), {'savings_goal_id': null});
    });

    test('checklist yang belum ada di HP ini dibuat saat dibutuhkan', () async {
      await h.seed();
      final trip = Trip.fromJson(tripJson());
      await h.account.store.write(EntityType.trip, tripJson(), serverUpdatedAt: t0);

      final created = await h.account.trips.checklistFor(trip);
      expect(created.tripId, tripId);
      expect((await h.ops()).single.method, 'PUT');

      final again = await h.account.trips.checklistFor(trip);
      expect(again.id, created.id);
      expect(await h.ops(), hasLength(1));
    });

    test('checklist bukan daftar biasa: tidak dipakai tambah cepat dan tidak dihitung daftar aktif terakhir', () async {
      await h.seed();
      await h.seedTrip();
      final lists = await h.account.store.taskLists();
      final household = Household(
        me: User.fromJson(userJson()),
        spaces: [Space.fromJson(sharedSpaceJson()), Space.fromJson(personalSpaceJson())],
      );

      expect([for (final list in orderLists(lists, household)) list.id], [listId]);
      expect(firstActiveList(lists, sharedSpaceId)!.id, listId);
      await expectLater(h.account.lists.delete(listId), throwsA(isA<LastActiveListException>()));
      await expectLater(h.account.lists.archive(listId), throwsA(isA<LastActiveListException>()));
    });

    test('409 trip_checklist: buang dari antrean, pakai current, dan tampilkan pesan', () async {
      await h.seed();
      await h.seedTrip();
      final events = <OutboxEvent>[];
      h.account.outbox.events.listen(events.add);

      // Hanya terjadi kalau ada app lain yang mencoba mengarsipkan checklist.
      await h.account.store.patch(EntityType.list, checklistId, {'archived_at': t1});
      await h.account.outbox.enqueueUpdate(EntityType.list, checklistId, {'archived_at': t1}, {'archived_at': null});
      const message = 'Checklist ini ikut perjalanannya. Hapus perjalanannya kalau ingin menghapus checklist.';
      h.api.failNext(apiError(409, ApiErrorCode.tripChecklist, message: message, current: checklistJson()));

      expect(await h.account.outbox.flush(), FlushState.idle);
      await pumpEventQueue();

      expect(await h.ops(), isEmpty);
      expect((await h.local(EntityType.list, checklistId))!['archived_at'], isNull);
      expect((events.single as OutboxRejected).message, message);
    });

    test('tugas yang daftarnya dihapus tidak dipindah ke checklist perjalanan', () async {
      await h.seed();
      await h.seedTrip();
      await h.account.store.write(
        EntityType.list,
        listJson(id: otherListId, name: 'Rumah', position: 1048576),
        serverUpdatedAt: t0,
      );

      final task = await h.account.tasks.create(list: TaskList.fromJson(listJson()), title: 'Beli galon');
      h.api.failNext(apiError(409, ApiErrorCode.parentDeleted, current: null));

      expect(await h.account.outbox.flush(), FlushState.idle);
      expect((await h.local(EntityType.task, task.id))!['task_list_id'], otherListId);
    });

    test('pengingat setor: frekuensi dan harinya selalu dikirim bersama, null mematikannya', () async {
      await h.seed(withGoal: true);

      await h.account.savings.setReminder(goalId, const SavingsReminder(frequency: ReminderFrequency.weekly, day: 5));
      expect(payloadOf((await h.ops()).single), {'reminder_frequency': 'weekly', 'reminder_day': 5});
      final goal = SavingsGoal.fromJson((await h.local(EntityType.goal, goalId))!);
      expect(goal.reminder, const SavingsReminder(frequency: ReminderFrequency.weekly, day: 5));
      await h.account.outbox.flush();

      await h.account.savings.setReminder(goalId, const SavingsReminder(frequency: ReminderFrequency.monthly, day: 5));
      expect(payloadOf((await h.ops()).single), {'reminder_frequency': 'monthly', 'reminder_day': 5});
      await h.account.outbox.flush();

      await h.account.savings.setReminder(goalId, null);
      expect(payloadOf((await h.ops()).single), {'reminder_frequency': null, 'reminder_day': null});
    });

    test('jadwal pengingat yang tidak dikenal atau di luar batas dianggap tidak ada', () {
      expect(SavingsReminder.tryFrom('monthly', 31), isNotNull);
      expect(SavingsReminder.tryFrom('monthly', 32), isNull);
      expect(SavingsReminder.tryFrom('weekly', 8), isNull);
      expect(SavingsReminder.tryFrom('weekly', null), isNull);
      expect(SavingsReminder.tryFrom('daily', 1), isNull);
      expect(SavingsReminder.tryFrom(null, 3), isNull);
    });

    test('sync membawa perjalanan dan checklistnya', () async {
      h.api.syncPages.add(
        h.api.syncPage(spaces: [sharedSpaceJson()], taskLists: [checklistJson()], trips: [tripJson()]),
      );

      expect(await h.account.sync.sync(), isTrue);

      expect((await h.local(EntityType.trip, tripId))!['title'], 'Liburan ke Bali');
      expect((await h.local(EntityType.list, checklistId))!['trip_id'], tripId);
    });

    test('perjalanan yang dihapus pasangan tiba lewat sync bersama checklistnya', () async {
      await h.seed();
      await h.seedTrip();
      h.api.syncPages.add(
        h.api.syncPage(
          trips: [tripJson(deletedAt: t1, updatedAt: t1)],
          taskLists: [checklistJson(deletedAt: t1)..['updated_at'] = t1],
        ),
      );

      await h.account.sync.sync();

      expect((await h.local(EntityType.trip, tripId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.list, checklistId))!['deleted_at'], isNotNull);
    });
  });

  test('database versi 2 dinaikkan ke versi 3: tabel perjalanan dan kolom baru, isi lama tetap ada', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('denly_migrasi3');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/akun.sqlite');

    // Buat database, isi daftar dan target, lalu kembalikan ke bentuk versi 2.
    final old = AppDatabase(NativeDatabase(file));
    await old.into(old.taskLists).insert(taskListCompanion(TaskList.fromJson(listJson())));
    await old.into(old.savingsGoals).insert(savingsGoalCompanion(SavingsGoal.fromJson(goalJson())));
    for (final statement in [
      'DROP TABLE trips',
      'ALTER TABLE task_lists DROP COLUMN trip_id',
      'ALTER TABLE savings_goals DROP COLUMN reminder_frequency',
      'ALTER TABLE savings_goals DROP COLUMN reminder_day',
      'ALTER TABLE tasks DROP COLUMN repeat_frequency',
      'ALTER TABLE tasks DROP COLUMN repeat_interval',
      'ALTER TABLE tasks DROP COLUMN next_task_id',
      'PRAGMA user_version = 2',
    ]) {
      await old.customStatement(statement);
    }
    await old.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect(await upgraded.select(upgraded.trips).get(), isEmpty);
    final list = await upgraded.select(upgraded.taskLists).getSingle();
    expect((list.name, list.tripId), ('Belanja', null));
    final goal = await upgraded.select(upgraded.savingsGoals).getSingle();
    expect((goal.name, goal.reminderFrequency, goal.reminderDay), ('Dana Liburan', null, null));
  });

  // ------------------------------------------------------------------ layar

  group('tab Liburan', () {
    testWidgets('kosong: buat perjalanan pertama, lalu detailnya langsung terbuka', (tester) async {
      final h = Harness();
      await h.seed();
      await pumpApp(tester, h);

      await tester.tap(find.text('Liburan'));
      await settle(tester);
      expect(
        find.text('Belum ada rencana liburan. Buat perjalanan, lalu siapkan checklistnya bersama pasangan.'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Buat perjalanan'));
      await settle(tester);
      expect(find.text('Perjalanan baru'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);
      expect(find.text('Nama perjalanan belum diisi.'), findsOneWidget);
      expect(await h.ops(), isEmpty);

      await tester.enterText(find.byType(TextField).first, 'Liburan ke Bali');
      await tester.enterText(find.byType(TextField).at(1), 'Bali');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Perjalanan baru'), findsNothing);
      expect(find.text('Liburan ke Bali'), findsOneWidget);
      expect(find.text('Tanggal belum pasti'), findsOneWidget);
      expect(find.text('Bali'), findsOneWidget);
      expect(
        find.text('Belum ada persiapan. Catat barang bawaan dan hal yang perlu diurus sebelum berangkat.'),
        findsOneWidget,
      );
      expect([for (final op in await h.ops()) '${op.method} ${op.entityType}'], ['PUT trip', 'PUT list']);

      await disposeApp(tester, h);
    });

    testWidgets('kartu perjalanan: hitung mundur, tanggal, tujuan, dan progres persiapan', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.trips);
      await settle(tester);

      expect(find.text('Liburan ke Bali'), findsOneWidget);
      expect(find.text('255 hari lagi'), findsOneWidget);
      expect(find.text('20–25 Jun 2027 · 6 hari · Bali'), findsOneWidget);
      expect(find.text('1 dari 2 beres'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      await tester.tap(find.text('Liburan ke Bali'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.trip(tripId));
      expect(find.text('20–25 Jun 2027 · 6 hari'), findsOneWidget);
      // Hanya item yang belum beres yang tampil di detail.
      expect(find.text('Beli sunscreen'), findsOneWidget);
      expect(find.text('Perpanjang paspor'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('perjalanan yang sudah selesai dilipat di bawah', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip(startDate: '2026-08-01', endDate: '2026-08-03');
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.trips);
      await settle(tester);

      expect(find.text('Liburan ke Bali'), findsNothing);
      await tester.tap(find.text('Sudah selesai (1)'));
      await settle(tester);
      expect(find.text('Liburan ke Bali'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('checklist: tambah item tanpa menutup keyboard, centang, lalu semuanya beres', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.trip(tripId));
      await settle(tester);

      await tester.tap(find.text('Lihat semua'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.tripChecklist(tripId));
      expect(find.text('1 dari 2 beres'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Tukar uang');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);

      expect(find.text('Tukar uang'), findsOneWidget);
      expect(find.text('1 dari 3 beres'), findsOneWidget);
      expect(tester.testTextInput.isVisible, isTrue, reason: 'keyboard tetap terbuka untuk item berikutnya');
      final created = (await h.ops()).single;
      expect(created.entityType, EntityType.task.name);
      expect(payloadOf(created), containsPair('task_list_id', checklistId));
      expect(payloadOf(created)['assignee_ids'], [meId]);

      await tester.tap(find.bySemanticsLabel('Tandai selesai: Tukar uang'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel('Tandai selesai: Beli sunscreen'));
      await settle(tester);

      expect(find.text('3 dari 3 beres'), findsOneWidget);
      expect(find.text('Persiapan beres semua. Selamat berlibur!'), findsOneWidget);

      await tester.tap(find.text('Selesai (3)'));
      await settle(tester);
      expect(find.text('Perpanjang paspor'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('item checklist dibuka di tab Liburan dan kembali ke checklistnya', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.tripChecklist(tripId));
      await settle(tester);

      await tester.tap(find.text('Beli sunscreen'));
      await settle(tester);
      expect(
        container.read(routerProvider).state.uri.path,
        Routes.tripTask(tripId, sunscreenTaskId, fromChecklist: true),
      );
      expect(find.text('Detail tugas'), findsOneWidget);
      // Item tetap di checklistnya: pilihan daftar tidak bisa diubah.
      expect(find.text('Persiapan Liburan ke Bali'), findsOneWidget);
      expect(find.byIcon(Symbols.chevron_right_rounded), findsNothing);

      await tester.tap(find.byTooltip('Kembali'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.tripChecklist(tripId));

      await disposeApp(tester, h);
    });

    testWidgets('item checklist bertenggat tampil di Tugas hari ini, tapi tidak di tab Tugas dan Kelola daftar', (
      tester,
    ) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip();
      final container = await pumpApp(tester, h);

      expect(find.text('Beli sunscreen'), findsOneWidget);
      // Keterangan barisnya menyebut checklist tempat item itu berada.
      expect(find.textContaining('· Persiapan Liburan ke Bali'), findsOneWidget);

      await tester.tap(find.text('Tugas'));
      await settle(tester);
      expect(find.text('Beli sunscreen'), findsNothing);
      expect(find.text('Persiapan Liburan ke Bali'), findsNothing);
      await tester.tap(find.text('Selesai'));
      await settle(tester);
      expect(find.text('Perpanjang paspor'), findsNothing);

      container.read(routerProvider).go(Routes.manageLists);
      await settle(tester);
      expect(find.text('Belanja'), findsOneWidget);
      expect(find.text('Persiapan Liburan ke Bali'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('dana: tautkan target yang ada, buka detailnya, lalu kembali ke perjalanan', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      await h.seedTrip();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.trip(tripId));
      await settle(tester);

      await tester.scrollUntilVisible(find.text('Pilih target'), 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Pilih target'));
      await settle(tester);
      expect(find.text('Dana perjalanan'), findsOneWidget);
      await tester.tap(find.text('Dana Liburan'));
      await settle(tester);

      expect(payloadOf((await h.ops()).single), {'savings_goal_id': goalId});
      expect(find.text('Rp0 dari Rp10.000.000'), findsOneWidget);

      await tester.tap(find.text('Dana Liburan'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.tripGoal(tripId, goalId));
      expect(find.text('Setor'), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.trip(tripId));

      await disposeApp(tester, h);
    });

    testWidgets('dana: buat target baru di ruang perjalanan, lalu langsung ditautkan', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.trip(tripId));
      await settle(tester);

      expect(find.text('Pilih target'), findsNothing, reason: 'belum ada target di ruang ini');
      await tester.scrollUntilVisible(find.text('Buat target'), 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Buat target'));
      await settle(tester);

      expect(find.text('Target baru'), findsOneWidget);
      expect(find.text('Dana Liburan ke Bali'), findsOneWidget);
      // Ruangnya mengikuti perjalanan, jadi pilihan Bersama atau Pribadi tidak ditampilkan.
      expect(find.text('Simpan di mana?'), findsNothing);
      await tester.enterText(find.byType(TextField).at(2), '5000000');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      final ops = await h.ops();
      expect([for (final op in ops) '${op.method} ${op.entityType}'], ['PUT goal', 'PATCH trip']);
      expect(payloadOf(ops.first), containsPair('space_id', sharedSpaceId));
      expect(payloadOf(ops.last), {'savings_goal_id': ops.first.entityId});
      expect(find.text('Rp0 dari Rp5.000.000'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('ubah dan hapus perjalanan dari menu', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.trip(tripId));
      await settle(tester);

      await tester.tap(find.byTooltip('Opsi lainnya'));
      await settle(tester);
      await tester.tap(find.text('Ubah'));
      await settle(tester);
      expect(find.text('Ubah perjalanan'), findsOneWidget);
      expect(find.text('Min, 20 Jun 2027'), findsOneWidget);
      expect(find.text('Jum, 25 Jun 2027'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Bali dan Lombok');
      await tester.tap(find.text('Kosongkan tanggal'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Bali dan Lombok'), findsOneWidget);
      expect(find.text('Tanggal belum pasti'), findsOneWidget);
      final edits = await h.ops();
      expect(payloadOf(edits.first), {'title': 'Bali dan Lombok', 'start_date': null, 'end_date': null});
      expect(payloadOf(edits.last), {'name': 'Persiapan Bali dan Lombok'});

      await tester.tap(find.byTooltip('Opsi lainnya'));
      await settle(tester);
      await tester.tap(find.text('Hapus'));
      await settle(tester);
      expect(find.text('Hapus Bali dan Lombok?'), findsOneWidget);
      expect(find.text('Checklist persiapannya (2 item) ikut terhapus.'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await settle(tester);

      expect(container.read(routerProvider).state.uri.path, Routes.trips);
      expect(find.text('Bali dan Lombok'), findsNothing);
      expect((await h.ops()).last.method, 'DELETE');

      await disposeApp(tester, h);
    });

    testWidgets('switch pengingat perjalanan sama dengan yang di Pengaturan', (tester) async {
      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.trips);
      await settle(tester);

      await tester.tap(find.text('Ingatkan sebelum berangkat'));
      await settle(tester);

      expect(payloadOf((await h.ops()).single)['notification_prefs'], containsPair('trip_reminders', false));
      expect(find.byType(Switch).evaluate().map((element) => (element.widget as Switch).value), [false]);

      await disposeApp(tester, h);
    });
  });

  group('Beranda', () {
    testWidgets('kartu Persiapan liburan: "1 dari 2" dan membuka perjalanannya', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedTrip();
      final container = await pumpApp(tester, h);

      expect(find.text('1 dari 2'), findsOneWidget);
      expect(find.text('Persiapan Liburan ke Bali'), findsOneWidget);
      expect(find.bySemanticsLabel('Persiapan liburan: 1 dari 2 beres, Liburan ke Bali'), findsOneWidget);

      await tester.ensureVisible(find.text('1 dari 2'));
      await tester.tap(find.text('1 dari 2'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.trip(tripId));

      await disposeApp(tester, h);
    });

    testWidgets('checklist masih kosong: kartu menampilkan hitung mundurnya', (tester) async {
      final h = Harness();
      h.clock.now = DateTime.utc(2027, 6, 19, 3);
      await h.seed();
      await h.account.store.write(EntityType.trip, tripJson(), serverUpdatedAt: t0);
      await pumpApp(tester, h);

      expect(find.text('Besok berangkat'), findsOneWidget);
      expect(find.text('Liburan ke Bali'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('belum ada perjalanan: kartu mengajak merencanakan liburan', (tester) async {
      final h = Harness();
      await h.seed();
      await pumpApp(tester, h);

      await tester.ensureVisible(find.text('Rencanakan liburan'));
      await tester.tap(find.text('Rencanakan liburan'));
      await settle(tester);
      expect(find.text('Perjalanan baru'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('pengingat setor di Detail target', () {
    Future<void> openGoal(WidgetTester tester, Harness h) async {
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.goal(goalId));
      await settle(tester);
    }

    testWidgets('nyalakan: pilih hari Jumat, lalu ubah ke bulanan tanggal 31', (tester) async {
      final h = Harness();
      await h.seed(withGoal: true);
      await openGoal(tester, h);

      expect(find.text('Ingatkan setor'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await settle(tester);
      expect(find.text('Pengingat setor'), findsOneWidget);

      await tester.tap(find.text('Jum'));
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Ingatkan setor tiap Jumat'), findsOneWidget);
      expect(find.text('Pukul 08.00, ke kalian berdua'), findsOneWidget);
      expect(payloadOf((await h.ops()).single), {'reminder_frequency': 'weekly', 'reminder_day': 5});
      await h.account.outbox.flush();

      await tester.tap(find.text('Ingatkan setor tiap Jumat'));
      await settle(tester);
      await tester.tap(find.text('Bulanan'));
      await settle(tester);
      // Bawaannya hari ini, tanggal 8.
      await tester.tap(find.text('Tanggal 8'));
      await settle(tester);
      // Menu tanggal hanya membangun pilihan yang terlihat.
      await tester.scrollUntilVisible(find.text('Tanggal 31'), 200, scrollable: find.byType(Scrollable).last);
      // Tunggu gulirannya berhenti; ketukan pada daftar yang masih bergulir hanya menghentikannya.
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tanggal 31'));
      await settle(tester);
      expect(find.text('Di bulan yang lebih pendek, pengingat dikirim di hari terakhir bulan itu.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Ingatkan setor tiap tanggal 31'), findsOneWidget);
      expect(payloadOf((await h.ops()).single), {'reminder_frequency': 'monthly', 'reminder_day': 31});

      await disposeApp(tester, h);
    });

    testWidgets('matikan lewat switch; target yang sudah tercapai tidak menampilkan pengingat', (tester) async {
      final h = Harness();
      await h.seed();
      final goal = goalJson(reminderFrequency: 'weekly', reminderDay: 1);
      await h.account.store.write(EntityType.goal, goal, serverUpdatedAt: t0);
      h.api.rows['savings-goals'] = {goalId: goal};
      await openGoal(tester, h);

      expect(find.text('Ingatkan setor tiap Senin'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await settle(tester);

      expect(find.text('Ingatkan setor'), findsOneWidget);
      expect(payloadOf((await h.ops()).single), {'reminder_frequency': null, 'reminder_day': null});

      await h.account.store.write(EntityType.entry, entryJson(amount: 10000000), serverUpdatedAt: t0);
      await settle(tester);
      expect(find.text('Ingatkan setor'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('preferensi dimatikan: baris pengingat memberi tahu', (tester) async {
      final h = Harness();
      await h.seed();
      final me = userJson();
      (me['notification_prefs'] as Map<String, dynamic>)['savings_reminders'] = false;
      await h.account.store.write(EntityType.me, me);
      h.api.me = me;
      final goal = goalJson(reminderFrequency: 'monthly', reminderDay: 25);
      await h.account.store.write(EntityType.goal, goal, serverUpdatedAt: t0);
      await openGoal(tester, h);

      expect(find.text('Ingatkan setor tiap tanggal 25'), findsOneWidget);
      expect(find.text('Pengingat setor sedang dimatikan di Pengaturan.'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  testWidgets('Pengaturan: switch Pengingat perjalanan dan Pengingat setor', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h);

    await tester.tap(find.bySemanticsLabel('Buka Pengaturan'));
    await settle(tester);
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(find.text('Pengingat perjalanan'), 200, scrollable: scrollable);
    await tester.tap(find.text('Pengingat perjalanan'));
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Pengingat setor'), 200, scrollable: scrollable);
    await tester.tap(find.text('Pengingat setor'));
    await settle(tester);

    // Kedua perubahan digabung ke satu PATCH /me, dengan notification_prefs utuh.
    expect(payloadOf((await h.ops()).single), {
      'notification_prefs': {
        'task_reminders': true,
        'partner_activity': true,
        'savings_activity': true,
        'special_dates': true,
        'trip_reminders': false,
        'savings_reminders': false,
      },
    });

    await disposeApp(tester, h);
  });

  testWidgets('push pengingat perjalanan dan setor: channel pengingat, lalu ketukannya membuka layarnya', (
    tester,
  ) async {
    final h = Harness();
    await h.seed(withGoal: true);
    await h.seedTrip();
    final push = FakePushService();
    final container = await pumpApp(tester, h, push: push);

    const tripReminder = PushMessage(
      title: 'Perjalanan',
      body: 'Liburan ke Bali 7 hari lagi. Persiapan 1 dari 2 beres.',
      data: {'type': 'trip_reminder', 'space_id': sharedSpaceId, 'trip_id': tripId},
    );
    const savingsReminder = PushMessage(
      title: 'Dana Liburan',
      body: 'Waktunya menabung. Terkumpul 0% dari target.',
      data: {'type': 'savings_reminder', 'space_id': sharedSpaceId, 'savings_goal_id': goalId},
    );

    push.receive(tripReminder);
    await settle(tester);
    push.receive(savingsReminder);
    await settle(tester);

    expect([for (final message in push.shown) message.channel], [PushChannels.reminders, PushChannels.reminders]);
    expect([for (final message in push.shown) message.tag], ['trip-$tripId', 'goal-$goalId']);
    expect(push.shown.last.isAboutSavings, isTrue, reason: 'isinya disembunyikan di layar kunci');

    push.tap(tripReminder);
    await settle(tester);
    expect(container.read(routerProvider).state.uri.path, Routes.trip(tripId));

    push.tap(savingsReminder);
    await settle(tester);
    expect(container.read(routerProvider).state.uri.path, Routes.goal(goalId));

    const missing = PushMessage(
      data: {'type': 'trip_reminder', 'space_id': sharedSpaceId, 'trip_id': '01m4dp5r20vbx9k3ws7ty6hn9z'},
    );
    push.tap(missing);
    await settle(tester);
    expect(container.read(routerProvider).state.uri.path, Routes.trips);
    expect(find.text('Perjalanan itu belum tersedia di HP ini.'), findsOneWidget);

    await disposeApp(tester, h);
  });
}
