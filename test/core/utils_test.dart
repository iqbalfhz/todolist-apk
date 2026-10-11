import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todolist/core/time/space_clock.dart';
import 'package:todolist/core/utils/dates.dart';
import 'package:todolist/core/utils/money.dart';
import 'package:todolist/core/utils/ulid.dart';
import 'package:todolist/core/utils/validators.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  group('ULID', () {
    test('26 karakter Crockford huruf kecil, sesuai pola yang diterima server', () {
      for (var i = 0; i < 200; i++) {
        final id = newUlid();
        expect(ulidPattern.hasMatch(id), isTrue, reason: id);
        expect(id, id.toLowerCase());
      }
    });

    test('terurut menurut waktu pembuatan', () {
      final random = Random(1);
      final earlier = newUlid(now: DateTime.utc(2026, 10, 8, 10), random: random);
      final later = newUlid(now: DateTime.utc(2026, 10, 8, 10, 0, 1), random: random);

      expect(earlier.compareTo(later), lessThan(0));
      expect(earlier.substring(0, 10), isNot(later.substring(0, 10)));
    });

    test('unik', () {
      final ids = {for (var i = 0; i < 2000; i++) newUlid(now: DateTime.utc(2026, 10, 8))};
      expect(ids, hasLength(2000));
    });
  });

  group('uang', () {
    test('Rupiah tanpa desimal', () {
      expect(formatMoney(150000, 'IDR'), 'Rp150.000');
      expect(formatMoney(6500000, 'IDR'), 'Rp6.500.000');
      expect(formatMoney(200000, 'IDR', withSign: true), '+Rp200.000');
    });

    test('mata uang lain mengikuti tabel desimal di kontrak', () {
      expect(formatMoney(5000, 'JPY'), '¥5.000');
      expect(formatMoney(1050, 'USD'), r'US$10,50');
      expect(formatMoney(1050, 'EUR'), '€10,50');
    });

    test('format ringkas untuk label grafik', () {
      expect(formatMoneyCompact(1000000, 'IDR'), '1,0 jt');
      expect(formatMoneyCompact(1800000, 'IDR'), '1,8 jt');
      expect(formatMoneyCompact(500000, 'IDR'), '500 rb');
      expect(formatMoneyCompact(0, 'IDR'), '0');
    });

    test('membaca isian nominal', () {
      expect(parseMoneyInput('150.000', 'IDR'), 150000);
      expect(parseMoneyInput('Rp 6.500.000', 'IDR'), 6500000);
      expect(parseMoneyInput('', 'IDR'), isNull);
      expect(parseMoneyInput('10,5', 'USD'), 1050);
      expect(parseMoneyInput('10', 'USD'), 1000);
      expect(parseMoneyInput('1.234,56', 'USD'), 123456);
    });

    test('isian nominal diberi pemisah ribuan saat diketik', () {
      TextEditingValue type(String text, String currency) =>
          MoneyInputFormatter(currency).formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

      expect(type('150000', 'IDR').text, '150.000');
      expect(type('0150000', 'IDR').text, '150.000');
      expect(type('15a0', 'IDR').text, '150');
      expect(type('1234,567', 'USD').text, '1.234,56');
      expect(type('12,5', 'IDR').text, '12');
      expect(type('', 'IDR').text, '');
    });

    test('teks awal isian untuk nilai yang sudah ada', () {
      expect(moneyInputText(200000, 'IDR'), '200.000');
      expect(moneyInputText(1050, 'USD'), '10,50');
    });
  });

  group('tanggal', () {
    test('format sesuai CLAUDE.md', () {
      expect(formatDayShort('2026-10-08', currentYear: 2026), 'Kam, 8 Okt');
      expect(formatDayShort('2027-02-28', currentYear: 2026), 'Min, 28 Feb 2027');
      expect(formatDateMedium('2027-02-28'), '28 Feb 2027');
      expect(formatClock('19:00'), '19.00');
      expect(formatWeekdayLong(DateTime(2026, 10, 8)), 'Kamis, 8 Oktober');
      expect(formatMonthShort(2026, 8), 'Agu');
    });

    test('hitung hari', () {
      expect(addDays('2026-10-31', 1), '2026-11-01');
      expect(addDays('2026-03-01', -1), '2026-02-28');
      expect(daysBetween('2026-10-08', '2027-02-28'), 143);
      expect(daysBetween('2026-10-08', '2026-10-07'), -1);
    });

    test('"hari ini" dihitung di zona waktu ruang, bukan zona waktu HP', () {
      // 8 Okt 2026 pukul 18.30 UTC: masih tanggal 8 di London, sudah tanggal 9 di Jakarta dan Tokyo.
      final clock = SpaceClock(now: () => DateTime.utc(2026, 10, 8, 18, 30));

      expect(clock.today('Asia/Jakarta'), '2026-10-09');
      expect(clock.nowIn('Asia/Jakarta').time, '01:30');
      expect(clock.today('Europe/London'), '2026-10-08');
      expect(clock.today('Asia/Tokyo'), '2026-10-09');
      expect(clock.today('Zona/TidakAda'), '2026-10-09', reason: 'zona tak dikenal memakai Asia/Jakarta');
    });

    test('tanggal lahir: tahun boleh kosong', () {
      final noYear = BirthDate.tryParse('--03-02')!;
      expect(noYear.year, isNull);
      expect(noYear.format(), '2 Maret');
      expect(noYear.toContract(), '--03-02');

      final withYear = BirthDate.tryParse('1998-03-02')!;
      expect(withYear.format(), '2 Maret 1998');
      expect(withYear.toContract(), '1998-03-02');
    });

    test('tanggal lahir dicek dengan kalender, sama seperti server', () {
      expect(BirthDate.tryParse('--02-29'), isNotNull);
      expect(BirthDate.tryParse('--02-30'), isNull);
      expect(BirthDate.tryParse('2001-02-29'), isNull);
      expect(BirthDate.tryParse('2000-02-29'), isNotNull);
      expect(BirthDate.tryParse('--13-01'), isNull);
      expect(BirthDate.tryParse('03-02'), isNull);
      expect(BirthDate.tryParse(null), isNull);
    });
  });

  group('validasi', () {
    test('panjang teks dihitung dalam code point, sama dengan server', () {
      expect(textLength('abc'), 3);
      expect(textLength('🛒'), 1);
      expect('🛒'.length, 2, reason: 'String.length menghitung unit UTF-16, bukan code point');
      expect(isValidRequiredText('🛒' * 50, Limits.name), isTrue);
      expect(isValidRequiredText('🛒' * 51, Limits.name), isFalse);
    });

    test('teks wajib tidak boleh kosong setelah dirapikan', () {
      expect(isValidRequiredText('   ', Limits.taskTitle), isFalse);
      expect(isValidRequiredText(' Beli galon ', Limits.taskTitle), isTrue);
      expect(isValidRequiredText('a' * 201, Limits.taskTitle), isFalse);
      expect(nullIfBlank('  '), isNull);
      expect(nullIfBlank(' catatan '), 'catatan');
    });

    test('nominal lebih dari 0 dan paling besar 10^15', () {
      expect(isValidAmount(0), isFalse);
      expect(isValidAmount(1), isTrue);
      expect(isValidAmount(1000000000000000), isTrue);
      expect(isValidAmount(1000000000000001), isFalse);
      expect(isValidAmount(null), isFalse);
    });

    test('kode undangan: 6 karakter tanpa 0, O, 1, dan I', () {
      expect(normalizeInvitationCode(' k7m-2qx '), 'K7M2QX');
      expect(isValidInvitationCode('k7m2qx'), isTrue);
      expect(isValidInvitationCode('K7M2Q'), isFalse);
      expect(isValidInvitationCode('K7M2Q0'), isFalse);
      expect(isValidInvitationCode('K7M2QO'), isFalse);
      expect(isValidInvitationCode('K7M2Q1'), isFalse);
      expect(isValidInvitationCode('K7M2QI'), isFalse);
    });

    test('emoji: tepat satu emoji', () {
      expect(isSingleEmoji('🛒'), isTrue);
      expect(isSingleEmoji('✈️'), isTrue);
      expect(isSingleEmoji('👨‍👩‍👧'), isTrue);
      expect(isSingleEmoji('🇮🇩'), isTrue);
      expect(isSingleEmoji('🛒🛒'), isFalse);
      expect(isSingleEmoji('a'), isFalse);
      expect(isSingleEmoji('7'), isFalse);
      expect(isSingleEmoji(''), isFalse);
      expect(lastEmojiOf('abc🛒✈️'), '✈️');
      expect(lastEmojiOf('abc'), isNull);
    });

    test('email', () {
      expect(isValidEmail('nama@email.com'), isTrue);
      expect(isValidEmail('nama@email'), isFalse);
      expect(isValidEmail('nama email@x.com'), isFalse);
    });
  });
}
