import 'package:todolist/core/database/entity_type.dart';

import 'fixtures.dart';

// Data contoh yang ramai untuk memeriksa tata letak: beberapa daftar, tugas dengan
// berbagai keadaan (terlewat, penting, selesai, judul panjang), dan beberapa target.

const String shoppingListId = listId;
const String houseListId = '01m4dh0420zqexwxs1n4yw5jn3';
const String tripListId = '01m4dh0420zqexwxs1n4yw5jn4';
const String privateListId = '01m4dh0420zqexwxs1n4yw5jn5';
const String archivedListId = '01m4dh0420zqexwxs1n4yw5jn6';

/// Tugas hari ini yang penting, berjam, dan punya catatan.
const String importantTaskId = '01m4dh1yn0t6cdn39q4f091891';

/// Tugas dengan judul yang butuh beberapa baris.
const String longTaskId = '01m4dh1yn0t6cdn39q4f091897';

/// Target bersama dengan setoran di lima bulan terakhir.
const String tripGoalId = '01m4djq1w0ystkpbz7mqd22k3a';

/// Target yang sudah tercapai.
const String achievedGoalId = '01m4djq1w0ystkpbz7mqd22k3c';

/// Tanggal penting berjudul panjang yang jatuh hari ini (kartu ucapan di Beranda).
const String longDateId = '01m4dm2k70z5bq7rn3xw8c4v5a';

String _taskId(int n) => '01m4dh1yn0t6cdn39q4f09189$n';

String _goalId(String suffix) => '01m4djq1w0ystkpbz7mqd22k3$suffix';

String _entryId(int n) => '01m4dk06v0p3ew0dm0dk94s1${n.toString().padLeft(2, '0')}';

extension RichHarness on Harness {
  /// Isi cache seperti akun berpasangan yang sudah lama dipakai. "Hari ini" adalah 8 Oktober 2026.
  Future<void> seedRich() async {
    final store = account.store;
    Future<void> put(EntityType type, Map<String, dynamic> row) => store.write(type, row, serverUpdatedAt: t0);

    await store.write(EntityType.me, userJson());
    api
      ..me = userJson()
      ..spaces = [personalSpaceJson(), sharedSpaceJson(partnerBirthDate: '1999-11-17')];
    await put(EntityType.space, personalSpaceJson());
    await put(EntityType.space, sharedSpaceJson(partnerBirthDate: '1999-11-17'));

    final dates = [
      specialDateJson(date: '2023-10-20'),
      specialDateJson(
        id: longDateId,
        type: 'other',
        title: 'Peringatan hari pertama kami pindah ke rumah baru',
        date: '2021-10-08',
      ),
      specialDateJson(
        id: '01m4dm2k70z5bq7rn3xw8c4v5b',
        spaceId: personalSpaceId,
        type: 'birthday',
        title: 'Ulang tahun Ibu',
        date: '--12-01',
      ),
    ];
    for (final date in dates) {
      await put(EntityType.specialDate, date);
    }

    final lists = [
      listJson(id: shoppingListId),
      listJson(id: houseListId, name: 'Rumah', color: 'biru', position: 2048),
      listJson(id: tripListId, name: 'Liburan Jogja', color: 'bata', position: 3072),
      listJson(id: privateListId, spaceId: personalSpaceId, name: 'Pribadi', color: 'lavender'),
      listJson(id: archivedListId, name: 'Pindahan', color: 'ungu', position: 4096, archivedAt: t0),
    ];
    for (final list in lists) {
      await put(EntityType.list, list);
    }

    final tasks = [
      taskJson(
        id: importantTaskId,
        taskListId: houseListId,
        title: 'Bayar internet',
        dueDate: '2026-10-08',
        dueTime: '19:00',
        priority: 3,
        notes: 'Tagihan Oktober. Bayar lewat m-banking, lalu simpan buktinya di grup.',
        position: 1024,
      ),
      taskJson(id: _taskId(2), title: 'Beli galon', dueDate: '2026-10-08', assigneeIds: [partnerId], position: 1024),
      taskJson(
        id: _taskId(3),
        taskListId: houseListId,
        title: 'Jemur kasur',
        dueDate: '2026-10-08',
        assigneeIds: [meId, partnerId],
        completedAt: '2026-10-08T03:10:00.000000Z',
        completedBy: partnerId,
      ),
      // Terlewat sekaligus penting.
      taskJson(
        id: _taskId(4),
        taskListId: houseListId,
        title: 'Servis motor',
        dueDate: '2026-10-06',
        priority: 3,
        position: 3072,
      ),
      taskJson(
        id: _taskId(5),
        title: 'Beli kado ulang tahun Ibu',
        dueDate: '2026-10-09',
        assigneeIds: [meId, partnerId],
      ),
      taskJson(
        id: _taskId(6),
        taskListId: tripListId,
        title: 'Pesan tiket kereta',
        dueDate: '2026-10-16',
        dueTime: '09:00',
        assigneeIds: [meId, partnerId],
        position: 1024,
      ),
      taskJson(
        id: longTaskId,
        taskListId: houseListId,
        title: 'Tanya tukang soal atap dapur yang bocor waktu hujan deras kemarin malam',
        assigneeIds: [partnerId],
        position: 4096,
      ),
      taskJson(
        id: _taskId(8),
        taskListId: privateListId,
        spaceId: personalSpaceId,
        title: 'Perpanjang SIM',
        dueDate: '2026-10-14',
        position: 1024,
      ),
      taskJson(
        id: _taskId(9),
        taskListId: houseListId,
        title: 'Cuci mobil',
        completedAt: '2026-10-07T09:00:00.000000Z',
        completedBy: meId,
        position: 5120,
      ),
    ];
    for (final task in tasks) {
      await put(EntityType.task, task);
    }

    final goals = [
      goalJson(id: tripGoalId),
      goalJson(
        id: _goalId('b'),
        spaceId: personalSpaceId,
        name: 'Laptop baru',
        targetAmount: 15000000,
        targetDate: null,
      ),
      {
        ...goalJson(id: achievedGoalId, name: 'Dana darurat', targetAmount: 5000000, targetDate: null),
        'achieved_at': t0,
      },
      goalJson(id: _goalId('d'), name: 'Kado nikahan Rina', targetAmount: 1000000, targetDate: null, archivedAt: t0),
      // Nominal besar, dan mata uang dengan dua desimal.
      goalJson(id: _goalId('e'), name: 'Uang muka rumah', targetAmount: 250000000, targetDate: '2028-12-31'),
      goalJson(id: _goalId('f'), name: 'Kamera', targetAmount: 120000, currency: 'USD', targetDate: '2027-06-30'),
    ];
    for (final goal in goals) {
      await put(EntityType.goal, goal);
    }

    var count = 0;
    Future<void> entry(
      String goal,
      int amount,
      String date, {
      String user = meId,
      String? note,
      String space = sharedSpaceId,
    }) => put(EntityType.entry, {
      ...entryJson(
        id: _entryId(count++),
        savingsGoalId: goal,
        userId: user,
        amount: amount,
        entryDate: date,
        note: note,
      ),
      'space_id': space,
    });

    await entry(tripGoalId, 500000, '2026-06-25', note: 'Gajian');
    await entry(tripGoalId, 1000000, '2026-07-25', user: partnerId);
    await entry(tripGoalId, 750000, '2026-08-27');
    await entry(tripGoalId, 1250000, '2026-09-25', user: partnerId, note: 'Bonus');
    await entry(tripGoalId, 800000, '2026-10-03', user: partnerId);
    await entry(tripGoalId, 200000, '2026-10-08', note: 'Gajian');
    await entry(_goalId('b'), 3000000, '2026-09-01', space: personalSpaceId, note: 'Tabungan lama');
    await entry(achievedGoalId, 5000000, '2026-08-01', user: partnerId);
    await entry(_goalId('d'), 1000000, '2026-05-01');
    await entry(_goalId('e'), 137500000, '2026-09-30', note: 'Hasil jual tanah warisan keluarga');
    await entry(_goalId('f'), 30000, '2026-10-01', note: 'Jual lensa lama');
  }
}
