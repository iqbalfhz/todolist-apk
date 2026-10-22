import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/router/app_router.dart';
import 'package:todolist/core/router/routes.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/features/auth/domain/user.dart';
import 'package:todolist/features/spaces/domain/household.dart';
import 'package:todolist/features/spaces/domain/space.dart';
import 'package:todolist/features/special_dates/domain/special_date.dart';
import 'package:todolist/features/special_dates/domain/upcoming_dates.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_push.dart';
import 'helpers/fixtures.dart';

const String privateDateId = '01m4dm2k70z5bq7rn3xw8c4v2a';

/// Ruang Bersama yang anggotanya membawa tanggal lahir (v0.2).
Map<String, dynamic> sharedSpaceWithBirthdays({String? partnerBirthDate = '1999-11-17'}) =>
    sharedSpaceJson(myBirthDate: '--03-02', partnerBirthDate: partnerBirthDate);

/// Hari jadi 20 Okt 2023 di Ruang Bersama dan ulang tahun Ibu di Ruang Pribadi.
Map<String, dynamic> anniversaryJson() => specialDateJson(date: '2023-10-20');

Map<String, dynamic> motherBirthdayJson() => specialDateJson(
  id: privateDateId,
  spaceId: personalSpaceId,
  type: 'birthday',
  title: 'Ulang tahun Ibu',
  date: '--12-01',
);

extension DatesHarness on Harness {
  /// Profil tanpa tanggal lahir, di HP dan di server (app mengambil ulang profil saat dibuka).
  Future<void> clearBirthDate() async {
    final me = {...userJson(), 'birth_date': null};
    await account.store.write(EntityType.me, me);
    api.me = me;
  }

  /// Seperti contoh di mockup: hari jadi, ulang tahun Sari dari profilnya, ulang tahun Ibu
  /// (pribadi), dan ulang tahunku sendiri. Datanya juga ada "di server".
  Future<void> seedDates() async {
    final store = account.store;
    await store.write(EntityType.space, sharedSpaceWithBirthdays(), serverUpdatedAt: t0);
    for (final row in [anniversaryJson(), motherBirthdayJson()]) {
      await store.write(EntityType.specialDate, row, serverUpdatedAt: t0);
      api.rows.putIfAbsent('special-dates', () => {})[row['id'] as String] = row;
    }
  }
}

void main() {
  setUpAll(prepareAppTests);

  Map<String, dynamic> payloadOf(OutboxRow op) => jsonDecode(op.payload!) as Map<String, dynamic>;

  // ------------------------------------------------------------------ hitung mundur

  group('daftar Akan datang', () {
    /// 8 Okt 2026 pukul 17.00 WIB, sama dengan jam di mockup.
    final october8 = DateTime.utc(2026, 10, 8, 10);

    Household household({List<Map<String, dynamic>>? spaces}) => Household(
      me: User.fromJson(userJson()),
      spaces: [
        for (final space in spaces ?? [sharedSpaceWithBirthdays(), personalSpaceJson()]) Space.fromJson(space),
      ],
    );

    UpcomingDates build(Household household, List<Map<String, dynamic>> rows, DateTime now) => buildUpcomingDates(
      household: household,
      dates: [for (final row in rows) SpecialDate.fromJson(row)],
      clock: SpaceClock(now: () => now),
      now: now,
    );

    test('urut dari yang paling dekat, dengan angka "ke-N" hanya kalau tahunnya diisi', () {
      final upcoming = build(household(), [anniversaryJson(), motherBirthdayJson()], october8);

      expect(
        [for (final item in upcoming.items) item.key],
        ['date-$specialDateId', 'birthday-$partnerId', 'date-$privateDateId', 'birthday-$meId'],
      );
      // Sama dengan angka di mockup Tanggal penting.
      expect([for (final item in upcoming.items) item.daysLeft], [12, 40, 54, 145]);
      expect([for (final item in upcoming.items) item.ordinal], [3, 27, null, null]);
      expect([for (final item in upcoming.items) item.next], ['2026-10-20', '2026-11-17', '2026-12-01', '2027-03-02']);
      expect([for (final item in upcoming.items) item.isPrivate], [false, false, true, false]);
      expect(upcoming.items.last.isMine, isTrue);
      expect(upcoming.nearest!.key, 'date-$specialDateId');
    });

    test('Bersama sejak: jumlah hari dari hari jadi sampai hari ini', () {
      final together = build(household(), [anniversaryJson()], october8).together!;

      expect(together.since, '2023-10-20');
      expect(together.days, 1084);
      expect(together.anniversary.daysLeft, 12);
    });

    test('hari H dihitung di zona waktu ruang, bukan jam UTC', () {
      // 19 Okt pukul 18.30 UTC sudah 20 Okt pukul 01.30 di Jakarta.
      final item = build(household(), [anniversaryJson()], DateTime.utc(2026, 10, 19, 18, 30)).nearest!;

      expect(item.isToday, isTrue);
      expect(item.ordinal, 3);
    });

    test('29 Februari jatuh pada 28 Februari di tahun biasa, sama seperti pengingat di server', () {
      final leapDay = specialDateJson(type: 'other', title: 'Hari kabisat', date: '--02-29');

      UpcomingDate leapDayOn(DateTime now) =>
          build(household(), [leapDay], now).items.singleWhere((item) => item.specialDate != null);

      final in2026 = leapDayOn(DateTime.utc(2026, 2, 1, 3));
      expect(in2026.next, '2026-02-28');
      expect(in2026.daysLeft, 27);

      expect(leapDayOn(DateTime.utc(2027, 3, 1, 3)).next, '2028-02-29');
    });

    test('tanggal terhapus, ruang yang tidak dikenal, dan tanggal lahir kosong tidak tampil', () {
      final upcoming = build(
        household(spaces: [sharedSpaceWithBirthdays(partnerBirthDate: null), personalSpaceJson()]),
        [specialDateJson(deletedAt: t1), specialDateJson(id: privateDateId, spaceId: '01m4dzzzzzzzzzzzzzzzzzzzzz')],
        october8,
      );

      expect([for (final item in upcoming.items) item.key], ['birthday-$meId']);
      expect(upcoming.together, isNull);
    });

    test('belum berpasangan: ulang tahun sendiri tetap dihitung mundur', () {
      final upcoming = build(household(spaces: [personalSpaceJson()]), const [], october8);

      expect(upcoming.items.single.isMine, isTrue);
      expect(upcoming.items.single.daysLeft, 145);
    });

    test('Bersama sejak mendahulukan Ruang Bersama, lalu yang tertua; tanpa tahun atau belum lewat diabaikan', () {
      final upcoming = build(household(), [
        specialDateJson(id: '01m4dm2k70z5bq7rn3xw8c4v3a', spaceId: personalSpaceId, date: '2015-01-01'),
        specialDateJson(id: '01m4dm2k70z5bq7rn3xw8c4v3b', date: '2023-10-20'),
        specialDateJson(id: '01m4dm2k70z5bq7rn3xw8c4v3c', date: '2019-05-05'),
        specialDateJson(id: '01m4dm2k70z5bq7rn3xw8c4v3d', date: '--01-01'),
        specialDateJson(id: '01m4dm2k70z5bq7rn3xw8c4v3e', date: '2030-01-01'),
      ], october8);

      expect(upcoming.together!.since, '2019-05-05');
    });
  });

  // ------------------------------------------------------------------ repository dan antrean

  group('menyimpan tanggal', () {
    late Harness h;

    setUp(() async {
      h = Harness();
      await h.seed();
    });

    tearDown(() => h.dispose());

    test('dibuat di HP dulu, lalu PUT /special-dates/{id} berisi kolom kontrak', () async {
      final created = await h.account.dates.create(
        spaceId: sharedSpaceId,
        type: SpecialDateType.anniversary,
        title: '  Hari jadi kita ',
        date: '2023-10-29',
      );

      final local = (await h.local(EntityType.specialDate, created.id))!;
      expect(local['title'], 'Hari jadi kita');
      expect(local['created_by'], meId);

      final op = (await h.ops()).single;
      expect(op.method, 'PUT');
      expect(payloadOf(op), {
        'space_id': sharedSpaceId,
        'type': 'anniversary',
        'title': 'Hari jadi kita',
        'date': '2023-10-29',
      });

      await h.account.outbox.flush();
      expect(h.api.log, ['PUT /special-dates/${created.id}']);
      expect(h.api.row('special-dates', created.id)!['date'], '2023-10-29');
    });

    test('ubah hanya mengirim kolom yang berubah; hapus mengirim DELETE', () async {
      await h.seedDates();

      await h.account.dates.edit(
        specialDateId,
        type: SpecialDateType.anniversary,
        title: 'Hari jadi',
        date: '2023-10-20',
      );
      await h.account.dates.delete(specialDateId);

      final ops = await h.ops();
      expect([for (final op in ops) op.method], ['PATCH', 'DELETE']);
      expect(payloadOf(ops.first), {'title': 'Hari jadi'});
      expect(await h.account.store.watchSpecialDates().first, hasLength(1));

      await h.account.outbox.flush();
      expect(h.api.log, ['PATCH /special-dates/$specialDateId', 'DELETE /special-dates/$specialDateId']);
    });

    test('nama dan tanggal dicek dengan aturan yang sama seperti server', () async {
      Future<void> create(String title, String date) =>
          h.account.dates.create(spaceId: sharedSpaceId, type: SpecialDateType.other, title: title, date: date);

      await expectLater(create('   ', '2023-10-29'), throwsArgumentError);
      await expectLater(create('a' * 51, '2023-10-29'), throwsArgumentError);
      await expectLater(create('Hari jadi', '--02-30'), throwsArgumentError);
      await expectLater(create('Hari jadi', '29-10-2023'), throwsArgumentError);
      expect(await h.ops(), isEmpty);

      await create('a' * 50, '--02-29');
      expect(await h.ops(), hasLength(1));
    });
  });

  test('database v0.1 dinaikkan ke versi 2: tabel tanggal penting dibuat, isi lama tetap ada', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('denly_migrasi');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/akun.sqlite');

    // Buat database, lalu kembalikan ke bentuk v0.1: tanpa tabel tanggal penting.
    final old = AppDatabase(NativeDatabase(file));
    await old.into(old.metaEntries).insert(MetaEntriesCompanion.insert(key: 'sync_since', value: 'T-lama'));
    await old.customStatement('DROP TABLE special_dates');
    await old.customStatement('PRAGMA user_version = 1');
    await old.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect(await upgraded.select(upgraded.specialDates).get(), isEmpty);
    expect((await upgraded.select(upgraded.metaEntries).getSingle()).value, 'T-lama');
  });

  // ------------------------------------------------------------------ layar

  group('layar Tanggal penting', () {
    testWidgets('dari Pengaturan: Bersama sejak, lalu daftar Akan datang dari sync dan profil', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedDates();
      await pumpApp(tester, h);

      await tester.tap(find.bySemanticsLabel('Buka Pengaturan'));
      await settle(tester);
      // Baris di bagian akun; switch dengan judul yang sama ada di bagian Notifikasi.
      await tester.tap(find.text('Tanggal penting').first);
      await settle(tester);

      expect(find.text('Bersama sejak 20 Okt 2023'), findsOneWidget);
      expect(find.text('1.084 hari'), findsOneWidget);
      expect(find.text('Hari jadi kita ke-3 tinggal 12 hari lagi'), findsOneWidget);

      final titles = ['Hari jadi kita ke-3', 'Ulang tahun Sari ke-27', 'Ulang tahun Ibu', 'Ulang tahunmu'];
      for (final title in titles) {
        expect(find.text(title), findsOneWidget);
      }
      final tops = [for (final title in titles) tester.getTopLeft(find.text(title)).dy];
      expect(tops, [...tops]..sort());

      expect(find.text('12 hari'), findsOneWidget);
      expect(find.text('40 hari'), findsOneWidget);
      expect(find.text('54 hari'), findsOneWidget);
      expect(find.text('145 hari'), findsOneWidget);
      expect(find.textContaining('Pribadi, untuk kejutan'), findsOneWidget);
      expect(find.textContaining('Sel, 20 Okt'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('tambah tanggal pribadi: nama dan tanggal wajib, lalu tampil sebelum server membalas', (tester) async {
      final h = Harness();
      await h.seed();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.specialDates);
      await settle(tester);

      await tester.tap(find.text('Tambah tanggal'));
      await settle(tester);
      expect(find.text('Tanggal baru'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);
      expect(find.text('Nama tanggal belum diisi.'), findsOneWidget);
      expect(find.text('Pilih tanggalnya dulu.'), findsOneWidget);
      expect(await h.ops(), isEmpty);

      await tester.tap(find.text('Ulang tahun'));
      await tester.enterText(find.byType(TextField), 'Ulang tahun Ibu');
      await tester.tap(find.text('Pilih tanggal'));
      await settle(tester);
      // Tanggal 1 Januari (bawaan dialog) dengan tahun 1960.
      await tester.enterText(find.byType(TextField).last, '1960');
      await tester.tap(find.widgetWithText(TextButton, 'Simpan'));
      await settle(tester);
      expect(find.text('1 Januari 1960'), findsOneWidget);

      await tester.tap(find.text('Pribadi'));
      await settle(tester);
      expect(find.text('Pasanganmu tidak akan melihat tanggal ini.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Tanggal baru'), findsNothing);
      expect(find.text('Ulang tahun Ibu ke-67'), findsOneWidget);
      expect(find.text('85 hari'), findsOneWidget);

      final op = (await h.ops()).single;
      expect(op.method, 'PUT');
      expect(op.entityType, EntityType.specialDate.name);
      expect(payloadOf(op), {
        'space_id': personalSpaceId,
        'type': 'birthday',
        'title': 'Ulang tahun Ibu',
        'date': '1960-01-01',
      });

      await disposeApp(tester, h);
    });

    testWidgets('ketuk tanggal untuk mengubahnya, lalu hapus dengan konfirmasi', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedDates();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.specialDates);
      await settle(tester);

      await tester.tap(find.text('Hari jadi kita ke-3'));
      await settle(tester);
      expect(find.text('Ubah tanggal'), findsOneWidget);
      expect(find.text('20 Oktober 2023'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hari jadi');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
      await settle(tester);

      expect(find.text('Hari jadi ke-3'), findsOneWidget);
      expect(payloadOf((await h.ops()).single), {'title': 'Hari jadi'});

      await tester.tap(find.text('Hari jadi ke-3'));
      await settle(tester);
      await tester.tap(find.text('Hapus tanggal'));
      await settle(tester);
      expect(find.text('Hapus Hari jadi?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await settle(tester);

      expect(find.text('Ubah tanggal'), findsNothing);
      expect(find.text('Hari jadi ke-3'), findsNothing);
      expect([for (final op in await h.ops()) op.method], ['PATCH', 'DELETE']);

      await disposeApp(tester, h);
    });

    testWidgets('tanggal lahir belum diisi: ada ajakan mengisinya di Profil', (tester) async {
      final h = Harness();
      await h.seed();
      await h.clearBirthDate();
      final container = await pumpApp(tester, h);
      container.read(routerProvider).go(Routes.specialDates);
      await settle(tester);

      expect(
        find.text(
          'Belum ada tanggal penting. Simpan hari jadi atau ulang tahun orang tersayang, nanti kalian diingatkan.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Tanggal lahirmu belum diisi'));
      await settle(tester);
      expect(find.text('Profil'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  group('Beranda', () {
    testWidgets('kartu Tanggal penting menghitung mundur yang terdekat dan membuka layarnya', (tester) async {
      final h = Harness();
      await h.seed();
      await h.seedDates();
      await pumpApp(tester, h);

      expect(find.text('12 hari lagi'), findsOneWidget);
      expect(find.text('Hari jadi kita ke-3 · Sel, 20 Okt'), findsOneWidget);

      await tester.ensureVisible(find.text('12 hari lagi'));
      await tester.tap(find.text('12 hari lagi'));
      await settle(tester);
      expect(find.text('1.084 hari'), findsOneWidget);

      // Kembali langsung ke Beranda, bukan ke Pengaturan.
      await tester.tap(find.byTooltip('Kembali'));
      await settle(tester);
      expect(find.text('Tugas hari ini'), findsOneWidget);
      expect(find.text('Pengaturan'), findsNothing);

      await disposeApp(tester, h);
    });

    testWidgets('hari H: kartu ucapan "Hari jadi kita ke-3. Selamat!"', (tester) async {
      final h = Harness();
      h.clock.now = DateTime.utc(2026, 10, 20, 1);
      await h.seed();
      await h.seedDates();
      await pumpApp(tester, h);

      expect(find.text('Hari jadi kita ke-3. Selamat!'), findsOneWidget);
      expect(find.text('Hari ini · Sel, 20 Okt'), findsOneWidget);

      await disposeApp(tester, h);
    });

    testWidgets('belum ada tanggal: kartu kosong mengajak menambah tanggal', (tester) async {
      final h = Harness();
      await h.seed();
      await h.clearBirthDate();
      await pumpApp(tester, h);

      await tester.ensureVisible(find.text('Tambah tanggal'));
      await tester.tap(find.text('Tambah tanggal'));
      await settle(tester);
      expect(find.text('Tanggal baru'), findsOneWidget);

      await disposeApp(tester, h);
    });
  });

  testWidgets('Pengaturan: switch Tanggal penting mengirim notification_prefs utuh', (tester) async {
    final h = Harness();
    await h.seed();
    await pumpApp(tester, h);

    await tester.tap(find.bySemanticsLabel('Buka Pengaturan'));
    await settle(tester);
    final subtitle = find.text('H-7, H-1, dan hari H pukul 08.00');
    await tester.scrollUntilVisible(subtitle, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(subtitle);
    await settle(tester);

    final op = (await h.ops()).single;
    expect(op.method, 'PATCH');
    expect(payloadOf(op), {
      'notification_prefs': {
        'task_reminders': true,
        'partner_activity': true,
        'savings_activity': true,
        'special_dates': false,
      },
    });

    await disposeApp(tester, h);
  });

  testWidgets('push pengingat tanggal penting: channel pengingat, lalu ketukannya membuka Beranda', (tester) async {
    final h = Harness();
    await h.seed();
    await h.seedDates();
    final push = FakePushService();
    final container = await pumpApp(tester, h, push: push);

    const dateReminder = PushMessage(
      title: 'Tanggal penting',
      body: 'Hari jadi kita 7 hari lagi',
      data: {'type': 'special_date_reminder', 'space_id': sharedSpaceId, 'special_date_id': specialDateId},
    );
    const birthdayReminder = PushMessage(
      title: 'Tanggal penting',
      body: 'Ulang tahun Sari besok',
      data: {'type': 'special_date_reminder', 'space_id': sharedSpaceId, 'member_id': partnerId},
    );

    push.receive(dateReminder);
    await settle(tester);
    push.receive(birthdayReminder);
    await settle(tester);

    expect([for (final message in push.shown) message.channel], [PushChannels.reminders, PushChannels.reminders]);
    expect([for (final message in push.shown) message.tag], ['date-$specialDateId', 'birthday-$partnerId']);

    container.read(routerProvider).go(Routes.specialDates);
    await settle(tester);
    push.tap(dateReminder);
    await settle(tester);

    expect(container.read(routerProvider).state.uri.path, Routes.home);
    expect(find.text('12 hari lagi'), findsOneWidget);

    await disposeApp(tester, h);
  });
}
