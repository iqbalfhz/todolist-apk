# CLAUDE.md — mobile (Flutter)

App to-do untuk berdua: tugas, tabungan, liburan, dan kenangan, dengan Ruang Pribadi dan Ruang Bersama. Pengguna awal: pemilik repo dan pasangannya, keduanya Android. v0.1 sampai v0.3 hanya untuk Android. Semua teks di layar berbahasa Indonesia.

**Sumber kebenaran API: `docs/kontrak-api.md`.** Baca sebelum menyentuh model, API client, database lokal, antrean, sync, atau notifikasi. Kalau kode dan kontrak berbeda, ikuti kontrak lalu tanyakan. Backend ada di repo `api` (Laravel).

**Sumber kebenaran layar: `docs/layar.md`** (daftar layar, isi, dan navigasi) dan mockup HTML di `docs/mockup/`. Baca sebelum membuat atau mengubah layar.

## Cakupan v0.1 (yang sedang dibangun)

- Masuk, daftar, izin notifikasi, dan panduan baterai
- Beranda, Tugas (daftar, tambah cepat, detail), Tabungan (target, setor, riwayat, statistik)
- Ajak pasangan (kode undangan), Pengaturan (profil dan foto, tema, notifikasi, mata uang)
- Cache lokal, antrean offline, sync, dan push notification

Belum dibangun, jangan dibuat dulu: Liburan dan checklist persiapan (v0.2), Tanggal penting (v0.2), Kenangan (v0.3), ekspor data dan hapus akun (v1.0), iOS.

**Belum final:** bagian "Perubahan dari rancangan awal" dan "Masih terbuka" di akhir kontrak belum semuanya disetujui pemilik. Kalau ada yang ditolak, kontrak dan file ini diperbarui.

## Stack

- Flutter stable, Dart 3, Material 3
- Riverpod untuk state, go_router untuk routing dan deep link dari notifikasi
- dio untuk HTTP, dengan interceptor token dan retry
- drift (SQLite) untuk cache lokal dan antrean (outbox)
- freezed + json_serializable untuk model
- flutter_secure_storage untuk token (jangan SharedPreferences)
- firebase_messaging + flutter_local_notifications
- image_picker, image_cropper, flutter_image_compress, cached_network_image
- fl_chart (statistik tabungan), share_plus (bagikan kode undangan)
- material_symbols_icons (ikon)
- flutter_localizations + intl (ARB, `id_ID`), flutter_timezone + timezone

## Perintah

- `flutter run --dart-define-from-file=env/dev.json` — jalankan ke HP
- `dart run build_runner build --delete-conflicting-outputs` — setelah mengubah model freezed atau tabel drift
- `flutter analyze` dan `flutter test` — sebelum commit
- `dart format .` — format kode

## Konfigurasi

- `env/dev.json`, `env/staging.json`, `env/prod.json` berisi `API_BASE_URL`, dibaca lewat `String.fromEnvironment`.
- HP lewat kabel USB ke API lokal: `adb reverse tcp:8000 tcp:8000`, lalu `API_BASE_URL` = `http://127.0.0.1:8000/api/v1`. Emulator: `http://10.0.2.2:8000/api/v1`.
- HTTP tanpa TLS hanya diizinkan di build debug (`android/app/src/debug/AndroidManifest.xml`); staging dan produksi selalu HTTPS.
- Firebase disiapkan dengan `flutterfire configure` (menghasilkan `lib/firebase_options.dart` dan `google-services.json`).

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

## Git

- Kerja di branch (`feat/...`, `fix/...`), lalu merge ke `main`. Commit kecil dengan awalan `feat:`, `fix:`, `chore:`, `test:`, atau `docs:`.

## Jangan

- Jangan menyimpan token di SharedPreferences.
- Jangan mengubah bentuk JSON atau aturan antrean/sync tanpa memperbarui `docs/kontrak-api.md`.
- Jangan menambah package baru tanpa alasan yang jelas; pakai yang sudah ada di Stack.
- Jangan menyalin desain aplikasi lain persis; ikuti mockup, token, dan prinsip di file ini.
