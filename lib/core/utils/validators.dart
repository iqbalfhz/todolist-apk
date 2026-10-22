import 'package:flutter/widgets.dart' show Characters;

import '../constants/currencies.dart';

/// Aturan validasi yang sama dengan `docs/kontrak-api.md`, supaya 422 dari antrean tidak terjadi.
///
/// Panjang teks dihitung dalam code point (`runes.length`), sama dengan `max` di Laravel.
abstract final class Limits {
  static const int name = 50;
  static const int taskTitle = 200;
  static const int taskNotes = 5000;
  static const int entryNote = 200;
  static const int specialDateTitle = 50;
  static const int emoji = 16;
  static const int passwordMin = 8;
  static const int invitationCode = 6;
}

int textLength(String value) => value.runes.length;

/// Teks wajib: tidak kosong setelah dirapikan dan tidak melebihi [max] code point.
bool isValidRequiredText(String value, int max) {
  final trimmed = value.trim();
  return trimmed.isNotEmpty && textLength(trimmed) <= max;
}

/// Teks opsional: boleh kosong, tidak melebihi [max] code point.
bool isValidOptionalText(String value, int max) => textLength(value.trim()) <= max;

/// Rapikan teks opsional; kosong menjadi `null` (server juga mengubah teks kosong menjadi `null`).
String? nullIfBlank(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

bool isValidAmount(int? amount) => amount != null && amount >= 1 && amount <= maxAmount;

final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool isValidEmail(String value) => _email.hasMatch(value.trim());

/// Alfabet kode undangan: tanpa 0, O, 1, dan I.
const String invitationAlphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

/// Seragamkan kode seperti server: huruf besar, tanpa spasi dan tanda hubung.
String normalizeInvitationCode(String value) => value.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

bool isValidInvitationCode(String value) {
  final code = normalizeInvitationCode(value);
  return code.length == Limits.invitationCode && code.split('').every(invitationAlphabet.contains);
}

/// Pastikan isinya tepat satu emoji: satu gugus grafem, bukan huruf, angka, atau tanda baca biasa.
bool isSingleEmoji(String value) {
  if (value.isEmpty || textLength(value) > Limits.emoji) return false;
  if (Characters(value).length != 1) return false;
  return value.runes.any(_isEmojiRune);
}

/// Ambil gugus grafem terakhir yang berupa emoji dari [value], atau `null` kalau tidak ada.
String? lastEmojiOf(String value) {
  for (final cluster in Characters(value).toList().reversed) {
    if (isSingleEmoji(cluster)) return cluster;
  }
  return null;
}

bool _isEmojiRune(int rune) =>
    (rune >= 0x1F000 && rune <= 0x1FAFF) || // emoji, simbol, dan piktograf
    (rune >= 0x2600 && rune <= 0x27BF) || // simbol lain-lain dan dingbat
    (rune >= 0x2190 && rune <= 0x21FF) || // panah
    (rune >= 0x2300 && rune <= 0x23FF) || // teknis (jam, jam pasir)
    (rune >= 0x2B00 && rune <= 0x2BFF) || // bintang, panah tebal
    rune == 0x20E3 || // tombol angka (1️⃣)
    rune == 0x00A9 ||
    rune == 0x00AE ||
    rune == 0x203C ||
    rune == 0x2049 ||
    rune == 0x2122 ||
    rune == 0x3030 ||
    rune == 0x303D;
