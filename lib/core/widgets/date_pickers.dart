import 'package:material_ui/material_ui.dart';

import '../utils/dates.dart';

/// Pilih tanggal kalender. [today] adalah hari ini di zona waktu ruang, bukan zona waktu HP.
/// Mengembalikan `YYYY-MM-DD`.
Future<String?> pickDate(BuildContext context, {required String today, String? initial}) async {
  final current = _local(today);

  final picked = await showDatePicker(
    context: context,
    initialDate: initial == null ? current : _local(initial),
    currentDate: current,
    firstDate: DateTime(current.year - 5),
    lastDate: DateTime(current.year + 10, 12, 31),
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
