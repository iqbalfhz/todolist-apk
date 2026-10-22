import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/time/space_clock.dart';
import '../../../core/utils/dates.dart';
import '../../spaces/domain/household.dart';
import 'special_date.dart';

/// Satu baris di daftar "Akan datang": tanggal penting dari sync, atau ulang tahun
/// anggota yang diambil dari profil.
class UpcomingDate {
  const UpcomingDate({
    required this.key,
    required this.type,
    required this.date,
    required this.next,
    required this.daysLeft,
    this.specialDate,
    this.memberId,
    this.memberName,
    this.memberColor,
    this.isMine = false,
    this.isPrivate = false,
  });

  /// Sama dengan `tag` push: `date-{id}` atau `birthday-{member_id}`.
  final String key;
  final SpecialDateType type;
  final AnnualDate date;

  /// Hari jatuhnya berikutnya (`YYYY-MM-DD`) di zona waktu ruangnya.
  final String next;

  /// 0 berarti hari ini.
  final int daysLeft;

  /// Terisi untuk tanggal penting; kosong untuk ulang tahun anggota.
  final SpecialDate? specialDate;
  final String? memberId;
  final String? memberName;
  final String? memberColor;

  /// Ulang tahun sendiri.
  final bool isMine;

  /// Disimpan di Ruang Pribadi, jadi pasangan tidak melihatnya.
  final bool isPrivate;

  bool get isToday => daysLeft == 0;

  /// Ini yang ke berapa pada [next], misalnya 3 untuk hari jadi ketiga. Hanya kalau tahunnya diisi.
  int? get ordinal => date.ordinalAt(next);
}

/// Hari jadi yang dipakai kartu "Bersama sejak".
class TogetherSince {
  const TogetherSince({required this.since, required this.days, required this.anniversary});

  /// `YYYY-MM-DD`.
  final String since;

  /// Jumlah hari dari [since] sampai hari ini.
  final int days;

  /// Hari jadi itu di daftar "Akan datang", untuk hitung mundur berikutnya.
  final UpcomingDate anniversary;
}

class UpcomingDates {
  const UpcomingDates({required this.items, this.together});

  /// Urut dari yang paling dekat.
  final List<UpcomingDate> items;
  final TogetherSince? together;

  UpcomingDate? get nearest => items.firstOrNull;
}

/// Susun daftar "Akan datang" dari cache lokal. Hitung mundurnya dihitung di HP,
/// di zona waktu ruang masing-masing, sama dengan pengingat dari server.
UpcomingDates buildUpcomingDates({
  required Household household,
  required List<SpecialDate> dates,
  required SpaceClock clock,
  required DateTime now,
}) {
  final items = <UpcomingDate>[];
  String todayIn(String timezone) => clock.wallClock(now, timezone).date;

  for (final special in dates) {
    final space = household.spaceOf(special.spaceId);
    final date = AnnualDate.tryParse(special.date);
    if (special.deletedAt != null || space == null || date == null) continue;

    final today = todayIn(space.timezone);
    final next = date.nextFrom(today);
    items.add(
      UpcomingDate(
        key: 'date-${special.id}',
        type: special.kind,
        date: date,
        next: next,
        daysLeft: daysBetween(today, next),
        specialDate: special,
        isPrivate: space.isPersonal,
      ),
    );
  }

  // Ulang tahun anggota memakai zona waktu Ruang Bersama, sama dengan pengingatnya.
  final birthdayZone = household.shared?.timezone ?? household.personal?.timezone ?? household.me.timezone;

  void addBirthday({
    required String memberId,
    required String name,
    required String color,
    required String? birthDate,
    required bool mine,
  }) {
    final date = AnnualDate.tryParse(birthDate);
    if (date == null) return;

    final today = todayIn(birthdayZone);
    final next = date.nextFrom(today);
    items.add(
      UpcomingDate(
        key: 'birthday-$memberId',
        type: SpecialDateType.birthday,
        date: date,
        next: next,
        daysLeft: daysBetween(today, next),
        memberId: memberId,
        memberName: name,
        memberColor: color,
        isMine: mine,
      ),
    );
  }

  final me = household.me;
  addBirthday(memberId: me.id, name: me.name, color: me.color, birthDate: me.birthDate, mine: true);

  final partner = household.partner;
  if (partner != null) {
    addBirthday(
      memberId: partner.id,
      name: partner.name,
      color: partner.color,
      birthDate: partner.birthDate,
      mine: false,
    );
  }

  items.sort((a, b) {
    final byDays = a.daysLeft.compareTo(b.daysLeft);
    if (byDays != 0) return byDays;
    if (a.isPrivate != b.isPrivate) return a.isPrivate ? 1 : -1;
    return a.key.compareTo(b.key);
  });

  return UpcomingDates(items: items, together: _togetherSince(items, household, todayIn));
}

/// Hari jadi tertua yang tahunnya diisi dan sudah lewat; yang di Ruang Bersama didahulukan.
TogetherSince? _togetherSince(List<UpcomingDate> items, Household household, String Function(String) todayIn) {
  TogetherSince? best;

  for (final item in items) {
    final special = item.specialDate;
    if (special == null || item.type != SpecialDateType.anniversary || item.date.year == null) continue;

    final since = item.date.toContract();
    final days = daysBetween(since, todayIn(household.timezoneOf(special.spaceId)));
    if (days < 0) continue;

    final current = best;
    final better =
        current == null ||
        (current.anniversary.isPrivate && !item.isPrivate) ||
        (current.anniversary.isPrivate == item.isPrivate && since.compareTo(current.since) < 0);
    if (better) best = TogetherSince(since: since, days: days, anniversary: item);
  }

  return best;
}

/// `null` selama profil, ruang, atau tanggal penting belum terbaca dari cache.
final upcomingDatesProvider = Provider<UpcomingDates?>((ref) {
  final household = ref.watch(householdProvider);
  final dates = ref.watch(specialDatesProvider).value;
  if (household == null || dates == null) return null;

  return buildUpcomingDates(
    household: household,
    dates: dates,
    clock: ref.watch(spaceClockProvider),
    now: ref.watch(nowProvider),
  );
});
