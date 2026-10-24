import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/local_store.dart';
import 'package:todolist/core/database/mappers.dart';
import 'package:todolist/core/l10n/l10n.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/sync/sync_engine.dart';
import 'package:todolist/features/tasks/domain/task.dart';
import 'package:todolist/features/tasks/domain/task_list.dart';
import 'package:todolist/features/tasks/presentation/repeat_sheet.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

extension RepeatHarness on Harness {
  /// "Buang sampah" mingguan bertenggat hari ini (8 Okt 2026). Datanya juga ada "di server".
  Future<void> seedWeekly({String? completedAt, String? nextTaskId}) async {
    final task = taskJson(
      title: 'Buang sampah',
      dueDate: '2026-10-08',
      repeatFrequency: 'weekly',
      completedAt: completedAt,
      completedBy: completedAt == null ? null : meId,
      nextTaskId: nextTaskId,
    );
    await account.store.write(EntityType.task, task, serverUpdatedAt: t0);
    api.rows.putIfAbsent('tasks', () => {})[taskId] = task;
  }

  Future<Task?> task(String id) async {
    final row = await local(EntityType.task, id);
    return row == null ? null : Task.fromJson(row);
  }

  List<String> opNames(List<OutboxRow> ops) => [for (final op in ops) '${op.method} ${op.entityType}'];

  /// Tugas yang belum dihapus di HP ini.
  Future<List<Task>> liveTasks() async => [
    for (final task in await account.store.tasks())
      if (task.deletedAt == null) task,
  ];
}

void main() {
  setUpAll(prepareAppTests);

  Map<String, dynamic> payloadOf(OutboxRow op) => jsonDecode(op.payload!) as Map<String, dynamic>;

  test('aturan ulang yang tidak dikenal atau di luar batas dianggap tidak ada; selang bawaannya 1', () {
    expect(TaskRepeat.tryFrom('weekly', 2), const TaskRepeat(RepeatFrequency.weekly, 2));
    expect(TaskRepeat.tryFrom('monthly', null), const TaskRepeat(RepeatFrequency.monthly));
    expect(TaskRepeat.tryFrom('hourly', 1), isNull);
    expect(TaskRepeat.tryFrom(null, 1), isNull);
    expect(TaskRepeat.tryFrom('daily', 0), isNull);
    expect(TaskRepeat.tryFrom('daily', 100), isNull);
    expect(TaskRepeat.tryFrom('daily', 99)!.interval, 99);
  });

  // ------------------------------------------------------------------ repository dan antrean

  group('repository', () {
    late Harness h;

    setUp(() async {
      h = Harness();
      await h.seed();
    });
    tearDown(() => h.dispose());

    TaskList list() => TaskList.fromJson(listJson());

    test('buat tugas berulang: aturan ulang ikut PUT; tugas biasa mengirim null', () async {
      final weekly = await h.account.tasks.create(
        list: list(),
        title: 'Buang sampah',
        dueDate: '2026-10-08',
        repeat: const TaskRepeat(RepeatFrequency.weekly, 2),
      );
      await h.account.tasks.create(list: list(), title: 'Beli galon');

      final ops = await h.ops();
      expect((payloadOf(ops[0])['repeat_frequency'], payloadOf(ops[0])['repeat_interval']), ('weekly', 2));
      expect((payloadOf(ops[1])['repeat_frequency'], payloadOf(ops[1])['repeat_interval']), (null, null));
      expect(weekly.repeat, const TaskRepeat(RepeatFrequency.weekly, 2));
      expect((await h.task(weekly.id))!.repeat, const TaskRepeat(RepeatFrequency.weekly, 2));
    });

    test('aturan sama dengan server: butuh tanggal, tidak di checklist, selang 1–99', () async {
      await expectLater(
        h.account.tasks.create(list: list(), title: 'Buang sampah', repeat: const TaskRepeat(RepeatFrequency.daily)),
        throwsArgumentError,
      );
      await expectLater(
        h.account.tasks.create(
          list: TaskList.fromJson(checklistJson()),
          title: 'Beli sunscreen',
          dueDate: '2026-10-08',
          repeat: const TaskRepeat(RepeatFrequency.daily),
        ),
        throwsArgumentError,
      );
      await expectLater(
        h.account.tasks.create(
          list: list(),
          title: 'Buang sampah',
          dueDate: '2026-10-08',
          repeat: const TaskRepeat(RepeatFrequency.daily, 100),
        ),
        throwsArgumentError,
      );
      expect(await h.ops(), isEmpty);

      // Tugas tanpa tenggat tidak bisa diberi aturan ulang.
      await h.account.store.write(EntityType.task, taskJson(), serverUpdatedAt: t0);
      await expectLater(
        h.account.tasks.setRepeat(taskId, const TaskRepeat(RepeatFrequency.daily)),
        throwsArgumentError,
      );
      expect(await h.ops(), isEmpty);
    });

    test('ubah aturan: frekuensi dan selang selalu dikirim berdua; null menghentikannya', () async {
      await h.seedWeekly();

      await h.account.tasks.setRepeat(taskId, const TaskRepeat(RepeatFrequency.weekly, 2));
      await h.account.outbox.flush();
      await h.account.tasks.setRepeat(taskId, null);

      expect(
        [for (final request in h.api.sent('PATCH')) request.body],
        [
          {'repeat_frequency': 'weekly', 'repeat_interval': 2},
        ],
      );
      expect(payloadOf((await h.ops()).single), {'repeat_frequency': null, 'repeat_interval': null});
      expect((await h.task(taskId))!.repeat, isNull);
    });

    test('hapus tenggat ikut mengosongkan aturan ulang, di HP dan di kiriman', () async {
      await h.seedWeekly();

      await h.account.tasks.setDue(taskId, date: null, time: null);

      expect(payloadOf((await h.ops()).single), {
        'due_date': null,
        'due_time': null,
        'repeat_frequency': null,
        'repeat_interval': null,
      });
      expect((await h.task(taskId))!.repeat, isNull);
    });

    test('centang tugas berulang: tugas berikutnya dari balasan PATCH langsung masuk cache', () async {
      await h.seedWeekly();

      await h.account.tasks.complete(taskId);
      h.clock.advance(Outbox.undoWindow);
      expect(await h.account.outbox.flush(), FlushState.idle);

      final done = (await h.task(taskId))!;
      final nextId = done.nextTaskId!;
      final next = (await h.task(nextId))!;
      expect(done.isCompleted, isTrue);
      expect((next.title, next.dueDate, next.isCompleted), ('Buang sampah', '2026-10-15', false));
      expect(next.repeat, const TaskRepeat(RepeatFrequency.weekly));
      expect(h.api.log, ['PATCH /tasks/$taskId'], reason: 'tanpa menunggu sync');
    });

    test('Urungkan setelah terkirim: server menghapus tugas berikutnya, dan HP ikut menghapusnya', () async {
      await h.seedWeekly();
      await h.account.tasks.complete(taskId);
      h.clock.advance(Outbox.undoWindow);
      await h.account.outbox.flush();
      final nextId = (await h.task(taskId))!.nextTaskId!;

      await h.account.tasks.uncomplete(taskId);
      expect(await h.account.outbox.flush(), FlushState.idle);

      expect(h.api.sent('PATCH').last.body, {'completed_at': null});
      expect((await h.task(taskId))!.nextTaskId, isNull);
      expect(await h.task(nextId), isNull);
      expect([for (final task in await h.liveTasks()) task.id], [taskId]);
    });

    test('tugas berikutnya yang sudah diubah di server tetap ada setelah Urungkan', () async {
      await h.seedWeekly();
      await h.account.tasks.complete(taskId);
      h.clock.advance(Outbox.undoWindow);
      await h.account.outbox.flush();
      final nextId = (await h.task(taskId))!.nextTaskId!;

      // Perubahannya sampai di server lebih dulu, jadi tugas berikutnya sudah disentuh.
      await h.account.tasks.rename(nextId, 'Buang sampah organik');
      await h.account.tasks.uncomplete(taskId);
      await h.account.outbox.flush();

      expect((await h.task(taskId))!.nextTaskId, nextId);
      expect((await h.task(nextId))!.title, 'Buang sampah organik');
    });

    test('tugas berikutnya yang masih punya perubahan di antrean tidak dihapus oleh balasan centang batal', () async {
      const nextId = '01m4dh1yn0t6cdn39q4f0918nx';
      await h.seedWeekly(completedAt: t1, nextTaskId: nextId);
      final next = taskJson(id: nextId, title: 'Buang sampah', dueDate: '2026-10-15', repeatFrequency: 'weekly');
      await h.account.store.write(EntityType.task, next, serverUpdatedAt: t0);

      // Centang batal dulu, lalu tugas berikutnya ditandai penting sebelum keduanya terkirim.
      await h.account.tasks.uncomplete(taskId);
      await h.account.tasks.setImportant(nextId, true);
      expect(h.opNames(await h.ops()), ['PATCH task', 'PATCH task']);

      // Balasan centang batal mengosongkan next_task_id; perubahan tugas berikutnya belum terkirim.
      h.api
        ..enqueue(
          (_) => ApiResponse(
            status: 200,
            body: {
              'data': taskJson(title: 'Buang sampah', dueDate: '2026-10-08', repeatFrequency: 'weekly', updatedAt: t2),
              'next_task': null,
            },
          ),
        )
        ..failNext(const NetworkFailure());
      expect(await h.account.outbox.flush(), FlushState.waitingRetry);

      expect((await h.task(taskId))!.nextTaskId, isNull);
      expect(await h.task(nextId), isNotNull, reason: 'nasibnya ditentukan balasan untuk perubahannya sendiri');
    });

    test('balasan PUT 200 juga membawa tugas berikutnya', () async {
      await h.seedWeekly();
      final next = taskJson(id: '01m4dh1yn0t6cdn39q4f0918nx', title: 'Buang sampah', dueDate: '2026-10-15');
      h.api.enqueue(
        (_) => ApiResponse(
          status: 200,
          body: {
            'data': taskJson(
              id: '01m4dh1yn0t6cdn39q4f0918mx',
              title: 'Cuci mobil',
              dueDate: '2026-10-08',
              repeatFrequency: 'weekly',
              completedAt: t1,
              nextTaskId: next['id'] as String,
              updatedAt: t2,
            ),
            'next_task': next,
          },
        ),
      );

      await h.account.tasks.create(list: list(), title: 'Cuci mobil');
      await h.account.outbox.flush();

      expect((await h.task(next['id'] as String))!.dueDate, '2026-10-15');
    });

    test('selama centang belum terkirim, sync tidak menimpa next_task_id', () async {
      await h.seedWeekly();
      await h.account.tasks.complete(taskId);
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
      await h.account.store.setMeta(MetaKeys.syncCollections, '${SyncEngine.collectionsVersion}');
      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [
            taskJson(title: 'Buang sampah', dueDate: '2026-10-08', repeatFrequency: 'weekly', updatedAt: t1)
              ..['next_task_id'] = 'dari-pasangan',
          ],
        ),
      );

      await h.account.sync.sync();

      final task = (await h.task(taskId))!;
      expect((task.isCompleted, task.nextTaskId), (true, null));
    });
  });

  // ------------------------------------------------------------------ sync dan database

  test('sync penuh sekali setelah app mengenal aturan ulang (v1.0)', () async {
    final h = Harness();
    addTearDown(h.dispose);
    await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
    await h.account.store.setMeta(MetaKeys.syncCollections, '4');
    h.api.syncPages.add(
      h.api.syncPage(
        serverTime: 'T-1',
        tasks: [taskJson(dueDate: '2026-10-08', repeatFrequency: 'monthly', repeatInterval: 3)],
      ),
    );

    expect(SyncEngine.collectionsVersion, 5);
    await h.account.sync.sync();

    expect(
      [
        for (final request in h.api.requests)
          if (request.path == '/sync') request.query,
      ],
      [null],
    );
    expect((await h.task(taskId))!.repeat, const TaskRepeat(RepeatFrequency.monthly, 3));
    expect(await h.account.store.meta(MetaKeys.syncCollections), '5');
  });

  test('database versi 4 dinaikkan ke versi 5: kolom aturan ulang di tugas, isi lama tetap ada', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('denly_migrasi5');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/akun.sqlite');

    final old = AppDatabase(NativeDatabase(file));
    await old.into(old.taskLists).insert(taskListCompanion(TaskList.fromJson(listJson())));
    for (final statement in [
      'ALTER TABLE tasks DROP COLUMN repeat_frequency',
      'ALTER TABLE tasks DROP COLUMN repeat_interval',
      'ALTER TABLE tasks DROP COLUMN next_task_id',
      'PRAGMA user_version = 4',
    ]) {
      await old.customStatement(statement);
    }
    await old.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect((await upgraded.select(upgraded.taskLists).getSingle()).name, 'Belanja');
    final task = Task.fromJson(
      taskJson(dueDate: '2026-10-08', repeatFrequency: 'yearly', repeatInterval: 2, nextTaskId: 'berikutnya'),
    );
    await upgraded.into(upgraded.tasks).insert(taskCompanion(task));
    final row = (await upgraded.select(upgraded.tasks).getSingle()).toModel();
    expect((row.repeat, row.nextTaskId), (const TaskRepeat(RepeatFrequency.yearly, 2), 'berikutnya'));
  });

  // ------------------------------------------------------------------ layar

  group('layar', () {
    testWidgets('Tugas baru: pilih Ulangi tiap 2 minggu; tanpa tanggal, pilihan ulang hilang', (tester) async {
      final h = Harness();
      await h.seed();
      await pumpApp(tester, h);

      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);
      // Dibuka dari Beranda: tanggalnya sudah "Hari ini", jadi Ulangi bisa dipilih.
      await tester.enterText(find.byType(TextField), 'Buang sampah');
      await tester.tap(find.text('Ulangi'));
      await settle(tester);
      expect(find.text('Ulangi tugas'), findsOneWidget);

      await tester.tap(find.text('Mingguan'));
      await settle(tester);
      expect(find.text('Tiap minggu'), findsOneWidget);
      await tester.tap(find.byTooltip('Tambah'));
      await settle(tester);
      expect(find.text('Tiap 2 minggu'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan').last);
      await settle(tester);

      expect(find.text('Ulangi tugas'), findsNothing);
      expect(find.widgetWithText(InkWell, 'Tiap 2 minggu'), findsOneWidget);

      // Tanggal dikosongkan: jam dan aturan ulang ikut hilang.
      await tester.tap(find.text('Hari ini').last);
      await settle(tester);
      expect(find.text('Tiap 2 minggu'), findsNothing);
      await tester.tap(find.text('Besok'));
      await settle(tester);
      expect(find.text('Ulangi'), findsOneWidget);

      await tester.tap(find.text('Ulangi'));
      await settle(tester);
      await tester.tap(find.text('Bulanan'));
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan').last);
      await settle(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      final op = (await h.ops()).single;
      expect(
        (payloadOf(op)['due_date'], payloadOf(op)['repeat_frequency'], payloadOf(op)['repeat_interval']),
        ('2026-10-09', 'monthly', 1),
      );

      await disposeApp(tester, h);
    });

    testWidgets('baris tugas menandai aturan ulangnya; centang mengirim, lalu tugas berikutnya muncul', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = Harness();
      await h.seed();
      await h.seedWeekly();
      await pumpApp(tester, h);

      await tester.tap(find.text('Tugas'));
      await settle(tester);
      expect(find.textContaining('Tiap minggu'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Tandai selesai: Buang sampah'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Tugas selesai. Yang berikutnya muncul setelah tersimpan di server.'), findsOneWidget);

      await tester.pump(Outbox.undoWindow);
      await tester.pumpAndSettle();
      h.clock.advance(Outbox.undoWindow);
      await h.account.outbox.flush();
      await settle(tester);

      // Tugas berikutnya tampil sebagai tugas baru yang belum selesai, bertenggat minggu depan.
      expect(find.bySemanticsLabel('Tandai selesai: Buang sampah'), findsOneWidget);
      expect(find.textContaining('Kam, 15 Okt'), findsOneWidget);

      semantics.dispose();
      await disposeApp(tester, h);
    });

    testWidgets('Detail tugas: atur ulang bulanan di tanggal 31, lalu hentikan', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.task, taskJson(dueDate: '2026-10-31'), serverUpdatedAt: t0);
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.task(taskId));
      await settle(tester);
      await tester.tap(find.text('Ulangi'));
      await settle(tester);
      await tester.tap(find.text('Bulanan'));
      await settle(tester);
      expect(find.text('Di bulan yang lebih pendek, tenggatnya jatuh di hari terakhir bulan itu.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Tiap bulan'), findsOneWidget);
      expect(payloadOf((await h.ops()).single), {'repeat_frequency': 'monthly', 'repeat_interval': 1});

      await tester.tap(find.text('Tiap bulan'));
      await settle(tester);
      await tester.tap(find.text('Tidak diulang'));
      await settle(tester);
      expect(find.text('Setiap berapa?'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Ulangi'), findsOneWidget);
      expect((await h.task(taskId))!.repeat, isNull);

      await disposeApp(tester, h);
    });

    testWidgets('Detail tugas berulang yang selesai: aturannya dan tautan ke tugas berikutnya', (tester) async {
      final h = Harness();
      await h.seed();
      const nextId = '01m4dh1yn0t6cdn39q4f0918nx';
      await h.seedWeekly(completedAt: t1, nextTaskId: nextId);
      await h.account.store.write(
        EntityType.task,
        taskJson(id: nextId, title: 'Buang sampah', dueDate: '2026-10-15', repeatFrequency: 'weekly'),
        serverUpdatedAt: t1,
      );
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.task(taskId));
      await settle(tester);
      expect(find.text('Tiap minggu'), findsOneWidget);
      expect(find.text('Ulangi'), findsNothing, reason: 'aturan tugas yang selesai tidak membuat apa-apa lagi');

      await tester.tap(find.text('Tugas berikutnya: Kam, 15 Okt'));
      await settle(tester);
      expect(container.read(routerProvider).state.uri.path, Routes.task(nextId));
      expect(find.text('Tiap minggu'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('item checklist perjalanan tidak punya pilihan Ulangi', (tester) async {
      final h = Harness();
      await h.seed();
      await h.account.store.write(EntityType.trip, tripJson(), serverUpdatedAt: t0);
      await h.account.store.write(EntityType.list, checklistJson(), serverUpdatedAt: t0);
      await h.account.store.write(
        EntityType.task,
        taskJson(taskListId: checklistId, title: 'Beli sunscreen', dueDate: '2026-10-08'),
        serverUpdatedAt: t0,
      );
      final container = await pumpApp(tester, h);

      container.read(routerProvider).go(Routes.tripTask(tripId, taskId));
      await settle(tester);
      expect(find.text('Beli sunscreen'), findsWidgets);
      expect(find.text('Ulangi'), findsNothing);

      await disposeApp(tester, h);
    });
  });

  test('teks aturan ulang', () {
    final l10n = lookupAppLocalizations(const Locale('id'));
    expect(repeatText(l10n, const TaskRepeat(RepeatFrequency.daily)), 'Tiap hari');
    expect(repeatText(l10n, const TaskRepeat(RepeatFrequency.weekly, 2)), 'Tiap 2 minggu');
    expect(repeatText(l10n, const TaskRepeat(RepeatFrequency.monthly, 3)), 'Tiap 3 bulan');
    expect(repeatText(l10n, const TaskRepeat(RepeatFrequency.yearly)), 'Tiap tahun');
  });
}
