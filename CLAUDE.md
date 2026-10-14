# CLAUDE.md — mobile (Flutter)

**Denly Days**, app to-do untuk berdua: tugas, tabungan, liburan, dan kenangan, dengan Ruang Pribadi dan Ruang Bersama. Nama paket Dart tetap `todolist`; ID app Android `id.my.iqbalfhz.denlydays`. Pengguna awal: pemilik repo dan pasangannya, keduanya Android. v0.1 sampai v0.3 hanya untuk Android. Semua teks di layar berbahasa Indonesia.

**Sumber kebenaran API: `docs/kontrak-api.md`.** Baca sebelum menyentuh model, API client, database lokal, antrean, sync, atau notifikasi. Kalau kode dan kontrak berbeda, ikuti kontrak lalu tanyakan. Backend ada di repo `api` (Laravel).

**Sumber kebenaran layar: `docs/layar.md`** (daftar layar, isi, dan navigasi) dan mockup HTML di `docs/mockup/`. Baca sebelum membuat atau mengubah layar.

## Kondisi repo (per 14 Oktober 2026)

Seluruh cakupan v0.1 di bawah sudah dibangun: semua layar di `docs/layar.md`, cache lokal, antrean, sync, dan penanganan push. `flutter analyze` bersih dan semua tes unit serta widget lulus. Tes ujung ke ujung di `test/e2e/` lulus terhadap API Laravel lokal: lapisan data dengan dua HP (`api_e2e_test.dart`), dan uji jalan penuh lewat layar (`ui_e2e_test.dart`: daftar, tugas, daftar, tabungan, pengaturan, profil, berpasangan, offline, keluar, dan masuk lagi, dengan setiap perubahan dicocokkan ke server). Build debug sudah dicoba di emulator Android 16 terhadap API lokal. Build rilis terbangun dan menyala di emulator yang sama sampai layar Masuk; layar sesudah masuk belum dicoba dalam mode rilis, karena build rilis menolak HTTP ke API lokal.

Belum beres; semuanya butuh keputusan atau akses pemilik:

- **Push belum dicoba di HP sungguhan.** Firebase sudah dikonfigurasi (lihat Konfigurasi), tetapi pendaftaran perangkat (`POST /devices`), push yang sampai ke HP, dan ketukan notifikasi baru diuji dengan layanan notifikasi palsu.
- **Build rilis masih ditandatangani kunci debug.** Buat keystore sebelum membagikan APK rilis.
- `env/staging.json` masih kosong; app menampilkan layar penjelasan kalau dijalankan dengan `API_BASE_URL` kosong.
- Belum pernah dicoba di HP sungguhan: kamera dan pemotong foto profil, bagikan kode undangan, dan panduan baterai di Xiaomi, Oppo, Vivo, dan Realme.
- Warna gelap yang di `.claude/rules/tema.md` masih "belum ditetapkan" (`danger` dan lima warna diri) diisi sementara di `lib/core/theme/app_palette.dart`. Kontrasnya lolos tes, tetapi pilihan warnanya belum disahkan pemilik.
- `ok` di atas `bg` Anggrek terang hanya 4,46:1, di bawah batas 4,5:1. Tokennya tidak diubah; di app, `ok` hanya dipakai di atas `surface`.

Perbarui atau hapus butir di atas begitu selesai dikerjakan.

## Cakupan v0.1 (yang sedang dibangun)

- Masuk, daftar, izin notifikasi, dan panduan baterai
- Beranda, Tugas (daftar, tambah cepat, detail), Tabungan (target, setor, riwayat, statistik)
- Ajak pasangan (kode undangan), Pengaturan (profil dan foto, tema, notifikasi, mata uang)
- Cache lokal, antrean offline, sync, dan push notification

Belum dibangun, jangan dibuat dulu: Liburan dan checklist persiapan (v0.2), Tanggal penting (v0.2), Kenangan (v0.3), ekspor data dan hapus akun (v1.0), iOS.

**Sudah disetujui pemilik (11 Oktober 2026):** semua butir "Perubahan dari rancangan awal" dan dua pertanyaan yang dulu ada di "Masih terbuka" (kini "Sudah diputuskan") di akhir kontrak.

## Stack

- Flutter stable, Dart 3, Material 3. Material diimpor dari paket `material_ui` (`package:material_ui/material_ui.dart`), bukan `package:flutter/material.dart`: go_router 18 dan cached_network_image 4 memakai `material_ui`, dan tipe kedua pustaka itu berbeda (`ThemeData`, `Scaffold`, dan lainnya tidak saling dikenali), jadi kode app harus konsisten memakai `material_ui`.
- Riverpod untuk state, go_router untuk routing dan deep link dari notifikasi
- dio untuk HTTP, dengan interceptor token dan retry
- drift (SQLite) untuk cache lokal dan antrean (outbox); `drift_flutter` membuka file database di HP
- freezed + json_serializable untuk model
- flutter_secure_storage untuk token (jangan SharedPreferences)
- firebase_messaging + flutter_local_notifications
- image_picker, image_cropper, flutter_image_compress, cached_network_image
- fl_chart (statistik tabungan), share_plus (bagikan kode undangan)
- material_symbols_icons (ikon)
- flutter_localizations + intl (ARB, `id_ID`), flutter_timezone + timezone
- flutter_launcher_icons (hanya alat pengembangan) untuk ikon app

## Perintah

- `flutter run --dart-define-from-file=env/dev.json` — jalankan ke HP
- `dart run build_runner build --delete-conflicting-outputs` — setelah mengubah model freezed atau tabel drift
- `flutter analyze` dan `flutter test` — sebelum commit
- `dart format .` — format kode
- `powershell -ExecutionPolicy Bypass -File tool/make_adaptive_icon_foreground.ps1` lalu `dart run flutter_launcher_icons` — setelah mengganti logo di `assets/icon/app_icon.png`. Yang pertama membuat latar depan ikon adaptif (logo dengan tepi diperluas, supaya tidak terpotong di ikon bulat); pengaturannya di `flutter_launcher_icons.yaml`, dan bagian iOS sengaja dimatikan di sana.

## Konfigurasi

- `env/dev.json`, `env/staging.json`, `env/prod.json` berisi `API_BASE_URL`, dibaca lewat `String.fromEnvironment`.
- HP lewat kabel USB ke API lokal: `adb reverse tcp:8000 tcp:8000`, lalu `API_BASE_URL` = `http://127.0.0.1:8000/api/v1`. Emulator: `http://10.0.2.2:8000/api/v1`.
- HTTP tanpa TLS hanya diizinkan di build debug (`android/app/src/debug/AndroidManifest.xml`); staging dan produksi selalu HTTPS.
- Firebase: proyek `todolist-cb119`, hanya app Android `id.my.iqbalfhz.denlydays`. `lib/firebase_options.dart`, `android/app/google-services.json`, dan `firebase.json` dibuat oleh `dart pub global run flutterfire_cli:flutterfire configure --project=todolist-cb119 --platforms=android --android-package-name=id.my.iqbalfhz.denlydays --out=lib/firebase_options.dart --yes` (butuh `firebase login`). Jalankan ulang hanya kalau app di Firebase berubah.

## Struktur (feature-first)

```
lib/
  core/        api client, database lokal (drift), antrean, sync, tema, router, l10n
  features/
    auth/  spaces/  tasks/  savings/  home/  settings/   (v0.2: trips/, v0.3: memories/)
      data/          sumber data + repository
      domain/        model (freezed)
      presentation/  layar dan widget
```

Widget tidak memanggil API langsung; selalu lewat repository.

## Data offline (aturan wajib)

- UI selalu membaca dari drift. Jaringan hanya mengisi drift.
- Tulis: ubah drift dulu (UI langsung berubah), lalu masukkan operasi ke antrean. Hanya PUT/PATCH/DELETE untuk daftar, tugas, target, setoran, dan `PATCH /me` yang lewat antrean; endpoint lain dipanggil langsung dan butuh koneksi.
- ID dibuat di HP: ULID huruf kecil.
- Waktu dikirim dengan `toUtc().toIso8601String()`. Tanggal `YYYY-MM-DD` dan jam `HH:MM` menurut zona waktu ruang; "hari ini" dihitung di zona waktu ruang (paket `timezone`).
- Uang berupa `int` satuan terkecil. Desimal per mata uang dari tabel di kontrak (IDR 0, JPY 0, lainnya 2); selalu isi `decimalDigits` sendiri saat memformat, karena `intl` memakai 2 desimal untuk IDR.
- Panjang teks dihitung dengan `runes.length` (code point), sama dengan server.
- Database lokal dan antrean terpisah per akun. Saat keluar, panggil juga `FirebaseMessaging.instance.deleteToken()`.
- Validasi di HP memakai aturan yang sama dengan kontrak, supaya 422 dari antrean tidak terjadi.

### Antrean

- Dikirim berurutan, satu per satu. Tandai operasi "pernah dikirim" sebelum dikirim.
- Perubahan baru hanya digabung ke operasi untuk data yang sama kalau operasi itu paling akhir di antrean, belum pernah dikirim, dan tidak sedang menunggu Urungkan. Selain itu, tambah operasi baru di ujung. Simpan nilai "sebelum diubah" yang paling awal.
- Selesai dan hapus tugas: operasi tersendiri dengan jeda kirim 5 detik selama tombol Urungkan tampil. Urungkan menghapus operasi itu saja.
- Layar detail: kirim 1 detik setelah berhenti mengetik; tulis ke antrean saat app masuk ke latar belakang.
- `PUT` dibalas 200 (sudah ada): terapkan balasan seperti baris sync, jangan tambah operasi.
- Balasan ditangani sesuai tabel Error di kontrak. Buang operasi atau hapus data lokal hanya kalau balasannya JSON dengan `code` yang dikenal. Non-JSON, 5xx, atau tanpa koneksi: coba lagi dengan jeda 2, 4, 8 detik, maksimal 5 menit. 401: hentikan antrean dan buka layar Masuk.
- `parent_deleted`/`parent_archived` untuk tugas: pindahkan ke daftar aktif pertama di ruang itu, lalu kirim ulang.

### Sync

- Satu sync pada satu waktu. Kirim dulu operasi yang bisa dikirim, lalu tetap tarik data.
- Halaman pertama `GET /sync?since=...`; berikutnya `?cursor=<next_cursor>` sampai `has_more` false. Simpan `server_time` dari halaman terakhir.
- Sync penuh (tanpa `since`) hanya saat database lokal akun itu masih kosong; sifatnya hanya menambah dan memperbarui.
- Saat menerapkan baris: tanpa foreign key check; kolom dengan operasi tertunda tidak ditimpa; baris dengan DELETE tertunda tidak muncul lagi; baris yang lebih tua dari salinan lokal diabaikan.
- Induk tiba terhapus: hapus anak lokalnya, kecuali anak yang masih punya operasi tertunda.
- Pemicu: app dibuka atau kembali aktif, tarik untuk menyegarkan, dan push yang masuk saat app terbuka.

### Notifikasi

- Dua channel Android: `pengingat` (penting, bersuara) dan `aktivitas` (normal), dibuat saat app pertama dibuka.
- Minta izin notifikasi (Android 13+) dengan penjelasan, plus panduan mematikan optimasi baterai untuk merek seperti Xiaomi, Oppo, Vivo, dan Realme.
- Ketuk notifikasi: sync paling lama 3 detik, lalu buka layar sesuai `type`; kalau data belum ada, buka layar induk dengan pesan singkat.

## UI

- Tema Mawar dan Anggrek, mode terang/gelap/ikuti sistem; pilihan disimpan di HP. Warna, huruf, bentuk, jarak, dan ikon ada di `.claude/rules/tema.md` (dimuat saat mengubah tema atau layar).
- Di layar, jangan menulis warna, ukuran huruf, radius, atau jarak langsung; ambil dari tema dan konstanta di `lib/core/theme/`. Kalau nilainya belum ada, tambahkan di sana dulu.
- Font Plus Jakarta Sans dibundel di `assets/fonts/` (bukan paket google_fonts), supaya tetap tampil saat offline.
- Aksesibilitas: area sentuh minimal 48 dp, kontras teks minimal 4.5:1, setiap tombol ikon punya label `Semantics`, tetap rapi saat huruf sistem diperbesar, animasi dikurangi saat "kurangi gerakan" aktif.
- Jangan hanya mengandalkan warna: penanggung jawab tampil sebagai avatar inisial plus warna; status memakai ikon plus teks; bar progres selalu disertai angka persen.
- Skeleton loading, bukan spinner. Layar kosong selalu menunjukkan langkah berikutnya.
- Teks ramah dan tidak menyalahkan: "Terlewat", bukan "Terlambat!". Label form berupa pertanyaan: "Mau mengerjakan apa?", "Kapan?", "Siapa?". Format: "Kam, 8 Okt", jam 24 jam "19.00", "Rp150.000" tanpa desimal.

## Tes

- Unit test untuk antrean dan sync dengan API palsu: urutan kirim, aturan gabung, jeda Urungkan, perlindungan kolom tertunda, dan penanganan tiap `code` error.
- Widget test untuk alur utama: tambah cepat, centang dan Urungkan, setor tabungan, masukkan kode undangan.
- Tata letak (`test/layout_test.dart`): setiap layar dan lembar bawah dirender pada huruf 1,3× dan 2× serta layar 360 × 640; isi yang meluap membuat tesnya gagal. Layar baru ditambahkan ke sana.
- Klien HTTP (`test/core/api_transport_test.dart`): pemilahan error dari tabel Error di kontrak, terhadap server lokal sementara.
- Ujung ke ujung (`test/e2e/`): hanya jalan kalau `E2E_API_URL` diisi, dan hanya ke API lokal dengan database khusus tes. Caranya ada di kepala filenya. Fitur atau layar baru ditambahkan juga ke `ui_e2e_test.dart`.

## Git

- Kerja di branch (`feat/...`, `fix/...`), lalu merge ke `main`. Commit kecil dengan awalan `feat:`, `fix:`, `chore:`, `test:`, atau `docs:`.

## Jangan

- Jangan menyimpan token di SharedPreferences.
- Jangan mengubah bentuk JSON atau aturan antrean/sync tanpa memperbarui `docs/kontrak-api.md`.
- Jangan menambah package baru tanpa alasan yang jelas; pakai yang sudah ada di Stack.
- Jangan menyalin desain aplikasi lain persis; ikuti mockup, token, dan prinsip di file ini.
