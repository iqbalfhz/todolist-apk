import 'package:material_ui/material_ui.dart';

import '../utils/dates.dart';

/// Pilih tanggal kalender. [today] adalah hari ini di zona waktu ruang, bukan zona waktu HP.
/// [earliest] membatasi tanggal paling awal yang bisa dipilih, misalnya tanggal pulang
/// yang tidak boleh sebelum tanggal berangkat. Mengembalikan `YYYY-MM-DD`.
Future<String?> pickDate(BuildContext context, {required String today, String? initial, String? earliest}) async {
  final current = _local(today);
  final first = earliest == null ? DateTime(current.year - 5) : _local(earliest);
  final last = DateTime(current.year + 10, 12, 31);
  var start = initial == null ? current : _local(initial);
  if (start.isBefore(first)) start = first;
  if (start.isAfter(last)) start = last;

  final picked = await showDatePicker(
    context: context,
    initialDate: start,
    currentDate: current,
    firstDate: first,
    lastDate: last,
  );
  return picked == null ? null : ymdOf(picked);
}

DateTime _local(String ymd) {
  final date = parseYmd(ymd);
  return DateTime(date.year, date.month, date.day);
}

/// Pilih jam dalam format 24 jam. Mengembalikan `HH:MM`.
Future<String?> pickTime(BuildContext context, {String? initial}) async {
  final parts = (initial ?? '17:00').split(':');
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    builder: (context, child) =>
        MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
  );
  return picked == null ? null : hmOf(DateTime(2000, 1, 1, picked.hour, picked.minute));
}
