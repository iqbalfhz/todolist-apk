# Daftar layar v0.1 sampai v1.0

Mockup ada di `docs/mockup/*.dc.html`, satu file per layar berukuran 390 × 844 (1 px = 1 dp). File ini berasal dari kanvas desain di claude.ai dan membutuhkan `support.js` yang tidak disertakan, jadi tidak tampil benar di browser; baca sebagai teks. Teks, ukuran, jarak, dan radius tertulis langsung di atribut `style`.

- `{{t.xxx}}` adalah token warna; daftar dan nilainya ada di `.claude/rules/tema.md`. `{{t.p2}}` = warna diri pasangan, `{{t.sw1}}` sampai `{{t.sw3}}` = warna daftar contoh.
- `{{...}}` lainnya dan isi `<script>` adalah data contoh dan interaksi kanvas, bukan logika app.
- Layar yang belum punya mockup mengikuti pola yang sama.

## Navigasi

- Tab bawah: Beranda, Tugas, Tabungan, Liburan (v0.2), dan Kenangan (v0.3), sama dengan lima tab di mockup.
- Pengaturan dibuka dari avatar di kanan atas Beranda.
- Tombol + mengambang di Beranda dan Tugas membuka lembar Tambah tugas. Tab Tabungan, Liburan, dan Kenangan memakai tombol + di kepala layarnya.
- Alur pertama kali: Masuk atau Daftar → Izin notifikasi → Ajak pasangan (bisa "Nanti saja") → Beranda.
- Route go_router: `/masuk`, `/daftar`, `/izin-notifikasi`, `/beranda`, `/tugas`, `/tugas/:id`, `/tabungan`, `/tabungan/:id`, `/pengaturan`, `/pengaturan/profil`, `/pengaturan/tanggal-penting` (v0.2), `/ajak-pasangan`, dan untuk Liburan (v0.2) `/liburan`, `/liburan/:id`, `/liburan/:id/persiapan`, `/liburan/:id/persiapan/:tugas`, `/liburan/:id/tugas/:tugas`, `/liburan/:id/tabungan/:target`, dan untuk Kenangan (v0.3) `/kenangan`, `/kenangan/baru` (`?perjalanan=:id` untuk "Simpan jadi kenangan"), `/kenangan/:id`, `/kenangan/:id/ubah`, serta `/kenangan/:id/foto/:foto` (Galeri, tanpa tab bawah). Detail tugas dan detail target yang dibuka dari perjalanan tetap di tab Liburan dan kembali ke sana.

## Layar dengan mockup

### Beranda — `Main.dc.html`

- Kepala: tanggal ("Kamis, 8 Oktober"), sapaan sesuai waktu ("Selamat sore!"), tombol ikon Cari (v1.x) → Cari, avatar kamu dan pasangan bertumpuk; ketuk avatar → Pengaturan.
- Kartu "Tugas hari ini": progres "1 dari 3 beres" dengan bar; chip Semua / Aku / Pasangan; tugas hari ini termasuk yang terlewat; "Lihat semua" → Tugas.
  - Baris tugas: tombol centang, judul, keterangan ("Terlewat · kemarin" dengan warna warn, "Hari ini, 17.00 · Belanja"), chip penanggung jawab Aku / Pasangan / Kita dengan titik warna.
  - Tugas yang selesai dicoret, dengan keterangan "Diselesaikan Pasangan, 12.40".
  - Item checklist perjalanan yang bertenggat ikut tampil, dengan nama checklistnya: "Hari ini · Persiapan Liburan ke Bali".
- Kartu "Setahun lalu, hari ini" (v1.x, tanpa mockup), di antara Tugas hari ini dan Tabungan, hanya di hari yang punya kenangan dengan tanggal dan bulan yang sama di tahun sebelumnya: sampul (kalau ada foto), ikon riwayat dan "Setahun lalu, hari ini" (atau "3 tahun lalu, hari ini"), judul, lalu "Rab, 8 Okt 2025 · Danau Toba". Ketuk → Detail kenangan. Paling banyak dua kartu, yang paling baru dulu; sisanya tautan "2 kenangan lain di tanggal ini" → Kenangan. Kenangan 29 Februari muncul di 28 Februari pada tahun yang bukan kabisat. "Hari ini" dihitung di zona waktu ruang, sama dengan Tugas hari ini.
- Kartu "Tabungan": target utama, persen, bar, "Rp6.500.000 dari Rp10.000.000"; ketuk → detail target.
- Dua kartu kecil berdampingan (v0.2), sama tinggi, seperti di mockup (tanpa label "v0.2"): ikon, satu baris besar 20 Bold, dan keterangan. Seluruh kartu satu tombol bagi pembaca layar ("Tanggal penting: …", "Persiapan liburan: …"). Judul yang sangat panjang dipotong (3 baris, keterangan 2 baris); pembaca layar tetap membacakan teks lengkapnya.
  - Tanggal penting: tanggal terdekat dengan hitung mundur ("12 hari lagi", "Besok", "Hari ini") dan keterangan "Hari jadi kita ke-3 · Sel, 20 Okt"; ketuk → Tanggal penting. Di hari H isinya ucapan "Hari jadi kita ke-3. Selamat!". Kosong: "Tambah tanggal" · "Hari jadi dan ulang tahun", ketuk → lembar Tanggal baru.
  - Persiapan liburan: perjalanan yang sedang berlangsung atau paling dekat berangkat, lalu yang tanggalnya belum pasti. "7 dari 12" dan "Persiapan Liburan ke Bali"; kalau checklistnya masih kosong, hitung mundurnya ("12 hari lagi") dan judulnya. Ketuk → Detail perjalanan. Kosong: "Rencanakan liburan" · "Buat perjalanan dan checklistnya", ketuk → lembar Perjalanan baru.
- Kosong: "Belum ada tugas hari ini. Santai dulu, atau tambah yang baru." Semua beres: "Beres semua! Hari ini kalian keren."

### Tugas — `Tugas.dc.html`

- Kepala "Tugas" dengan tombol buat daftar baru.
- Chip status: Semua tugas / Belum selesai / Selesai. Chip orang: Semua orang / Aku / Pasangan.
- Tugas dikelompokkan per daftar: nama daftar dengan titik warna, label ruang dan jumlah ("Bersama · 3", atau ikon gembok "Pribadi · 1").
- Baris tugas: tombol centang 44 dp, judul, keterangan tenggat ("Hari ini, 17.00", "Tanpa tenggat", "Jum, 10 Okt · Penting"), chip penanggung jawab (tidak tampil di Ruang Pribadi). Tugas berulang (v1.0) ditandai ikon ulang dan aturannya: "Hari ini · Tiap minggu".
- Tugas selesai dilipat di bawah, dibuka lewat tombol "Selesai (3)".
- Ketuk baris → Detail tugas. Centang → animasi, getar halus, dan snackbar Urungkan selama 5 detik. Untuk tugas berulang, snackbarnya "Tugas selesai. Yang berikutnya muncul setelah tersimpan di server.": tugas berikutnya dibuat server dan muncul begitu centangnya terkirim.
- Checklist perjalanan dan isinya tidak tampil di sini; tempatnya di tab Liburan.

### Tambah tugas — `TambahTugas.dc.html` (lembar bawah)

- Judul "Tugas baru" dan tombol tutup.
- "Mau mengerjakan apa?" — satu-satunya isian wajib; keyboard langsung terbuka.
- "Kapan?": chip Hari ini / Besok / Pilih tanggal, lalu chip jam (misalnya 17.00) atau "Tanpa jam", dan chip "Ulangi" (v1.0) yang membuka lembar Ulangi tugas. Jam dan Ulangi hanya ada selama tanggalnya terisi; mengosongkan tanggal ikut mengosongkan keduanya.
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
- Tombol "Ambil" (v1.x, tanpa mockup) di samping Setor, bergaris dengan ikon minus, hanya kalau total terkumpul lebih dari 0 → lembar "Ambil tabungan": "Berapa yang diambil?" dengan keterangan "Terkumpul Rp4.500.000, jadi paling banyak segitu yang bisa diambil.", tanggal, dan catatan ("Misalnya untuk tiket pesawat"). Nominal di atas yang terkumpul ditolak di layar: "Paling banyak Rp4.500.000, sebesar yang terkumpul." (server menerimanya, jadi layar ini yang mencegah). Mengubah penarikan: "Ubah penarikan", batasnya ditambah nominal penarikan itu sendiri; "Hapus penarikan" dengan konfirmasi "Hapus penarikan Rp350.000?". Jenisnya tidak bisa diubah: setoran tetap setoran.
- Total, persen, sisa, dan "Perlu ... per minggu" dihitung dari total bersih (setoran dikurangi penarikan). Total bisa negatif kalau dua HP menarik bersamaan saat offline ("−Rp600.000"); persennya tetap 0%.
- "Kontribusi" (tanpa mockup; hanya target di Ruang Bersama yang sudah punya setoran): satu bar yang dibagi warna diri masing-masing, lalu baris Aku dan Pasangan dengan titik warna, persen, dan nominal ("Aku · 60% · Rp3.000.000"), dan baris "Total" berisi jumlah terkumpul. Persennya selalu berjumlah 100; setoran yang dibulatkan ke 0% tampil "<1%". Pasangan yang belum menyetor tetap tampil dengan Rp0. Setoran dari akun yang sudah bukan anggota ruang digabung di baris "Anggota lain". Nominal tiap orang bersih (setorannya dikurangi penarikannya, v1.x), jadi bisa negatif ("−Rp1.000.000") kalau ia mengambil lebih dari yang ia setor; persennya hanya dibagi di antara yang positif.
- "Setoran per bulan": grafik batang (fl_chart), hanya setoran; penarikan tidak ikut.
- "Riwayat tabungan": siapa dan catatan, tanggal, nominal "+Rp200.000"; penarikan tertulis "Aku mengambil · catatan" dengan "−Rp350.000" (tanda minus U+2212). Ketuk → ubah atau hapus.
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
  - Aktivitas pasangan — titipan baru, tugas selesai, dan kenangan baru (`partner_activity`)
  - Setoran tabungan — setoran, penarikan (v1.x), dan target tercapai (`savings_activity`)
  - Tanggal penting — H-7, H-1, dan hari H pukul 08.00 (`special_dates`, v0.2)
  - Pengingat perjalanan — H-7 dan H-1 pukul 08.00 (`trip_reminders`, v0.2)
  - Pengingat setor — Hari setor yang dipilih di target, pukul 08.00 (`savings_reminders`, v0.2)
- Lainnya: Mata uang ("Rupiah (IDR)"), Widget di layar utama ("Tugas hari ini dan target tabungan utama", v1.x; ketuk → dialog Android untuk menyematkan widget, atau pesan "Tekan lama layar utama HP, pilih Widget, lalu cari Denly Days." kalau launcher tidak mendukungnya), Backup dan ekspor ("Tersimpan otomatis di server · ekspor di v1.0").
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
- **Perjalanan yang sudah selesai** (v0.3): kartunya di "Sudah selesai (N)" punya tombol "Simpan jadi kenangan", dan Detail perjalanannya menampilkan bagian "Kenangan" berisi kenangan dari perjalanan itu (judul, tanggal, jumlah foto; ketuk → Detail kenangan) dan tombol yang sama. Satu perjalanan boleh punya beberapa kenangan.
- **Lembar Perjalanan baru / Ubah perjalanan:** "Apa nama perjalanannya?" (1–50 karakter), "Ke mana?" (opsional, paling banyak 100 karakter), "Kapan berangkat?" dan "Kapan pulang?" (pemilih tanggal; boleh kosong kalau belum pasti, tanggal pulang butuh tanggal berangkat dan tidak boleh sebelumnya; "Kosongkan tanggal"), "Catatan", dan "Simpan di mana?" Bersama / Pribadi saat dibuat dan sudah berpasangan. Perjalanan baru langsung membuka detailnya.

### Kenangan (v0.3) — tanpa mockup selain tab

- **Linimasa** (tab Kenangan): kepala "Kenangan" dengan tombol peta (Peta kenangan, v1.x) dan tombol + (Kenangan baru). Dikelompokkan per tahun ("2027", dengan "3 kenangan" di kanan) lalu per bulan ("Juni") dari `visited_on`, terbaru dulu. Kartu: foto sampul 16:9 di atas (foto dengan `position` terkecil; kenangan tanpa foto tampil tanpa sampul), judul, "Min, 20 Jun 2027 · Ubud, Bali", jumlah foto ("7 foto" atau "Belum ada foto") dengan ikon, dan gembok "Pribadi". Ketuk → Detail kenangan. Kosong: ajakan "Kenangan baru".
- **Detail kenangan:** kembali, judul, menu (Ubah, Hapus). Sampul 4:3 (ketuk → Galeri), kartu berisi tanggal, tempat, "Dari perjalanan Pangandaran" (ketuk → Detail perjalanan), dan gembok Pribadi. Kalau berpin (v1.x): peta kecil 160 dp radius 20 yang tidak bisa digeser, dengan pinnya dan atribusi OSM; ketuk → Peta kenangan dengan kenangan ini terpilih. "Cerita" kalau diisi. "Foto" dengan jumlahnya: kisi tiga kolom persegi (ketuk → Galeri); foto yang belum terkirim diberi lingkaran ikon unggah ("Menunggu terkirim"), dan foto yang masih disiapkan tampil sebagai kotak skeleton dengan "Menyiapkan 3 foto". "Tambah foto" membuka galeri HP (paling banyak sisa dari 50 foto); foto yang tidak bisa dibaca diberi tahu lewat snackbar. Kosong: "Belum ada foto. Tambahkan dari galeri HP supaya kenangan ini lebih hidup." Hapus kenangan berfoto memakai konfirmasi "Hapus Liburan ke Bali? 7 fotonya ikut terhapus dan tidak bisa dikembalikan."; yang tanpa foto langsung dihapus dengan Urungkan 5 detik.
- **Galeri foto:** tanpa tab bawah. Kepala "3 dari 12" dengan menu (Jadikan sampul, kecuali foto pertama; Hapus foto dengan Urungkan 5 detik). Geser antarfoto, cubit untuk memperbesar; versi penuh diunduh saat foto dibuka. Di bawah: "Foto sampul", "Diambil Sab, 20 Jun 2027, 10.12" (jam di zona waktu ruang), dan "Menunggu terkirim".
- **Kenangan baru / Ubah kenangan** (layar penuh): "Mau dikenang sebagai apa?" (1–50 karakter), "Di mana?" (opsional, paling banyak 100), "Tepatnya di titik mana?" (v1.x, opsional: tombol "Pasang pin di peta" → Pilih lokasi; kalau sudah berpin, peta kecil dengan "Ubah pin" dan "Lepas pin"; keterangan "Opsional. Kenangan berpin tampil di Peta kenangan."), "Kapan?" (pemilih tanggal, bawaannya hari ini), "Ceritanya?" (opsional, paling banyak 10.000), "Fotonya?" (hanya saat dibuat: kisi foto terpilih dengan tombol batal pilih, "Pilih foto", dan keterangan bahwa foto dikecilkan dan lokasinya tidak ikut tersimpan), dan "Simpan di mana?" Bersama / Pribadi saat dibuat dan sudah berpasangan. Dari "Simpan jadi kenangan", judul, tempat (tujuan), dan tanggal (tanggal berangkat) sudah terisi, dan ruangnya ruang perjalanan itu. Setelah Simpan, Detail kenangan langsung terbuka dan fotonya muncul satu per satu sambil disiapkan. Pin dikirim bersama kenangan baru; saat mengubah, pin yang berubah dikirim sebagai `latitude` dan `longitude` berdua.
- **Pilih lokasi** (v1.x, layar penuh di atas formulir): kembali dan "Pilih lokasi"; kolom "Cari tempat, misalnya Ubud" dengan tombol ikon Cari. Pencarian (`GET /places`, butuh koneksi) hanya berjalan saat tombol Cari atau Enter ditekan, tidak sambil mengetik, karena kebijakan Nominatim melarang autocomplete. Hasil: kartu berisi nama dan alamat (paling banyak 8, bisa digulir), lalu "© OpenStreetMap contributors"; ketuk → pin pindah ke sana dan peta mendekat. Pesan: kurang dari 3 huruf "Ketik paling sedikit 3 huruf, lalu ketuk Cari.", tanpa hasil "Tidak ada tempat yang cocok dengan "ubud". Coba kata lain, atau ketuk peta.", 503 `places_unavailable` dan 422 memakai pesan server, 429 "Terlalu sering mencari...", offline "Mencari tempat butuh koneksi internet. Pin tetap bisa dipasang dengan mengetuk peta." Di bawahnya peta penuh (geser, cubit, tanpa memutar; Indonesia kalau belum ada pin) dengan petunjuk "Ketuk peta untuk memasang pin"; ketuk peta memasang atau memindah pin. Bawah: "Pakai titik ini" (aktif setelah ada pin) dan "Lepas pin" kalau sebelumnya sudah berpin; keduanya tersembunyi selama keyboard terbuka. Titik dari hasil pencarian mengisi "Di mana?" kalau isian itu masih kosong. Koordinat dibulatkan ke 6 desimal seperti di server.
- **Peta kenangan** (v1.x, `/kenangan/peta`, dengan tab bawah): kembali (ke Kenangan, atau ke Detail kenangan asalnya) dan "Peta kenangan", keterangan "12 kenangan berpin" atau "Belum ada kenangan berpin. Pasang pin lewat Ubah kenangan.", lalu peta penuh berisi pin semua kenangan (area sentuh 48 dp, label judul untuk pembaca layar). Kamera awal: kenangan yang dibuka dari Detail kenangan, satu-satunya pin, semua pin sekaligus, atau Indonesia. Ketuk pin → pin membesar dan kartu di bawah peta: judul, "Sab, 1 Agu · Pangandaran", dan "Buka kenangan" (ketuk → Detail kenangan); ketuk peta kosong menutup kartu.
- Semua peta memakai ubin OpenStreetMap lewat flutter_map dengan User-Agent app dan cache ubin di HP (paling banyak 200 MB), sesuai kebijakan tile OSM, dan selalu menampilkan "© OpenStreetMap contributors" di pojok kiri bawah. Pin berupa lingkaran `brand` bergaris `surface`; latar peta selama ubin belum tampil `track`.

## Layar tanpa mockup

- **Masuk dan Daftar:** email, kata sandi (minimal 8 karakter), dan nama panggilan saat daftar; tautan untuk pindah di antara keduanya. Error diambil dari `message` balasan API.
- **Izin notifikasi:** alasan singkat kenapa notifikasi penting dan tombol minta izin (Android 13+). Bisa dilewati; sebelum Android 13 layarnya tidak tampil. Tanpa panduan optimasi baterai (lihat CLAUDE.md).
- **Detail tugas:** judul, catatan, tenggat (tanggal dan jam opsional), switch penting, penanggung jawab, pindah daftar (hanya daftar di ruang yang sama), dan hapus. Tersimpan otomatis tanpa tombol Simpan. Item checklist perjalanan tidak bisa dipindah ke daftar lain. Chip "Ulangi" atau aturannya ("Tiap 2 minggu") ada di "Kapan?" selama tanggalnya terisi, kecuali di item checklist perjalanan dan tugas yang sudah selesai; "Hapus tenggat" ikut menghentikan pengulangan. Tugas berulang yang sudah selesai menampilkan aturannya dan "Tugas berikutnya: Kam, 15 Okt" (ketuk → tugas berikutnya).
- **Lembar Ulangi tugas** (v1.0): "Seberapa sering?" chip Tidak diulang / Harian / Mingguan / Bulanan / Tahunan; "Setiap berapa?" dengan tombol kurang dan tambah di kiri-kanan "Tiap 2 minggu" (1–99); keterangan bulan yang lebih pendek kalau tenggatnya tanggal 29–31 (bulanan) atau 29 Februari (tahunan); catatan "Begitu tugas ini selesai, tugas berikutnya dibuat dengan tenggat baru."; Simpan. Mingguan di beberapa hari sekaligus belum ada.
- **Kelola daftar:** buat atau ubah nama, emoji, dan warna (enam pilihan); urutkan; arsipkan; hapus dengan konfirmasi "Hapus daftar Belanja? 12 tugas di dalamnya ikut terhapus." Checklist perjalanan tidak tampil di sini; ia ikut terhapus bersama perjalanannya.
- **Cari** (v1.x, `/cari`, di luar tab bawah, dibuka dari kepala Beranda): tombol kembali dan kolom "Mau cari apa?" dengan ikon kaca pembesar dan tombol "Hapus kata kunci". Mencari di cache lokal, jadi jalan saat offline: tugas (judul dan catatan, termasuk item checklist perjalanan), target tabungan (nama), setoran (catatan), perjalanan (judul, tujuan, catatan), kenangan (judul, tempat, cerita), serta tanggal penting dan ulang tahun anggota. Huruf besar-kecil dan aksen diabaikan; setiap kata harus ada di data yang sama; paling sedikit 2 huruf. Hasil dikelompokkan dengan judul berikon dan jumlahnya ("Tugas · 3 hasil"), urutannya Tugas, Tabungan, Setoran, Liburan, Kenangan, Tanggal penting; judul yang diawali kata kunci di atas. Baris: judul dengan kata yang cocok ditebalkan berlatar `soft`, keterangan ("Belanja · Hari ini", "45% · Rp4.500.000 dari Rp10.000.000", "+Rp200.000 · Kam, 8 Okt · Dana Liburan", tujuan dan tanggal, tanggal dan tempat, "Sel, 20 Okt · 12 hari lagi"), lalu potongan catatan atau cerita kalau kata kuncinya tidak ada di judul. Paling banyak 5 baris per kelompok, sisanya "Tampilkan semua (12)". Ketuk → detail (tanggal penting → Tanggal penting). Kata kunci terakhir diingat selama app berjalan. Kosong: "Cari tugas, tabungan, setoran, liburan, kenangan, dan tanggal penting. Bisa juga saat offline." Tidak ketemu: "Belum ketemu "kata". Coba kata lain."
- **Tab Tabungan:** kartu untuk setiap target beserta progresnya; tombol tambah target (nama, emoji, nominal, mata uang, tanggal target opsional).
- **Widget "Tugas hari ini" di layar utama HP** (v1.x, Android, `TasksWidget.kt`): kartu radius 20 berwarna Mawar (gelap mengikuti HP). Kepala "Tugas hari ini" dan "3 belum beres"; baris tugas yang tenggatnya hari ini atau sudah terlewat (termasuk tugas pasangan dan item checklist, sama dengan Beranda), yang terlewat dulu, dengan keterangan "Terlewat" (warna `warn`) atau jamnya ("17.00"); banyaknya baris mengikuti tinggi widget (1–5), sisanya "+2 lainnya"; di bawah, target tabungan utama "✈️ Dana Liburan · 45%" tanpa nominal. Kosong: "Tidak ada tugas hari ini. Santai dulu." Belum masuk atau sudah keluar: "Masuk ke Denly Days untuk melihat tugas hari ini." Hanya untuk dilihat; ketuk di mana saja membuka app. App mengirim ringkasan (tugas belum selesai sampai 7 hari ke depan) setiap tugas atau tabungan berubah; widget menghitung "hari ini" sendiri di zona waktu ruang dan diperbarui paling jarang 30 menit sekali, jadi pergantian hari tetap benar walau app tidak dibuka. Perubahan dari pasangan baru sampai ke widget setelah app dibuka.
- **Offline:** banner kecil "Sedang offline. Perubahanmu aman dan dikirim saat online."
