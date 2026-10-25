import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// Pencarian lintas modul (v1.x): tugas, tabungan, liburan, kenangan, dan tanggal penting,
/// semuanya dari cache lokal. Jalan saat offline dan tidak memanggil server.
///
/// Huruf besar-kecil dan tanda aksen diabaikan ("cafe" menemukan "Café"). Kata kunci dipecah
/// per spasi, dan setiap kata harus ada di judul atau kolom lain data yang sama.
class SearchQuery {
  SearchQuery._(this.text, this.folded, this.tokens);

  factory SearchQuery.parse(String input) {
    final text = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    final folded = foldForSearch(text);
    final tokens = folded.split(' ').where((token) => token.isNotEmpty).toSet().toList()
      // Kata yang lebih panjang dicari dulu, supaya sorotannya tidak terpotong kata pendek.
      ..sort((a, b) => b.length.compareTo(a.length));
    return SearchQuery._(text, folded, tokens);
  }

  /// Paling sedikit dua huruf, supaya satu huruf tidak menampilkan hampir semua data.
  static const int minLength = 2;

  /// Kata kunci seperti yang diketik, dirapikan.
  final String text;

  /// [text] tanpa huruf besar dan aksen.
  final String folded;

  final List<String> tokens;

  bool get isSearchable => folded.runes.length >= minLength;
}

/// Satu data yang cocok.
class SearchHit<T> {
  const SearchHit({required this.item, required this.title, required this.rank, this.snippet});

  final T item;
  final String title;

  /// 0: judul diawali kata kunci; 1: judul memuat semua kata; 2: cocok di kolom lain.
  final int rank;

  /// Potongan kolom lain yang cocok (catatan, cerita, tujuan), hanya kalau judulnya
  /// tidak memuat semua kata.
  final String? snippet;
}

/// Cari [query] di [items]. Hasilnya urut [SearchHit.rank]; yang rank-nya sama tetap dalam
/// urutan [items].
List<SearchHit<T>> searchItems<T>(
  Iterable<T> items,
  SearchQuery query, {
  required String Function(T item) title,
  List<String?> Function(T item)? others,
}) {
  if (!query.isSearchable) return const [];

  final hits = <(int, SearchHit<T>)>[];
  var index = 0;
  for (final item in items) {
    final hit = _match(item, query, title(item), others?.call(item) ?? const []);
    if (hit != null) hits.add((index, hit));
    index++;
  }

  hits.sort((a, b) {
    final byRank = a.$2.rank.compareTo(b.$2.rank);
    return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
  });
  return [for (final (_, hit) in hits) hit];
}

SearchHit<T>? _match<T>(T item, SearchQuery query, String title, List<String?> others) {
  final foldedTitle = foldForSearch(title);
  final fields = [
    for (final field in others)
      if (field != null && field.isNotEmpty) field,
  ];
  final foldedFields = [for (final field in fields) foldForSearch(field)];

  for (final token in query.tokens) {
    if (!foldedTitle.contains(token) && !foldedFields.any((field) => field.contains(token))) return null;
  }

  if (foldedTitle.startsWith(query.folded)) return SearchHit(item: item, title: title, rank: 0);
  final missing = query.tokens.where((token) => !foldedTitle.contains(token)).toList();
  if (missing.isEmpty) return SearchHit(item: item, title: title, rank: 1);

  // Potongan dari kolom pertama yang memuat kata yang tidak ada di judul.
  final token = missing.first;
  for (var i = 0; i < fields.length; i++) {
    final at = foldedFields[i].indexOf(token);
    if (at >= 0) {
      return SearchHit(item: item, title: title, rank: 2, snippet: snippetAround(fields[i], at, token.length));
    }
  }
  return SearchHit(item: item, title: title, rank: 2);
}

/// Potongan [text] di sekitar posisi [at] sepanjang [length], dipotong di batas kata dan
/// diberi "…" di ujung yang terpotong. Baris baru diganti spasi.
String snippetAround(String text, int at, int length, {int before = 30, int after = 70}) {
  final flat = text.replaceAll(RegExp(r'[\r\n\t]'), ' ');
  var start = at - before;
  var end = at + length + after;

  if (start <= 0) {
    start = 0;
  } else {
    final space = flat.indexOf(' ', start);
    if (space >= 0 && space < at) start = space + 1;
  }

  if (end >= flat.length) {
    end = flat.length;
  } else {
    final space = flat.lastIndexOf(' ', end);
    if (space > at + length) end = space;
  }

  // Jangan memotong emoji (pasangan surrogate) di tengah.
  if (start > 0 && _isLowSurrogate(flat.codeUnitAt(start))) start--;
  if (end < flat.length && _isLowSurrogate(flat.codeUnitAt(end))) end++;

  final middle = flat.substring(start, end).trim();
  return '${start > 0 ? '…' : ''}$middle${end < flat.length ? '…' : ''}';
}

bool _isLowSurrogate(int unit) => unit >= 0xdc00 && unit <= 0xdfff;

/// Bagian [text] yang cocok dengan [tokens], sebagai rentang (awal, akhir) yang urut dan
/// tidak bertumpuk, untuk disorot.
List<(int, int)> matchRanges(String text, List<String> tokens) {
  final folded = foldForSearch(text);
  final ranges = <(int, int)>[];
  for (final token in tokens) {
    var from = 0;
    while (true) {
      final at = folded.indexOf(token, from);
      if (at < 0) break;
      ranges.add((at, at + token.length));
      from = at + 1;
    }
  }
  ranges.sort((a, b) => a.$1.compareTo(b.$1));

  final merged = <(int, int)>[];
  for (final range in ranges) {
    if (merged.isNotEmpty && range.$1 <= merged.last.$2) {
      final last = merged.removeLast();
      merged.add((last.$1, range.$2 > last.$2 ? range.$2 : last.$2));
    } else {
      merged.add(range);
    }
  }
  return merged;
}

/// [text] tanpa huruf besar dan tanpa aksen umum. Panjangnya (dalam code unit) selalu sama
/// dengan aslinya, supaya posisi kecocokan bisa dipakai langsung untuk menyorot teks asli.
String foldForSearch(String text) => String.fromCharCodes(text.runes.map(_foldRune));

int _foldRune(int rune) {
  final lower = String.fromCharCode(rune).toLowerCase().runes.toList();
  final folded = lower.length == 1 ? (_accents[lower.single] ?? lower.single) : rune;
  // Jangan sampai panjangnya berubah (huruf di luar BMP menjadi huruf BMP, atau sebaliknya).
  return (folded > 0xffff) == (rune > 0xffff) ? folded : rune;
}

const Map<int, int> _accents = {
  0xe0: 0x61, 0xe1: 0x61, 0xe2: 0x61, 0xe3: 0x61, 0xe4: 0x61, 0xe5: 0x61, // à-å → a
  0xe7: 0x63, // ç → c
  0xe8: 0x65, 0xe9: 0x65, 0xea: 0x65, 0xeb: 0x65, // è-ë → e
  0xec: 0x69, 0xed: 0x69, 0xee: 0x69, 0xef: 0x69, // ì-ï → i
  0xf1: 0x6e, // ñ → n
  0xf2: 0x6f, 0xf3: 0x6f, 0xf4: 0x6f, 0xf5: 0x6f, 0xf6: 0x6f, // ò-ö → o
  0xf9: 0x75, 0xfa: 0x75, 0xfb: 0x75, 0xfc: 0x75, // ù-ü → u
  0xfd: 0x79, 0xff: 0x79, // ý, ÿ → y
};

/// Kata kunci terakhir di layar Cari, disimpan selama app berjalan supaya hasilnya masih ada
/// saat Cari dibuka lagi. Dikosongkan saat akun berganti.
class SearchText extends Notifier<String> {
  @override
  String build() {
    ref.watch(accountProvider);
    return '';
  }

  void set(String value) => state = value;
}

final searchTextProvider = NotifierProvider<SearchText, String>(SearchText.new);
