# Daftar layar v0.1

Mockup ada di `docs/mockup/*.dc.html`, satu file per layar berukuran 390 × 844 (1 px = 1 dp). File ini berasal dari kanvas desain di claude.ai dan membutuhkan `support.js` yang tidak disertakan, jadi tidak tampil benar di browser; baca sebagai teks. Teks, ukuran, jarak, dan radius tertulis langsung di atribut `style`.

- `{{t.xxx}}` adalah token warna; daftar dan nilainya ada di `.claude/rules/tema.md`. `{{t.p2}}` = warna diri pasangan, `{{t.sw1}}` sampai `{{t.sw3}}` = warna daftar contoh.
- `{{...}}` lainnya dan isi `<script>` adalah data contoh dan interaksi kanvas, bukan logika app.
- Layar yang belum punya mockup mengikuti pola yang sama.

## Navigasi

- Tab bawah v0.1: Beranda, Tugas, Tabungan. Mockup menampilkan lima tab; Liburan (v0.2) dan Kenangan (v0.3) disembunyikan sampai rilisnya (keputusan ini masih bisa diubah).
- Pengaturan dibuka dari avatar di kanan atas Beranda.
- Tombol + mengambang di Beranda dan Tugas membuka lembar Tambah tugas.
- Alur pertama kali: Masuk atau Daftar → Izin notifikasi → Ajak pasangan (bisa "Nanti saja") → Beranda.
- Usulan route go_router: `/masuk`, `/daftar`, `/izin-notifikasi`, `/beranda`, `/tugas`, `/tugas/:id`, `/tabungan`, `/tabungan/:id`, `/pengaturan`, `/pengaturan/profil`, `/ajak-pasangan`.

## Layar dengan mockup

### Beranda — `Main.dc.html`

- Kepala: tanggal ("Kamis, 8 Oktober"), sapaan sesuai waktu ("Selamat sore!"), avatar kamu dan pasangan bertumpuk; ketuk avatar → Pengaturan.
- Kartu "Tugas hari ini": progres "1 dari 3 beres" dengan bar; chip Semua / Aku / Pasangan; tugas hari ini termasuk yang terlewat; "Lihat semua" → Tugas.
  - Baris tugas: tombol centang, judul, keterangan ("Terlewat · kemarin" dengan warna warn, "Hari ini, 17.00 · Belanja"), chip penanggung jawab Aku / Pasangan / Kita dengan titik warna.
  - Tugas yang selesai dicoret, dengan keterangan "Diselesaikan Pasangan, 12.40".
- Kartu "Tabungan": target utama, persen, bar, "Rp6.500.000 dari Rp10.000.000"; ketuk → detail target.
- Kartu "Tanggal penting" dan "Persiapan liburan" milik v0.2: tidak ditampilkan di v0.1.
- Kosong: "Belum ada tugas hari ini. Santai dulu, atau tambah yang baru." Semua beres: "Beres semua! Hari ini kalian keren."

### Tugas — `Tugas.dc.html`

- Kepala "Tugas" dengan tombol buat daftar baru.
- Chip status: Semua tugas / Belum selesai / Selesai. Chip orang: Semua orang / Aku / Pasangan.
- Tugas dikelompokkan per daftar: nama daftar dengan titik warna, label ruang dan jumlah ("Bersama · 3", atau ikon gembok "Pribadi · 1").
- Baris tugas: tombol centang 44 dp, judul, keterangan tenggat ("Hari ini, 17.00", "Tanpa tenggat", "Jum, 10 Okt · Penting"), chip penanggung jawab (tidak tampil di Ruang Pribadi).
- Tugas selesai dilipat di bawah, dibuka lewat tombol "Selesai (3)".
- Ketuk baris → Detail tugas. Centang → animasi, getar halus, dan snackbar Urungkan selama 5 detik.

### Tambah tugas — `TambahTugas.dc.html` (lembar bawah)

- Judul "Tugas baru" dan tombol tutup.
- "Mau mengerjakan apa?" — satu-satunya isian wajib; keyboard langsung terbuka.
- "Kapan?": chip Hari ini / Besok / Pilih tanggal, lalu chip jam (misalnya 17.00) atau "Tanpa jam".
- "Siapa?": Aku / Pasangan / Kita. Pasangan dan Kita hanya ada di Ruang Bersama; memilihnya memindahkan pilihan daftar ke Ruang Bersama.
- Pilihan daftar: nama daftar dengan keterangan "Daftar bersama" atau "Daftar pribadi".
- Switch "Tandai penting" = `priority` 3; mati = 0. Prioritas 1 dan 2 belum dipakai di UI v0.1.
- Simpan: tugas langsung tampil sebelum server membalas.

### Detail tabungan — `Tabungan.dc.html`

- Kepala: kembali, nama target, menu opsi (ubah, arsipkan, hapus).
- Ringkasan: cincin progres "65% terkumpul", "Rp6.500.000 dari Rp10.000.000", "Sisa Rp3.500.000", "Target 28 Feb 2027", dan "Perlu Rp175.000 per minggu" (hanya kalau ada `target_date`).
- Switch "Ingatkan setor tiap Jumat" milik v0.2: tidak ditampilkan di v0.1.
- Tombol "Setor" → lembar setor: nominal dengan keyboard angka dan format Rp otomatis, tanggal (bawaan hari ini), catatan opsional.
- "Setoran per bulan": grafik batang (fl_chart).
- "Riwayat tabungan": siapa dan catatan, tanggal, nominal "+Rp200.000"; ketuk → ubah atau hapus setoran.
- Target tercapai: perayaan kecil, teks "Dana Liburan tercapai. Selamat, kalian berhasil!"

### Ajak pasangan — `Pairing.dc.html`

- Judul "Pakai berdua, lebih ringan" dan penjelasan bahwa kode berlaku 48 jam dan sekali pakai.
- "Kode undanganmu": enam kotak karakter dan tombol Salin; tombol "Bagikan lewat WhatsApp" (share_plus).
- Pemisah "atau", lalu "Punya kode dari pasangan?" dengan isian 6 karakter huruf besar dan tombol "Gabung".
- "Nanti saja" → Beranda.
- Kode diambil dari `POST /invitations` (atau `invitation` di `GET /me`). Setelah berhasil gabung: sync, lalu Beranda.
- Kalau sudah berpasangan, layar ini menampilkan Ruang Bersama dan kedua anggotanya, bukan kode.

### Pengaturan — `Pengaturan.dc.html`

- Akun dan ruang: Profil (avatar dengan ikon kamera → Profil), Ruang Bersama ("Kamu dan pasangan · 2 anggota" → Ajak pasangan). Baris Tanggal penting milik v0.2: tidak ditampilkan.
- Tema: kartu Mawar (Palet C·D·I) dan Anggrek (Palet H·G·E); segmen Terang / Gelap / Ikuti sistem. Perubahan langsung terlihat.
- Notifikasi: tiga switch yang memetakan `notification_prefs`:
  - Pengingat tugas — saat tenggat tiba (`task_reminders`)
  - Aktivitas pasangan — titipan baru dan tugas selesai (`partner_activity`)
  - Setoran tabungan — setoran baru dan target tercapai (`savings_activity`)
- Lainnya: Mata uang ("Rupiah (IDR)"), Backup dan ekspor ("Tersimpan otomatis di server · ekspor di v1.0").
- Keluar (belum ada di mockup): tombol di paling bawah; peringatkan kalau masih ada perubahan yang belum terkirim.

### Profil — `Profil.dc.html`

- Avatar 112 dp dengan tombol kamera; tombol Kamera dan Galeri; catatan "Foto dipotong persegi dan hanya terlihat oleh anggota Ruang Bersama."
- Nama panggilan (isian), Email (hanya dibaca), Tanggal lahir (pemilih tanggal, tahun boleh kosong) dengan keterangan "Dipakai untuk pengingat ulang tahun. Tahun lahir boleh dikosongkan."
- Warna diri: enam lingkaran `mawar`, `ungu`, `toska`, `bata`, `biru`, `lavender`.
- Simpan.

### Tanggal penting — `TanggalPenting.dc.html`

- Milik v0.2. Hanya referensi; jangan dibangun dulu.

## Layar tanpa mockup

- **Masuk dan Daftar:** email, kata sandi (minimal 8 karakter), dan nama panggilan saat daftar; tautan untuk pindah di antara keduanya. Error diambil dari `message` balasan API.
- **Izin notifikasi:** alasan singkat kenapa notifikasi penting, tombol minta izin (Android 13+), lalu panduan mematikan optimasi baterai sesuai merek HP (Xiaomi, Oppo, Vivo, Realme). Bisa dilewati.
- **Detail tugas:** judul, catatan, tenggat (tanggal dan jam opsional), switch penting, penanggung jawab, pindah daftar (hanya daftar di ruang yang sama), dan hapus. Tersimpan otomatis tanpa tombol Simpan.
- **Kelola daftar:** buat atau ubah nama, emoji, dan warna (enam pilihan); urutkan; arsipkan; hapus dengan konfirmasi "Hapus daftar Belanja? 12 tugas di dalamnya ikut terhapus."
- **Tab Tabungan:** kartu untuk setiap target beserta progresnya; tombol tambah target (nama, emoji, nominal, mata uang, tanggal target opsional).
- **Offline:** banner kecil "Sedang offline. Perubahanmu aman dan dikirim saat online."
