# Daftar layar v0.1 dan v0.2

Mockup ada di `docs/mockup/*.dc.html`, satu file per layar berukuran 390 × 844 (1 px = 1 dp). File ini berasal dari kanvas desain di claude.ai dan membutuhkan `support.js` yang tidak disertakan, jadi tidak tampil benar di browser; baca sebagai teks. Teks, ukuran, jarak, dan radius tertulis langsung di atribut `style`.

- `{{t.xxx}}` adalah token warna; daftar dan nilainya ada di `.claude/rules/tema.md`. `{{t.p2}}` = warna diri pasangan, `{{t.sw1}}` sampai `{{t.sw3}}` = warna daftar contoh.
- `{{...}}` lainnya dan isi `<script>` adalah data contoh dan interaksi kanvas, bukan logika app.
- Layar yang belum punya mockup mengikuti pola yang sama.

## Navigasi

- Tab bawah: Beranda, Tugas, Tabungan, dan Liburan (v0.2). Mockup menampilkan lima tab; Kenangan (v0.3) disembunyikan sampai rilisnya.
- Pengaturan dibuka dari avatar di kanan atas Beranda.
- Tombol + mengambang di Beranda dan Tugas membuka lembar Tambah tugas. Tab Tabungan dan Liburan memakai tombol + di kepala layarnya.
- Alur pertama kali: Masuk atau Daftar → Izin notifikasi → Ajak pasangan (bisa "Nanti saja") → Beranda.
- Route go_router: `/masuk`, `/daftar`, `/izin-notifikasi`, `/beranda`, `/tugas`, `/tugas/:id`, `/tabungan`, `/tabungan/:id`, `/pengaturan`, `/pengaturan/profil`, `/pengaturan/tanggal-penting` (v0.2), `/ajak-pasangan`, dan untuk Liburan (v0.2) `/liburan`, `/liburan/:id`, `/liburan/:id/persiapan`, `/liburan/:id/persiapan/:tugas`, `/liburan/:id/tugas/:tugas`, `/liburan/:id/tabungan/:target`. Detail tugas dan detail target yang dibuka dari perjalanan tetap di tab Liburan dan kembali ke sana.

## Layar dengan mockup

### Beranda — `Main.dc.html`

- Kepala: tanggal ("Kamis, 8 Oktober"), sapaan sesuai waktu ("Selamat sore!"), avatar kamu dan pasangan bertumpuk; ketuk avatar → Pengaturan.
- Kartu "Tugas hari ini": progres "1 dari 3 beres" dengan bar; chip Semua / Aku / Pasangan; tugas hari ini termasuk yang terlewat; "Lihat semua" → Tugas.
  - Baris tugas: tombol centang, judul, keterangan ("Terlewat · kemarin" dengan warna warn, "Hari ini, 17.00 · Belanja"), chip penanggung jawab Aku / Pasangan / Kita dengan titik warna.
  - Tugas yang selesai dicoret, dengan keterangan "Diselesaikan Pasangan, 12.40".
  - Item checklist perjalanan yang bertenggat ikut tampil, dengan nama checklistnya: "Hari ini · Persiapan Liburan ke Bali".
- Kartu "Tabungan": target utama, persen, bar, "Rp6.500.000 dari Rp10.000.000"; ketuk → detail target.
- Dua kartu kecil berdampingan (v0.2), sama tinggi, seperti di mockup (tanpa label "v0.2"): ikon, satu baris besar 20 Bold, dan keterangan. Seluruh kartu satu tombol bagi pembaca layar ("Tanggal penting: …", "Persiapan liburan: …"). Judul yang sangat panjang dipotong (3 baris, keterangan 2 baris); pembaca layar tetap membacakan teks lengkapnya.
  - Tanggal penting: tanggal terdekat dengan hitung mundur ("12 hari lagi", "Besok", "Hari ini") dan keterangan "Hari jadi kita ke-3 · Sel, 20 Okt"; ketuk → Tanggal penting. Di hari H isinya ucapan "Hari jadi kita ke-3. Selamat!". Kosong: "Tambah tanggal" · "Hari jadi dan ulang tahun", ketuk → lembar Tanggal baru.
  - Persiapan liburan: perjalanan yang sedang berlangsung atau paling dekat berangkat, lalu yang tanggalnya belum pasti. "7 dari 12" dan "Persiapan Liburan ke Bali"; kalau checklistnya masih kosong, hitung mundurnya ("12 hari lagi") dan judulnya. Ketuk → Detail perjalanan. Kosong: "Rencanakan liburan" · "Buat perjalanan dan checklistnya", ketuk → lembar Perjalanan baru.
- Kosong: "Belum ada tugas hari ini. Santai dulu, atau tambah yang baru." Semua beres: "Beres semua! Hari ini kalian keren."

### Tugas — `Tugas.dc.html`

- Kepala "Tugas" dengan tombol buat daftar baru.
- Chip status: Semua tugas / Belum selesai / Selesai. Chip orang: Semua orang / Aku / Pasangan.
- Tugas dikelompokkan per daftar: nama daftar dengan titik warna, label ruang dan jumlah ("Bersama · 3", atau ikon gembok "Pribadi · 1").
- Baris tugas: tombol centang 44 dp, judul, keterangan tenggat ("Hari ini, 17.00", "Tanpa tenggat", "Jum, 10 Okt · Penting"), chip penanggung jawab (tidak tampil di Ruang Pribadi).
- Tugas selesai dilipat di bawah, dibuka lewat tombol "Selesai (3)".
- Ketuk baris → Detail tugas. Centang → animasi, getar halus, dan snackbar Urungkan selama 5 detik.
- Checklist perjalanan dan isinya tidak tampil di sini; tempatnya di tab Liburan.

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
- Baris pengingat setor (v0.2) di bawah ringkasan, dengan ikon lonceng dan switch: "Ingatkan setor tiap Jumat" atau "Ingatkan setor tiap tanggal 25", keterangan "Pukul 08.00, ke kalian berdua" (Ruang Pribadi: "Pukul 08.00"). Mati: "Ingatkan setor" · "Mingguan atau bulanan, pukul 08.00". Ketuk baris atau nyalakan switch → lembar Pengingat setor; matikan switch → jadwalnya dikosongkan. Tidak tampil untuk target yang sudah tercapai atau diarsipkan. Kalau `savings_reminders` mati: "Pengingat setor sedang dimatikan di Pengaturan."
- Lembar Pengingat setor (tanpa mockup): "Seberapa sering?" Mingguan / Bulanan; "Hari apa?" chip Sen sampai Min, atau "Tanggal berapa?" Tanggal 1–31 dengan keterangan untuk 29–31 ("Di bulan yang lebih pendek, pengingat dikirim di hari terakhir bulan itu."); catatan "Dikirim pukul 08.00 ke kalian berdua selama target belum tercapai."; "Matikan pengingat" kalau sudah menyala; Simpan. Pilihan bawaannya hari ini.
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

- Akun dan ruang: Profil (avatar dengan ikon kamera → Profil), Ruang Bersama ("Kamu dan pasangan · 2 anggota" → Ajak pasangan), Tanggal penting ("Ulang tahun dan anniversary" → Tanggal penting, v0.2).
- Tema: kartu Mawar (Palet C·D·I) dan Anggrek (Palet H·G·E); segmen Terang / Gelap / Ikuti sistem. Perubahan langsung terlihat.
- Notifikasi: switch yang memetakan `notification_prefs`:
  - Pengingat tugas — saat tenggat tiba (`task_reminders`)
  - Aktivitas pasangan — titipan baru dan tugas selesai (`partner_activity`)
  - Setoran tabungan — setoran baru dan target tercapai (`savings_activity`)
  - Tanggal penting — H-7, H-1, dan hari H pukul 08.00 (`special_dates`, v0.2)
  - Pengingat perjalanan — H-7 dan H-1 pukul 08.00 (`trip_reminders`, v0.2)
  - Pengingat setor — Hari setor yang dipilih di target, pukul 08.00 (`savings_reminders`, v0.2)
- Lainnya: Mata uang ("Rupiah (IDR)"), Backup dan ekspor ("Tersimpan otomatis di server · ekspor di v1.0").
- Keluar (belum ada di mockup): tombol di paling bawah; peringatkan kalau masih ada perubahan yang belum terkirim.

### Profil — `Profil.dc.html`

- Avatar 112 dp dengan tombol kamera; tombol Kamera dan Galeri; catatan "Foto dipotong persegi dan hanya terlihat oleh anggota Ruang Bersama."
- Nama panggilan (isian), Email (hanya dibaca), Tanggal lahir (pemilih tanggal, tahun boleh kosong) dengan keterangan "Dipakai untuk pengingat ulang tahun. Tahun lahir boleh dikosongkan."
- Warna diri: enam lingkaran `mawar`, `ungu`, `toska`, `bata`, `biru`, `lavender`.
- Simpan.

### Tanggal penting — `TanggalPenting.dc.html`

- v0.2. Dibuka dari Pengaturan dan dari kartu Beranda.
- Kartu "Bersama sejak 20 Okt 2023", "1.084 hari", dan "Hari jadi kita ke-3 tinggal 12 hari lagi": dari hari jadi tertua yang tahunnya diisi, yang di Ruang Bersama didahulukan. Tidak tampil kalau belum ada.
- "Akan datang": tanggal penting dan ulang tahun anggota dari profil, urut dari yang terdekat. Baris: ikon jenis (hati untuk anniversary, kado untuk ulang tahun, kalender untuk Lainnya; ulang tahun anggota memakai warna dirinya), nama ditambah "ke-N" kalau tahunnya diisi ("Hari jadi kita ke-3", "Ulang tahun Sari ke-27", "Ulang tahunmu"), keterangan "Sel, 20 Okt · Ruang Bersama" atau "Sel, 1 Des · ikon gembok Pribadi, untuk kejutan", dan hitung mundur "12 hari", "Besok", atau "Hari ini".
- Ketuk tanggal penting → lembar Ubah tanggal; ketuk ulang tahunmu → Profil; ulang tahun pasangan tidak bisa diubah di sini.
- Tanggal lahir sendiri belum diisi: kartu "Tanggal lahirmu belum diisi · Isi di Profil supaya pasanganmu diingatkan" → Profil.
- "Pengingat": switch "Kirim pengingat" (H-7, H-1, dan hari H pukul 08.00) yang sama dengan switch Tanggal penting di Pengaturan, ditambah catatan bahwa ulang tahun kalian hanya diingatkan ke pasangan. Pilihan H-30 dan "Jam kirim" di mockup tidak dibangun, karena jadwalnya tetap di v0.2 (lihat kontrak).
- Catatan "Simpan di Ruang Pribadi kalau ingin menyiapkan kejutan; pasanganmu tidak akan melihatnya." (hanya kalau sudah berpasangan), lalu tombol utama "Tambah tanggal" di bawah.
- Lembar Tanggal baru / Ubah tanggal (tanpa mockup): "Jenis apa?" chip Ulang tahun / Anniversary / Lainnya; "Apa namanya?" (1–50 karakter, contoh sesuai jenis); "Kapan?" pemilih tanggal dengan tahun boleh kosong; "Simpan di mana?" Bersama / Pribadi saat dibuat dan sudah berpasangan (ruang tidak bisa diubah sesudahnya); "Hapus tanggal" dengan konfirmasi saat mengubah.

### Liburan (v0.2) — tanpa mockup selain tab dan kartu Beranda

- Status perjalanan dihitung di HP dari tanggal lokal ruangnya (kontrak, bagian Perjalanan): direncanakan, berlangsung, atau selesai. Selalu ditulis dengan ikon: "12 hari lagi", "Besok berangkat", "Hari ke-2 dari 6", "Sedang berlangsung" (perjalanan sehari), "Tanggal belum pasti", atau "Selesai".
- **Daftar perjalanan** (tab Liburan): kepala "Liburan" dengan tombol + (Buat perjalanan). Kartu per perjalanan: judul, status, tanggal dan tujuan ("20–25 Jun 2027 · 6 hari · Bali"), progres persiapan "7 dari 12 beres" dengan bar dan persen (atau "Belum ada persiapan"), dan gembok "Pribadi". Urutannya: yang berlangsung, yang paling dekat berangkat, lalu yang tanggalnya belum pasti (terbaru dulu); yang sudah selesai dilipat di "Sudah selesai (N)". Kosong: ajakan "Buat perjalanan". Di bawah: "Pengingat" dengan switch "Ingatkan sebelum berangkat" (H-7 dan H-1 pukul 08.00, dengan progres persiapan), sama dengan switch Pengingat perjalanan di Pengaturan.
- **Detail perjalanan:** kembali, judul, menu (Ubah, Hapus). Kartu ringkasan: lingkaran ikon status, hitung mundur 28 Bold, tanggal dan lamanya, tujuan, dan gembok Pribadi. "Persiapan" dengan "Lihat semua": progres, tiga item pertama yang belum beres (centang dengan Urungkan, ketuk → Detail tugas), lalu "N item lain belum beres" atau "Tambah persiapan" → Checklist persiapan; semuanya beres: "Persiapan beres semua. Selamat berlibur!"; kosong: ajakan "Tambah persiapan". "Dana" dengan "Ganti": progres target yang ditautkan, ketuk → Detail target; belum ditautkan: "Pilih target" (target di ruang yang sama dan belum diarsipkan, ditambah "Tanpa tabungan" untuk melepas) dan "Buat target" (lembar Target baru dengan ruang perjalanan dan nama "Dana Liburan ke Bali", lalu langsung ditautkan). "Catatan" kalau diisi. Hapus dengan konfirmasi "Hapus Liburan ke Bali? Checklist persiapannya (12 item) ikut terhapus."
- **Checklist persiapan:** kembali ke Detail perjalanan, judul "Persiapan" dan nama perjalanannya, kartu progres berisi item yang belum beres, dan "Selesai (N)" yang dilipat. Isian "Tambah persiapan" menempel di bawah layar: Enter menambah item dan keyboard tetap terbuka untuk item berikutnya; checklist kosong langsung siap diisi. Penanggung jawab bawaannya Aku, supaya mencatat banyak item tidak mengirim notifikasi titipan; diubah di Detail tugas. Ketuk item → Detail tugas, lalu kembali ke checklist.
- **Lembar Perjalanan baru / Ubah perjalanan:** "Apa nama perjalanannya?" (1–50 karakter), "Ke mana?" (opsional, paling banyak 100 karakter), "Kapan berangkat?" dan "Kapan pulang?" (pemilih tanggal; boleh kosong kalau belum pasti, tanggal pulang butuh tanggal berangkat dan tidak boleh sebelumnya; "Kosongkan tanggal"), "Catatan", dan "Simpan di mana?" Bersama / Pribadi saat dibuat dan sudah berpasangan. Perjalanan baru langsung membuka detailnya.

## Layar tanpa mockup

- **Masuk dan Daftar:** email, kata sandi (minimal 8 karakter), dan nama panggilan saat daftar; tautan untuk pindah di antara keduanya. Error diambil dari `message` balasan API.
- **Izin notifikasi:** alasan singkat kenapa notifikasi penting dan tombol minta izin (Android 13+). Bisa dilewati; sebelum Android 13 layarnya tidak tampil. Tanpa panduan optimasi baterai (lihat CLAUDE.md).
- **Detail tugas:** judul, catatan, tenggat (tanggal dan jam opsional), switch penting, penanggung jawab, pindah daftar (hanya daftar di ruang yang sama), dan hapus. Tersimpan otomatis tanpa tombol Simpan. Item checklist perjalanan tidak bisa dipindah ke daftar lain.
- **Kelola daftar:** buat atau ubah nama, emoji, dan warna (enam pilihan); urutkan; arsipkan; hapus dengan konfirmasi "Hapus daftar Belanja? 12 tugas di dalamnya ikut terhapus." Checklist perjalanan tidak tampil di sini; ia ikut terhapus bersama perjalanannya.
- **Tab Tabungan:** kartu untuk setiap target beserta progresnya; tombol tambah target (nama, emoji, nominal, mata uang, tanggal target opsional).
- **Offline:** banner kecil "Sedang offline. Perubahanmu aman dan dikirim saat online."
