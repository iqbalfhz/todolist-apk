---
paths:
  - "lib/core/theme/**"
  - "lib/features/**/presentation/**"
---

# Tema: warna, huruf, bentuk, ikon

Semua nilai di sini diambil dari mockup di `docs/mockup/`. Nilai ini diimplementasikan sekali di `lib/core/theme/`; layar memakainya lewat `Theme.of(context)` dan konstanta dari folder itu, tidak menulis angka atau hex sendiri.

## Warna

Dua tema, Mawar dan Anggrek, masing-masing punya mode terang dan gelap. Setiap kombinasi jadi satu `ThemeData` dengan `ColorScheme` yang diisi manual dari tabel ini (jangan `ColorScheme.fromSeed`). Nilainya sama dengan objek `t` di `<script>` setiap file mockup.

| Token | Mawar terang | Anggrek terang | Mawar gelap | Anggrek gelap | Dipakai untuk |
| --- | --- | --- | --- | --- | --- |
| bg | #FCF3F7 | #F9EEF4 | #1E1519 | #1E1519 | Latar layar (`scaffoldBackgroundColor`) |
| surface | #FFFFFF | #FFFFFF | #2A1F24 | #2A1F24 | Kartu, lembar bawah, tab bawah (`surface`) |
| soft | #F9E4EC | #F3DCE9 | #3B2530 | #3A2434 | Chip terpilih, latar sorotan (`secondaryContainer`) |
| line | #EFD9E2 | #EBD3E0 | #43343B | #43343B | Garis dan batas (`outlineVariant`) |
| text | #2B1A22 | #2B1A22 | #F5E9EE | #F5E9EE | Teks utama (`onSurface`) |
| muted | #6E5A63 | #6E5A63 | #BBA6AF | #BBA6AF | Teks sekunder (`onSurfaceVariant`) |
| primary | #CB2F69 | #CA4189 | #E38BB3 | #DD799F | Tombol utama, FAB (`primary`) |
| onPrimary | #FFFFFF | #FFFFFF | #1E1519 | #1E1519 | Teks/ikon di atas primary (`onPrimary`) |
| link | #B42A5E | #A3326C | #E38BB3 | #DD799F | Teks tautan dan tombol teks |
| brand | #D54B7E | #CA4189 | #E38BB3 | #DD799F | Isi progres, centang, ikon aktif (bukan untuk teks putih) |
| accent | #E38BB3 | #CF679C | #ECB1C7 | #CF679C | Ilustrasi dan aksen (`tertiary`) |
| track | #F6DCE6 | #F1D7E5 | #4A2E3B | #482C3E | Jalur bar progres |
| scrim | rgba(43,26,34,0.45) | rgba(43,26,34,0.45) | rgba(0,0,0,0.55) | rgba(0,0,0,0.55) | Latar redup di belakang lembar bawah dan dialog (`scrim`) |
| ok | #2E7D4F | #2E7D4F | #7FD3A0 | #7FD3A0 | Status berhasil, selalu dengan ikon |
| warn | #9A5B00 | #9A5B00 | #F0B45C | #F0B45C | Status peringatan dan label "Terlewat", selalu dengan ikon |
| danger | #B3261E | #B3261E | belum ditetapkan | belum ditetapkan | Hapus dan error; versi gelap harus lebih terang, cek kontras dulu |

Aturan:

- Hanya `primary` yang boleh berisi teks putih (mode terang). `brand` (#D54B7E) gagal kontras untuk teks putih, jadi jangan dipakai sebagai latar teks.
- Warna sorotan (`soft`, `accent`, `track`) selalu diberi teks gelap (`text`).
- Status (ok, warn, danger) hanya untuk teks/ikon di atas `bg` atau `surface`, dan selalu ditemani ikon.
- Pilihan tema (Mawar/Anggrek) dan mode (terang/gelap/ikuti sistem) disimpan di HP, bukan di server.
- Tombol masuk dengan Google (v1.x) tidak memakai token di sini: warnanya dari panduan merek Google (`GoogleButtonColors` di `app_palette.dart`), dan logo G resmi (`assets/images/google_g.png`) tidak boleh diubah warna atau bentuknya.

## Warna diri dan warna daftar

Enam kunci yang sama dipakai untuk warna diri (`color` milik user: avatar inisial, chip penanggung jawab) dan warna daftar (`color` milik daftar tugas: titik di samping nama daftar).

| Kunci | Terang | Gelap |
| --- | --- | --- |
| `mawar` | #CB2F69 | belum ditetapkan |
| `ungu` | #5B57A6 | #A9A3F0 |
| `toska` | #2E7D73 | belum ditetapkan |
| `bata` | #B4541F | belum ditetapkan |
| `biru` | #3567B5 | belum ditetapkan |
| `lavender` | #8A4FA0 | belum ditetapkan |

Versi gelap yang belum ditetapkan: pakai varian yang lebih terang dan cek kontrasnya terhadap `surface` gelap.

Di mockup, warna milikmu memakai `{{t.brand}}`, warna pasangan `{{t.p2}}` (ungu), dan titik daftar `{{t.sw1}}` sampai `{{t.sw3}}`. Di app, semuanya diambil dari `color` orang atau daftar itu. Penanggung jawab "Kita" menampilkan dua titik.

## Huruf

Plus Jakarta Sans, tebal 400, 500, 600, 700. Ukuran dalam dp (1 px di mockup = 1 dp). Buat satu gaya per peran (lewat `TextTheme` atau `ThemeExtension`), lalu layar memakai gaya itu.

| Peran | Ukuran dan tebal | Contoh di mockup |
| --- | --- | --- |
| Judul Beranda | 24 Bold | "Selamat sore!", karakter kode undangan |
| Judul layar | 20 Bold (22 di Ajak pasangan) | "Pengaturan", "Dana Liburan" |
| Nominal besar | 22 Bold | "Rp6.500.000" di Detail tabungan |
| Judul lembar bawah | 18 Bold | "Tugas baru" |
| Judul kartu, teks tombol utama | 16 Bold | "Tugas hari ini", "Simpan" |
| Teks di isian | 16 Regular; judul tugas dan kode undangan 16 SemiBold | nama panggilan, judul tugas |
| Judul bagian, nama daftar | 15 Bold | "Notifikasi", "Belanja" |
| Judul baris | 15 SemiBold; tugas selesai 15 Medium dicoret | "Bayar internet", "Profil" |
| Paragraf | 14 Regular | penjelasan di Ajak pasangan |
| Chip filter | 14 Medium, SemiBold saat terpilih | "Aku", "Belum selesai" |
| Nominal di riwayat | 14 Bold | "+Rp200.000" |
| Keterangan | 13 Regular | "1 dari 3 beres" |
| Tautan, label isian | 13 SemiBold | "Lihat semua", "Nama panggilan" |
| Keterangan kecil | 12 Regular; chip penanggung jawab 12 SemiBold | "Kamu dan pasangan · 2 anggota" |
| Label sumbu grafik | 11 Regular | "1,0 jt" |
| Hitung mundur besar (v0.2) | 28 Bold | "1.084 hari" di kartu Bersama sejak |
| Hitung mundur (v0.2) | 20 Bold | "12 hari lagi" di kartu Tanggal penting Beranda |

## Bentuk dan jarak

| Elemen | Nilai |
| --- | --- |
| Halaman | padding samping 20, atas 24 |
| Kartu | radius 20, garis 1 warna `line`, padding 16 |
| Kartu kecil Beranda (v0.2) | setengah lebar, sama tinggi, jarak 12, padding 12 × 14; ikon 18, baris besar 20 Bold |
| Lembar bawah | radius atas 28, pegangan 40 × 4 |
| Isian teks | tinggi 52, radius 14, padding samping 14 |
| Tombol utama | tinggi 52, bulat penuh |
| Chip filter | tinggi 44, bulat penuh, padding samping 16 |
| Chip penanggung jawab | bulat penuh, padding 5 × 10, latar `soft`, titik warna 8 |
| Tombol centang tugas | lingkaran 22 dengan garis 2, di area 44 |
| Tombol ikon | 44 × 44 |
| FAB | 56 × 56, radius 18, 20 dari tepi kanan |
| Avatar | 36 (kepala Beranda), 80 (Ajak pasangan), 112 (Profil) |
| Lingkaran ikon | 40 (baris Pengaturan dan Akan datang), 56 dengan ikon 28 (kartu Bersama sejak dan ringkasan Detail perjalanan) |
| Bar progres | tinggi 6 sampai 8, bulat penuh, jalur `track`, isi `brand` |
| Foto kenangan (v0.3) | kisi 3 kolom persegi, jarak 4, radius 12; sampul 16:9 di kartu linimasa (menempel di atas kartu) dan 4:3 di Detail kenangan (radius 20); kotak `track` selama gambar belum ada; penanda "Menunggu terkirim" lingkaran 24 berlatar `surface` |
| Jarak antarelemen | 4, 6, 8, 10, 12, 16 |

Ukuran 44 adalah ukuran tampilan. Area sentuh tetap minimal 48 dp: biarkan `materialTapTargetSize` bawaan (`padded`).

## Ikon

Material Symbols Rounded dari paket `material_symbols_icons` (`Symbols.<nama>_rounded`), tanpa isi (fill 0), tebal 400. Ukuran mengikuti mockup, paling sering 22, 20, dan 18. Ikon SVG di mockup hanya gambar sementara dengan gaya serupa; jangan disalin.
