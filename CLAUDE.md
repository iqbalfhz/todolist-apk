# CLAUDE.md — mobile (Flutter)

**Denly Days**, app to-do untuk berdua: tugas, tabungan, liburan, dan kenangan, dengan Ruang Pribadi dan Ruang Bersama. Nama paket Dart tetap `todolist`; ID app Android `id.my.iqbalfhz.denlydays`. Pengguna awal: pemilik repo dan pasangannya, keduanya Android. v0.1 sampai v0.3 hanya untuk Android. Semua teks di layar berbahasa Indonesia.

**Sumber kebenaran API: `docs/kontrak-api.md`.** Baca sebelum menyentuh model, API client, database lokal, antrean, sync, atau notifikasi. Kalau kode dan kontrak berbeda, ikuti kontrak lalu tanyakan. Backend ada di repo `api` (Laravel).

**Sumber kebenaran layar: `docs/layar.md`** (daftar layar, isi, dan navigasi) dan mockup HTML di `docs/mockup/`. Baca sebelum membuat atau mengubah layar.

## Kondisi repo (per 30 Oktober 2026)

Seluruh cakupan v0.1 di bawah sudah dibangun: semua layar di `docs/layar.md`, cache lokal, antrean, sync, dan penanganan push. Dari v0.2, Tanggal penting, Perjalanan dengan checklist persiapan, dan pengingat setor rutin juga sudah dibangun, begitu pula Kenangan (v0.3), tugas berulang (awal v1.0), dan bagian v1.x yang cukup di HP (lihat Cakupan). Push sudah sampai ke HP sungguhan dalam uji pemilik dan pasangannya (`task_completed` dan `savings_deposit`, serta `partner_joined` yang dikirim dari server), dan pada 24 Oktober 2026 pukul 08.00 pengingat terjadwal `trip_reminder` dan `special_date_reminder` (H-1 dan hari H) juga sampai. `flutter analyze` bersih dan semua tes unit serta widget lulus. Tes ujung ke ujung di `test/e2e/` lulus terhadap API Laravel lokal: lapisan data dengan dua HP (`api_e2e_test.dart`), dan uji jalan penuh lewat layar (`ui_e2e_test.dart`: daftar, tugas, daftar, tabungan, pengaturan, profil, berpasangan, tanggal penting, perjalanan dan checklist, pengingat setor, tugas berulang, kenangan tanpa foto dan "Simpan jadi kenangan", kontribusi dan penarikan tabungan, pin lokasi kenangan dan Peta kenangan, komentar dan reaksi antara dua HP, Cari, "Setahun lalu, hari ini", sync berkala, ringkasan widget, offline, keluar, masuk dengan Google yang ditolak server, masuk lagi, keluar dari Ruang Bersama dan bergabung lagi, serta hapus akun, dengan setiap perubahan dicocokkan ke server). Build debug sudah dicoba di emulator Android 16 terhadap API lokal. Build rilis terbangun dan menyala di emulator yang sama sampai layar Masuk; layar sesudah masuk belum dicoba dalam mode rilis, karena build rilis menolak HTTP ke API lokal.

Belum beres; semuanya butuh keputusan atau akses pemilik:

- Belum dicoba di HP sungguhan: ketukan notifikasi pengingat v0.2, push `savings_reminder`, dan push `memory_created` (v0.3); di tes semuanya memakai layanan notifikasi palsu.
- Foto kenangan (v0.3) belum pernah diunggah sungguhan: API lokal tidak punya kunci R2, jadi tes ujung ke ujung hanya mencakup kenangan tanpa foto dan unggahan yang ditolak `parent_deleted`. Perlu dicoba di HP terhadap produksi: pilih banyak foto, unggah saat offline lalu online, thumbnail di HP pasangan, Galeri dan versi penuh, Jadikan sampul, hapus foto, dan URL yang diperbarui setelah 7 hari.
- `env/staging.json` masih kosong; app menampilkan layar penjelasan kalau dijalankan dengan `API_BASE_URL` kosong.
- Belum pernah dicoba di HP sungguhan: kamera dan pemotong foto profil, dan bagikan kode undangan.
- Belum diuji: apakah notifikasi tetap sampai di HP Xiaomi (HyperOS) setelah app ditutup dari daftar app terbaru, dengan Mulai otomatis mati (keadaan bawaan di HP pemilik). Kalau tertahan, tambahkan satu tombol di Pengaturan > Notifikasi yang memunculkan dialog Android (Izinkan/Tolak) dan membuka langsung halaman Mulai otomatis; jangan kembali ke langkah manual.
- Warna gelap yang di `.claude/rules/tema.md` masih "belum ditetapkan" (`danger` dan lima warna diri) diisi sementara di `lib/core/theme/app_palette.dart`. Kontrasnya lolos tes, tetapi pilihan warnanya belum disahkan pemilik.
- `ok` di atas `bg` Anggrek terang hanya 4,46:1, di bawah batas 4,5:1. Tokennya tidak diubah; di app, `ok` hanya dipakai di atas `surface`.

- APK terbaru (penarikan tabungan, pin lokasi, komentar dan reaksi, dan masuk dengan Google) sudah terpasang di HP pemilik (30 Oktober 2026, 13.56; salinannya di folder Download sebagai `DenlyDays.apk`), dan harus terpasang juga di HP pasangan sebelum penarikan pertama dicatat: app lama menghitung penarikan sebagai setoran. HP pasangan juga masih memakai APK lama yang koneksinya bisa disadap di Wi-Fi publik.
- Pin lokasi belum dicoba di HP sungguhan: ubin OpenStreetMap, cache ubin, dan cari tempat lewat Nominatim di server produksi.
- Widget "Tugas hari ini" sudah terdaftar di HP pemilik, tetapi belum pernah ditambahkan ke layar utama, jadi tampilannya di launcher HyperOS dan pergantian harinya belum dilihat.
- Masuk dengan Google (30 Oktober 2026) belum dicoba di HP sungguhan: tes memakai pilihan akun palsu, dan uji ujung ke ujung hanya mencakup token yang ditolak server. Server produksi sudah membaca `GOOGLE_CLIENT_ID` (dicek 30 Oktober 2026: token palsu dibalas 422 `google_token_invalid`, bukan 500). Layar persetujuan Google masih berstatus Testing, jadi hanya pemilik dan pasangan yang bisa masuk dengan Google; ubah statusnya sebelum rilis publik.
- Keluar dari Ruang Bersama (30 Oktober 2026) belum dicoba di HP sungguhan, termasuk push `partner_left` dan bergabung lagi. Uji di dua HP hanya dengan dua akun uji, jangan dengan Ruang Bersama pemilik dan pasangannya: keluar menutup ruang itu untuk berdua.
- Hapus akun (31 Oktober 2026) belum dicoba di HP sungguhan, termasuk konfirmasi dengan akun Google dan penghapusan berkas database di HP. Uji hanya dengan akun uji, jangan akun pemilik dan pasangannya.
- Komentar dan reaksi belum dicoba di HP sungguhan: emoji di chip reaksi (tes hanya merender kotak karena font tes tanpa emoji), push `comment_created` dan `reaction_created`, dan ketukannya.

Perbarui atau hapus butir di atas begitu selesai dikerjakan.

## Cakupan

v0.1:

- Masuk, daftar, dan izin notifikasi
- Beranda, Tugas (daftar, tambah cepat, detail), Tabungan (target, setor, riwayat, statistik)
- Ajak pasangan (kode undangan), Pengaturan (profil dan foto, tema, notifikasi, mata uang)
- Cache lokal, antrean offline, sync, dan push notification

v0.2 yang sudah dibangun:

- Tanggal penting: layar Pengaturan > Tanggal penting, koleksi sync `special_dates` dengan sync penuh sekali, hitung mundur dan kartu ucapan hari H di Beranda, ulang tahun anggota dari `birth_date`, switch `special_dates`, dan push `special_date_reminder` (ketuk membuka Beranda)
- Perjalanan: tab Liburan (Daftar perjalanan, Detail perjalanan, Checklist persiapan), checklist berupa daftar dengan `trip_id` yang dibuat app tepat setelah perjalanannya dan disembunyikan dari tab Tugas, Kelola daftar, dan tambah cepat, tautan ke target tabungan, kartu Persiapan liburan di Beranda, koleksi sync `trips`, switch `trip_reminders`, dan push `trip_reminder` (ketuk membuka Detail perjalanan)
- Pengingat setor rutin: jadwal mingguan atau bulanan di Detail target (`reminder_frequency`, `reminder_day`), switch `savings_reminders`, dan push `savings_reminder` (ketuk membuka Detail target)

v0.3 yang sudah dibangun:

- Kenangan: tab Kenangan (linimasa per tahun dan bulan), Detail kenangan, Galeri foto, dan Kenangan baru / Ubah kenangan; paling banyak 50 foto per kenangan, sampul = `position` terkecil, Jadikan sampul, hapus foto dengan Urungkan, dan hapus kenangan berfoto dengan konfirmasi; koleksi sync `memories` dan `memory_photos` dengan sync penuh sekali; "Simpan jadi kenangan" di perjalanan yang sudah selesai; push `memory_created` (channel `aktivitas`, ketuk membuka Detail kenangan)

v1.0 yang sudah dibangun:

- Hapus akun (31 Oktober 2026): Pengaturan > Hapus akun (`/pengaturan/hapus-akun`, nama dan langkahnya sama dengan halaman publik `/hapus-akun` untuk Google Play) dengan akibatnya, lalu kata sandi atau "Lanjutkan dengan Google" dan konfirmasi. `DELETE /me` dengan `password` atau `id_token` (langsung, tidak lewat antrean). Setelah 204, `completeAccountDeletion` menghapus token FCM, cache foto, sesi, penanda Ajak pasangan akun itu, lalu berkas database dan folder foto akun (`AccountFiles`), dan app kembali ke layar Masuk. Kiriman ulang yang dibalas 401 setelah kiriman sebelumnya tanpa balasan dianggap selesai; 401 lain tetap sesi berakhir biasa. HP pasangan menangani Ruang Bersama yang tertutup dan `partner_left` seperti saat keluar.
- Keluar dari Ruang Bersama (30 Oktober 2026): tombol "Keluar dari Ruang Bersama" di Ajak pasangan (yang sudah berpasangan, di luar alur pertama kali) dengan konfirmasi yang menyebut akibatnya. App mengirim antrean dulu, lalu `DELETE /spaces/{id}` (langsung, tidak lewat antrean); setelah 204, ruang dan isinya dibuang dari cache beserta sisa antreannya (`Outbox.forgetSpace`), lalu layar kembali menampilkan kode undangan. Ruang yang tiba tertutup lewat sync ikut menghapus semua isinya. Push `partner_left` (channel `aktivitas`) saat diketuk menjalankan sync lalu membuka Beranda. Bergabung lagi dalam 30 hari memulihkan ruang lama lewat `POST /invitations/accept` dan sync biasa, tanpa kode khusus di app.
- Tugas berulang: aturan `repeat_frequency` (harian, mingguan, bulanan, tahunan) dan `repeat_interval` (1–99) dengan `due_date` sebagai patokan, chip "Ulangi" di Tugas baru dan Detail tugas, lembar Ulangi tugas, penanda "Tiap minggu" di baris tugas, dan tautan "Tugas berikutnya" di tugas yang sudah selesai. Tugas berikutnya dibuat server dan tiba di balasan centang; app tidak menghitung tenggatnya.

v1.x yang sudah dibangun (diminta pemilik 25 Oktober 2026; semuanya cukup di HP):

- Kontribusi tabungan bersama: kartu Kontribusi di Detail tabungan untuk target di Ruang Bersama, berisi bagian Aku dan Pasangan (bar terbagi warna diri, persen yang selalu berjumlah 100, dan nominal) serta Total
- "Setahun lalu, hari ini": kartu kenangan dari tanggal dan bulan yang sama di tahun sebelumnya di Beranda
- Cari (`/cari`, dari kepala Beranda): tugas, target, setoran, perjalanan, kenangan, dan tanggal penting di cache lokal, juga saat offline
- Sinkron langsung: sync tiap 30 detik selama app tampil, dan push `sync` dari server (aktif sejak 25 Oktober 2026) yang hanya memicu sync, tanpa notifikasi
- Penarikan tabungan (29 Oktober 2026): tombol Ambil di Detail target, setoran dengan `type` `withdrawal` yang hanya dikirim saat PUT, total bersih (setoran dikurangi penarikan) untuk progres dan kontribusi, penarikan di atas yang terkumpul dicegah di layar (server menerimanya), riwayat "Aku mengambil" dengan "−Rp...", dan push `savings_withdrawal` (ketuk membuka Detail target)
- Komentar dan reaksi (29 Oktober 2026): koleksi sync `comments` dan `reactions` (skema 7, sync penuh sekali) untuk tugas, setoran, dan kenangan di Ruang Bersama; bagian Komentar di Detail tugas, Detail kenangan, dan lembar detail setoran (ketuk setoran di target bersama); satu reaksi per orang per subjek (reaksi baru menggantikan yang lama, yang belum terkirim dibatalkan tanpa request); hanya penulis yang bisa mengubah dan menghapus komentarnya (hapus dengan Urungkan); penanda reaksi dan jumlah komentar di riwayat setoran dan kartu kenangan; push `comment_created` dan `reaction_created` yang membuka subjeknya langsung di bagian Komentar (`?komentar=1`, atau `?setoran={id}` untuk setoran)
- Pin lokasi kenangan (29 Oktober 2026): `latitude` dan `longitude` di kenangan yang selalu dikirim berdua (dibulatkan 6 desimal), layar Pilih lokasi (cari tempat lewat `GET /places` hanya saat tombol Cari ditekan, atau ketuk peta), pratinjau peta di formulir dan Detail kenangan, dan Peta kenangan (`/kenangan/peta`) dengan ubin OpenStreetMap; kolom baru di `memories`, jadi sync penuh sekali
- Widget "Tugas hari ini" di layar utama Android (`TasksWidget.kt`, kanal `todolist/device`), dengan tombol sematkan di Pengaturan
- Masuk dengan Google (30 Oktober 2026): tombol "Masuk dengan Google" dan "Daftar dengan Google" di bawah formulir Masuk dan Daftar (logo G resmi di `assets/images/`, warna dari panduan merek Google di `GoogleButtonColors`), lalu `POST /auth/google` dengan ID token dari `google_sign_in`. Pilihan akun dilupakan begitu ID token didapat, jadi masuk berikutnya bertanya lagi. Selama token ditukar, akun Google yang dipakai disebut di bawah tombol; balasan 201 (akun baru) memunculkan "Akun baru dibuat untuk {email}." Akun tanpa kata sandi tidak butuh penanganan khusus di app.

Belum dibangun, jangan dibuat dulu: sisa v1.0 (ekspor data dan lupa kata sandi di app), dan iOS. Tabel `activities` (feed aktivitas) ditunda juga di server.

**Sudah disetujui pemilik (11 Oktober 2026):** semua butir "Perubahan dari rancangan awal" dan dua pertanyaan yang dulu ada di "Masih terbuka" (kini "Sudah diputuskan") di akhir kontrak.

## Stack

- Flutter stable paling rendah 3.47.8 (Dart 3.13.7), dikunci di `environment` pada `pubspec.yaml`. Versi sebelumnya mempercayai sertifikat perantara eMudhra yang bocor, sehingga koneksi HTTPS app di Android bisa disadap orang di jaringan yang sama (advisory Dart GHSA-frr6-h895-5pxp, 23 Oktober 2026). Setiap ada rilis keamanan Flutter atau Dart, naikkan batas itu, bangun ulang APK, lalu pasang lagi di kedua HP.
- Material 3. Material diimpor dari paket `material_ui` (`package:material_ui/material_ui.dart`), bukan `package:flutter/material.dart`: go_router 18 dan cached_network_image 4 memakai `material_ui`, dan tipe kedua pustaka itu berbeda (`ThemeData`, `Scaffold`, dan lainnya tidak saling dikenali), jadi kode app harus konsisten memakai `material_ui`.
- Riverpod untuk state, go_router untuk routing dan deep link dari notifikasi
- dio untuk HTTP, dengan interceptor token dan retry
- drift (SQLite) untuk cache lokal dan antrean (outbox); `drift_flutter` membuka file database di HP
- freezed + json_serializable untuk model
- flutter_secure_storage untuk token (jangan SharedPreferences)
- firebase_messaging + flutter_local_notifications
- image_picker, image_cropper, flutter_image_compress, cached_network_image; flutter_cache_manager (cache foto kenangan dengan kunci sendiri) dan path_provider (folder foto yang menunggu diunggah), keduanya sudah ikut lewat cached_network_image
- fl_chart (statistik tabungan), share_plus (bagikan kode undangan)
- flutter_map + latlong2 (peta pin lokasi kenangan, v1.x). Ubin OpenStreetMap mengikuti kebijakan tile OSM: User-Agent app (`userAgentPackageName`), cache ubin bawaan flutter_map (paling banyak 200 MB), dan atribusi "© OpenStreetMap contributors" di setiap peta dan di bawah hasil cari tempat. Hanya ubin, penanda, dan kamera yang dipakai; atribusi dan tombolnya dibuat sendiri, karena widget bawaan flutter_map memakai Material dari Flutter, bukan `material_ui`. Di tes, `mapTileProviderProvider` diganti ubin kosong (`test/helpers/fake_map.dart`)
- material_symbols_icons (ikon)
- google_sign_in (masuk dengan Google, v1.x): Credential Manager di Android, dengan `serverClientId` = client ID klien Web (`Env.googleServerClientId`), sama dengan `GOOGLE_CLIENT_ID` di server. Dibungkus `GoogleAccounts` (`lib/features/auth/data/google_accounts.dart`) supaya bisa diganti di tes
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
- API key Android Firebase ("Android key (auto created by Firebase)" di Google Cloud Console) hanya dibatasi per API, tanpa "Application restrictions". Pembatasan ke Android apps (paket + SHA-1) membuat pendaftaran token FCM gagal dengan "FCM Registration failed!", karena pendaftaran itu dikerjakan Google Play Services; ini terjadi saat token diperbarui setelah 7 hari (22 Oktober 2026), lalu pulih setelah pembatasannya dilepas.
- Masuk dengan Google: klien Web "Denly Days server" dan klien Android (`id.my.iqbalfhz.denlydays` dengan SHA-1 kunci rilis dan debug) ada di Google Cloud proyek `todolist-cb119`. Kalau kunci tanda tangan berganti, daftarkan SHA-1 barunya di klien Android dan di Firebase; tanpa itu memilih akun Google gagal, dan app hanya menampilkan "Masuk dengan Google gagal. Coba lagi." (detailnya di logcat).
- Tanda tangan rilis: kuncinya `denlydays.jks` (alias `denlydays`) di luar repo, di laptop pemilik `C:\Users\LOQ\Documents\Kunci\denlydays.jks`, dibuat sekali dengan `keytool -genkeypair -v -keystore <folder>\denlydays.jks -keyalg RSA -keysize 2048 -validity 10000 -alias denlydays -dname "CN=Denly Days, C=ID"`. `android/key.properties` berisi `storeFile`, `storePassword`, `keyAlias`, dan `keyPassword`. Berkas itu dan semua `.jks` tidak masuk git. Tanpa `key.properties`, build rilis berhenti dengan pesan; build debug tetap jalan. Kunci dan kata sandinya harus dicadangkan: pembaruan app hanya bisa dipasang di atas versi lama kalau ditandatangani kunci yang sama.

## Struktur (feature-first)

```
lib/
  core/        api client, database lokal (drift), antrean, sync, media (foto), tema, router, l10n
  features/
    auth/  spaces/  tasks/  savings/  special_dates/  trips/  memories/  comments/  home/  settings/  search/
      data/          sumber data + repository
      domain/        model (freezed)
      presentation/  layar dan widget
```

Widget tidak memanggil API langsung; selalu lewat repository.

## Data offline (aturan wajib)

- UI selalu membaca dari drift. Jaringan hanya mengisi drift.
- Tulis: ubah drift dulu (UI langsung berubah), lalu masukkan operasi ke antrean. Hanya PUT/PATCH/DELETE untuk daftar, tugas, target, setoran, tanggal penting, perjalanan, kenangan, foto kenangan, dan komentar, PUT/DELETE untuk reaksi, unggah foto kenangan (`POST /memory-photos/{id}`), dan `PATCH /me` yang lewat antrean; endpoint lain (termasuk `GET /memories/{id}/photos`, `GET /places`, `DELETE /spaces/{id}`, dan `DELETE /me`) dipanggil langsung dan butuh koneksi.
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
- `parent_deleted`/`parent_archived` untuk tugas: pindahkan ke daftar aktif pertama di ruang itu (bukan checklist perjalanan), lalu kirim ulang.
- Foto kenangan: `POST` multipart masuk antrean setelah `PUT` kenangannya. Foto dikecilkan ke sisi terpanjang 2560 px (JPEG mutu 85, tanpa EXIF dan lokasi), `taken_at` dibaca dari EXIF foto asli, dan berkasnya disimpan di folder app per akun (`foto_kenangan/akun_{id}`) sampai server membalas, lalu dipindah ke cache versi penuh. Berkas yang hilang membuat operasinya dibuang. Hapus kenangan berfoto membatalkan unggahan yang belum pernah dikirim. Hapus foto memakai jeda Urungkan 5 detik seperti hapus tugas; hapus kenangan tanpa foto juga.
- Tugas berulang: balasan `PUT` dan `PATCH /tasks/{id}` berbentuk `{"data": {...}, "next_task": {...}}`; `next_task` diterapkan seperti baris sync. Kalau balasan centang batal membawa `next_task_id` kosong padahal sebelumnya terisi, tugas berikutnya itu dihapus dari cache, kecuali masih punya operasi di antrean. `repeat_frequency` dan `repeat_interval` selalu dikirim berdua, dan mengosongkan `due_date` ikut mengirim keduanya kosong.
- Checklist perjalanan: dibuat lewat `PUT /lists/{id}` dengan `trip_id` tepat setelah perjalanannya, tidak pernah dihapus atau diarsipkan sendiri, dan tidak dihitung daftar aktif. Hapus perjalanan hanya mengirim `DELETE /trips/{id}`; checklist dan isinya cukup ditandai terhapus di HP. Mengubah judul perjalanan ikut mengganti nama checklistnya ("Persiapan {judul}").

### Sync

- Satu sync pada satu waktu. Kirim dulu operasi yang bisa dikirim, lalu tetap tarik data.
- Halaman pertama `GET /sync?since=...`; berikutnya `?cursor=<next_cursor>` sampai `has_more` false. Simpan `server_time` dari halaman terakhir.
- Sync penuh (tanpa `since`) hanya saat database lokal akun itu masih kosong, atau sekali setelah app mengenal koleksi baru (`SyncEngine.collectionsVersion`; v0.2: `special_dates`, lalu `trips` beserta `trip_id` di daftar dan jadwal setor di target; v0.3: `memories` dan `memory_photos`; v1.0: aturan ulang dan `next_task_id` di `tasks`; v1.x: `latitude` dan `longitude` di `memories`, lalu `comments` dan `reactions`); sifatnya hanya menambah dan memperbarui.
- Pengiriman antrean sebelum menarik data dibatasi 8 detik (`SyncEngine.flushLimit`), supaya unggahan foto yang lama tidak menahan data baru; antreannya tetap jalan di belakang.
- Foto kenangan: cache gambar memakai kunci `photo-{id}` dan `photo-{id}-thumb`, bukan URL. Thumbnail yang belum ada diunduh setelah setiap sync yang berhasil; versi penuh saat foto dibuka. URL yang berumur 7 hari, atau yang ditolak R2 dengan 403, diganti lewat `GET /memories/{id}/photos`.
- Saat menerapkan baris: tanpa foreign key check; kolom dengan operasi tertunda tidak ditimpa; baris dengan DELETE tertunda tidak muncul lagi; baris yang lebih tua dari salinan lokal diabaikan.
- Induk tiba terhapus: hapus anak lokalnya, kecuali anak yang masih punya operasi tertunda. Anaknya didaftar di `EntityType.children`: komentar dan reaksi menunjuk tugas, setoran, atau kenangan lewat `subject_id`. Ruang Bersama yang tiba tertutup (v1.0) adalah induk dari semua isinya (`EntityType.spaceContent`, lewat `space_id`).
- Pemicu: app dibuka atau kembali aktif, tarik untuk menyegarkan, push yang masuk saat app terbuka, dan setiap 30 detik selama app tampil di layar (`liveSyncInterval`, berhenti saat app tidak tampil). Push tanpa judul dan isi (termasuk `type` `sync`) hanya memicu sync, tanpa notifikasi.

### Notifikasi

- Dua channel Android: `pengingat` (penting, bersuara: tenggat tugas, tanggal penting, perjalanan, dan hari setor) dan `aktivitas` (normal), dibuat saat app pertama dibuka.
- Minta izin notifikasi (Android 13+) dengan penjelasan; sebelum Android 13 layarnya dilewati. Panduan mematikan optimasi baterai tidak ditampilkan (keputusan pemilik, 23 Oktober 2026): langkah manual di Pengaturan HP terlalu merepotkan untuk alur pertama kali.
- Ketuk notifikasi: sync paling lama 3 detik, lalu buka layar sesuai `type`; kalau data belum ada, buka layar induk dengan pesan singkat. Pengingat tanggal penting membuka Beranda, pengingat perjalanan membuka Detail perjalanan, pengingat setor membuka Detail target, `memory_created` membuka Detail kenangan, dan `partner_left` (v1.0) membuka Beranda setelah sync.

## Keamanan

Diaudit 24–25 Oktober 2026. Aturan yang harus tetap berlaku:

- Android: `allowBackup` mati dan `data_extraction_rules.xml` mengecualikan semua data dari backup cloud dan salinan saat pindah HP (data ada di server; token terenkripsi tidak bisa dibuka di HP lain). Deep link Flutter dimatikan (`flutter_deeplinking_enabled`), karena app tidak memakainya dan app lain bisa membuka layar mana pun lewat intent. `MainActivity` memakai `taskAffinity=""`.
- Klien API tidak mengikuti pengalihan (redirect), supaya token tidak pernah terkirim ke alamat lain, dan build rilis menolak `API_BASE_URL` yang bukan HTTPS (`apiBaseUrlProblem` di `lib/core/config/env.dart`).
- ID dari server atau penyimpanan hanya dipakai sebagai nama berkas atau database kalau berbentuk ULID (`ulidPattern`): folder dan berkas foto, dan database akun.
- Penyimpanan aman yang tidak bisa dibaca saat app dibuka berarti belum masuk, bukan app gagal dibuka.
- Keluar: token yang tidak sempat dicabut karena offline disimpan di penyimpanan aman lalu dicabut dengan token itu sendiri saat app dibuka atau kembali aktif (`TokenRevocations`). Hapus akun (v1.0) menghapus juga berkas database akun dan folder fotonya setelah databasenya tertutup (`Account.closed`). Cache foto kenangan dan foto profil dikosongkan.
- Salinan sementara foto dari image_picker dan image_cropper (dari kamera masih membawa lokasi) dihapus setelah diproses atau saat batal dipilih, dan hanya kalau letaknya di folder cache app.
- Tidak ada rahasia di repo: kunci rilis dan kata sandinya di luar git; kunci Firebase di `google-services.json` memang publik.
- Cek paket Dart setiap ada kabar kerentanan: `dart run tool/cek_kerentanan.dart` (OSV). SDK Flutter dan Dart dipantau terpisah lewat advisory resminya.

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
- Ujung ke ujung (`test/e2e/`): hanya jalan kalau `E2E_API_URL` diisi, dan hanya ke API lokal dengan database khusus tes. Caranya ada di kepala filenya. Fitur atau layar baru ditambahkan juga ke `ui_e2e_test.dart`. Tes itu jauh lebih rapat dari pemakaian sungguhan dan dekat batas server 120 request per menit per akun, jadi bagian Kenangan dan langkah sync berkala menunggu 61 detik dulu (`coolDown`). Langkah pin lokasi memasang pin dengan mengetuk peta, tanpa `GET /places`, supaya tes tidak sampai ke Nominatim. Foto kenangan tidak diunggah di sana (API lokal tanpa kunci R2), dan jangan diarahkan ke R2 sungguhan.
- Foto di tes memakai `test/helpers/fake_photos.dart` (cache, berkas tunggu unggah, dan galeri palsu); `pumpApp(photoPicker: ...)` mengganti galeri HP.
- Hapus akun di tes tidak menyentuh berkas sungguhan: `pumpApp(accountFiles: ...)` memakai `FakeAccountFiles`, yang mencatat akun mana yang berkasnya dihapus.
- Masuk dengan Google di tes memakai `test/helpers/fake_google.dart`; `pumpApp(google: ...)` mengganti pilihan akun Google. Zona waktu HP di `pumpApp` selalu tidak terbaca (kanal `flutter_timezone` dibalas error), supaya daftar dan masuk dengan Google tidak menunggu kanal yang tidak pernah menjawab.

## Git

- Kerja di branch (`feat/...`, `fix/...`), lalu merge ke `main`. Commit kecil dengan awalan `feat:`, `fix:`, `chore:`, `test:`, atau `docs:`.

## Jangan

- Jangan menyimpan token di SharedPreferences.
- Jangan mengubah bentuk JSON atau aturan antrean/sync tanpa memperbarui `docs/kontrak-api.md`.
- Jangan menambah package baru tanpa alasan yang jelas; pakai yang sudah ada di Stack.
- Jangan menyalin desain aplikasi lain persis; ikuti mockup, token, dan prinsip di file ini.
