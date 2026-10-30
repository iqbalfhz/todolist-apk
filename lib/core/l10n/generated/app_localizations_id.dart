// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonBack => 'Kembali';

  @override
  String get commonUndo => 'Urungkan';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonContinue => 'Lanjut';

  @override
  String get commonSkip => 'Lewati';

  @override
  String get commonLater => 'Nanti saja';

  @override
  String get commonSeeAll => 'Lihat semua';

  @override
  String get commonShowLess => 'Tampilkan lebih sedikit';

  @override
  String get commonEdit => 'Ubah';

  @override
  String get commonOptions => 'Opsi lainnya';

  @override
  String get commonOk => 'Oke';

  @override
  String get labelMe => 'Aku';

  @override
  String get labelPartner => 'Pasangan';

  @override
  String get labelUs => 'Kita';

  @override
  String get labelShared => 'Bersama';

  @override
  String get labelPersonal => 'Pribadi';

  @override
  String get navHome => 'Beranda';

  @override
  String get navTasks => 'Tugas';

  @override
  String get navSavings => 'Tabungan';

  @override
  String get navTrips => 'Liburan';

  @override
  String get navMemories => 'Kenangan';

  @override
  String get navLabel => 'Navigasi utama';

  @override
  String get commentsTitle => 'Komentar';

  @override
  String commentsCount(int count) {
    return '$count komentar';
  }

  @override
  String get commentsEmpty => 'Belum ada komentar. Tulis yang pertama.';

  @override
  String get commentHint => 'Tulis komentar…';

  @override
  String get commentSend => 'Kirim komentar';

  @override
  String get commentRequired => 'Komentarnya masih kosong.';

  @override
  String get commentTooLong => 'Komentar paling banyak 1.000 karakter.';

  @override
  String get commentEdited => 'diedit';

  @override
  String get commentOptions => 'Opsi komentar';

  @override
  String get commentEditTitle => 'Ubah komentar';

  @override
  String get commentDeleted => 'Komentar dihapus.';

  @override
  String get reactionAdd => 'Beri reaksi';

  @override
  String get reactionClose => 'Tutup pilihan reaksi';

  @override
  String reactionPick(String emoji) {
    return 'Reaksi $emoji';
  }

  @override
  String reactionBy(String emoji, String people) {
    return 'Reaksi $emoji dari $people';
  }

  @override
  String get listAnd => ' dan ';

  @override
  String conversationSummary(int reactions, int comments) {
    return '$reactions reaksi, $comments komentar';
  }

  @override
  String get entryDetailDeposit => 'Setoran';

  @override
  String get entryGone => 'Setoran ini sudah dihapus.';

  @override
  String get entryDetailWithdrawal => 'Penarikan';

  @override
  String get osmAttribution => '© OpenStreetMap contributors';

  @override
  String get memoryPinLabel => 'Tepatnya di titik mana?';

  @override
  String get memoryPinHelp => 'Opsional. Kenangan berpin tampil di Peta kenangan.';

  @override
  String get memoryPinAdd => 'Pasang pin di peta';

  @override
  String get memoryPinChange => 'Ubah pin';

  @override
  String get memoryPinRemove => 'Lepas pin';

  @override
  String get memoryPinPreview => 'Lokasi di peta. Ketuk untuk mengubah pin.';

  @override
  String get memoryMapPreview => 'Lokasi di peta. Ketuk untuk membuka Peta kenangan.';

  @override
  String get pickerTitle => 'Pilih lokasi';

  @override
  String get pickerSearchHint => 'Cari tempat, misalnya Ubud';

  @override
  String get pickerSearch => 'Cari tempat';

  @override
  String get pickerTapHint => 'Ketuk peta untuk memasang pin';

  @override
  String get pickerMapSemantic => 'Peta. Ketuk untuk memasang pin di titik itu.';

  @override
  String get pickerUse => 'Pakai titik ini';

  @override
  String pickerQueryShort(int count) {
    return 'Ketik paling sedikit $count huruf, lalu ketuk Cari.';
  }

  @override
  String pickerNoResults(String query) {
    return 'Tidak ada tempat yang cocok dengan \"$query\". Coba kata lain, atau ketuk peta.';
  }

  @override
  String get pickerOffline => 'Mencari tempat butuh koneksi internet. Pin tetap bisa dipasang dengan mengetuk peta.';

  @override
  String get pickerTooOften => 'Terlalu sering mencari. Coba lagi sebentar lagi, atau ketuk peta.';

  @override
  String get memoriesMapTitle => 'Peta kenangan';

  @override
  String get memoriesMapEmpty => 'Belum ada kenangan berpin. Pasang pin lewat Ubah kenangan.';

  @override
  String memoriesMapCount(int count) {
    return '$count kenangan berpin';
  }

  @override
  String get memoriesMapOpen => 'Buka kenangan';

  @override
  String get searchHint => 'Mau cari apa?';

  @override
  String get searchClear => 'Hapus kata kunci';

  @override
  String get searchIntro =>
      'Cari tugas, tabungan, setoran, liburan, kenangan, dan tanggal penting. Bisa juga saat offline.';

  @override
  String searchEmpty(String query) {
    return 'Belum ketemu \"$query\". Coba kata lain.';
  }

  @override
  String searchCount(int count) {
    return '$count hasil';
  }

  @override
  String searchShowAll(int count) {
    return 'Tampilkan semua ($count)';
  }

  @override
  String get searchSectionEntries => 'Setoran';

  @override
  String get offlineBanner => 'Sedang offline. Perubahanmu aman dan dikirim saat online.';

  @override
  String get updateBanner => 'Versi app ini sudah tertinggal. Perbarui app supaya perubahanmu terkirim.';

  @override
  String get needsConnection => 'Butuh koneksi internet. Coba lagi saat online.';

  @override
  String get genericError => 'Ada yang tidak beres. Coba lagi sebentar lagi.';

  @override
  String get sessionExpired => 'Sesi kamu sudah berakhir. Silakan masuk lagi.';

  @override
  String get loginTitle => 'Masuk';

  @override
  String get loginSubtitle => 'Senang melihatmu lagi.';

  @override
  String get registerTitle => 'Daftar';

  @override
  String get registerSubtitle => 'Buat akun untuk mulai mencatat berdua.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldEmailHint => 'nama@email.com';

  @override
  String get fieldPassword => 'Kata sandi';

  @override
  String get fieldPasswordHint => 'Minimal 8 karakter';

  @override
  String get fieldName => 'Nama panggilan';

  @override
  String get fieldNameHint => 'Nama yang dilihat pasangan';

  @override
  String get loginButton => 'Masuk';

  @override
  String get registerButton => 'Daftar';

  @override
  String get loginNoAccount => 'Belum punya akun?';

  @override
  String get registerHasAccount => 'Sudah punya akun?';

  @override
  String get authOr => 'atau';

  @override
  String get googleSignIn => 'Masuk dengan Google';

  @override
  String get googleSignUp => 'Daftar dengan Google';

  @override
  String googleUsingAccount(String email) {
    return 'Memakai akun Google $email…';
  }

  @override
  String googleAccountCreated(String email) {
    return 'Akun baru dibuat untuk $email.';
  }

  @override
  String get googleSignInFailed => 'Masuk dengan Google gagal. Coba lagi.';

  @override
  String get showPassword => 'Tampilkan kata sandi';

  @override
  String get hidePassword => 'Sembunyikan kata sandi';

  @override
  String get errorEmailInvalid => 'Tulis email yang benar, misalnya nama@email.com.';

  @override
  String get errorPasswordRequired => 'Kata sandi belum diisi.';

  @override
  String get errorPasswordShort => 'Kata sandi minimal 8 karakter.';

  @override
  String get errorNameRequired => 'Nama panggilan belum diisi.';

  @override
  String get errorNameLong => 'Paling banyak 50 karakter.';

  @override
  String get notifTitle => 'Biar tidak ada yang terlewat';

  @override
  String get notifBody =>
      'Notifikasi memberi tahu saat tenggat tiba, saat pasangan menitipkan tugas, dan saat ada setoran baru. Kamu bisa mengaturnya kapan saja di Pengaturan.';

  @override
  String get notifAllow => 'Izinkan notifikasi';

  @override
  String get notifAllowed => 'Notifikasi sudah diizinkan.';

  @override
  String get notifDenied => 'Notifikasi belum diizinkan. Kamu bisa menyalakannya nanti dari pengaturan HP.';

  @override
  String get notifOpenSettings => 'Buka pengaturan notifikasi';

  @override
  String get greetingMorning => 'Selamat pagi!';

  @override
  String get greetingNoon => 'Selamat siang!';

  @override
  String get greetingAfternoon => 'Selamat sore!';

  @override
  String get greetingNight => 'Selamat malam!';

  @override
  String get homeOpenSettings => 'Buka Pengaturan';

  @override
  String get homeTodayTitle => 'Tugas hari ini';

  @override
  String homeTodayProgress(int done, int total) {
    return '$done dari $total beres';
  }

  @override
  String get homeTodayEmpty => 'Belum ada tugas hari ini. Santai dulu, atau tambah yang baru.';

  @override
  String get homeTodayAllDone => 'Beres semua! Hari ini kalian keren.';

  @override
  String get homeTodayAllDoneSolo => 'Beres semua! Hari ini kamu keren.';

  @override
  String get homeTodayFilterEmpty => 'Tidak ada tugas hari ini untuk pilihan ini.';

  @override
  String get homeSavingsTitle => 'Tabungan';

  @override
  String get homeSavingsEmpty => 'Belum ada target tabungan. Mulai dari satu target dulu.';

  @override
  String get homeSavingsCreate => 'Buat target';

  @override
  String get homeDatesAdd => 'Tambah tanggal';

  @override
  String homeDatesInDays(int count) {
    return '$count hari lagi';
  }

  @override
  String homeDatesGreeting(String title) {
    return '$title. Selamat!';
  }

  @override
  String homeDatesCaption(String title, String date) {
    return '$title · $date';
  }

  @override
  String get homeDatesEmptyCaption => 'Hari jadi dan ulang tahun';

  @override
  String homeDatesSemantic(String detail) {
    return 'Tanggal penting: $detail';
  }

  @override
  String homeOnThisDay(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years tahun lalu, hari ini',
      one: 'Setahun lalu, hari ini',
    );
    return '$_temp0';
  }

  @override
  String homeOnThisDayMore(int count) {
    return '$count kenangan lain di tanggal ini';
  }

  @override
  String get homeSearch => 'Cari';

  @override
  String get homeTripTitle => 'Persiapan liburan';

  @override
  String homeTripProgress(int done, int total) {
    return '$done dari $total';
  }

  @override
  String homeTripCaption(String title) {
    return 'Persiapan $title';
  }

  @override
  String get homeTripEmpty => 'Rencanakan liburan';

  @override
  String get homeTripEmptyCaption => 'Buat perjalanan dan checklistnya';

  @override
  String homeTripSemantic(String detail) {
    return 'Persiapan liburan: $detail';
  }

  @override
  String get filterAll => 'Semua';

  @override
  String get filterPeopleLabel => 'Filter penanggung jawab';

  @override
  String get addTask => 'Tambah tugas';

  @override
  String percent(int value) {
    return '$value%';
  }

  @override
  String get tasksTitle => 'Tugas';

  @override
  String get tasksNewList => 'Buat daftar baru';

  @override
  String get statusLabel => 'Status tugas';

  @override
  String get statusAll => 'Semua tugas';

  @override
  String get statusOpen => 'Belum selesai';

  @override
  String get statusDone => 'Selesai';

  @override
  String get peopleAll => 'Semua orang';

  @override
  String tasksDoneCount(int count) {
    return 'Selesai ($count)';
  }

  @override
  String listSpaceCount(String space, int count) {
    return '$space · $count';
  }

  @override
  String get tasksEmptyList => 'Belum ada tugas di daftar ini.';

  @override
  String get tasksEmptyFiltered => 'Tidak ada tugas untuk pilihan ini.';

  @override
  String get tasksEmptyDone => 'Belum ada tugas yang selesai.';

  @override
  String taskMarkDone(String title) {
    return 'Tandai selesai: $title';
  }

  @override
  String taskMarkUndone(String title) {
    return 'Batalkan selesai: $title';
  }

  @override
  String get taskCompletedSnack => 'Tugas selesai.';

  @override
  String get taskDeletedSnack => 'Tugas dihapus.';

  @override
  String get dueToday => 'Hari ini';

  @override
  String get dueTomorrow => 'Besok';

  @override
  String get dueYesterday => 'Kemarin';

  @override
  String get dueNone => 'Tanpa tenggat';

  @override
  String dueWithTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String dueOverdue(String when) {
    return 'Terlewat · $when';
  }

  @override
  String get dueImportant => 'Penting';

  @override
  String taskCompletedBy(String who, String when) {
    return 'Diselesaikan $who, $when';
  }

  @override
  String manageList(String name) {
    return 'Kelola daftar $name';
  }

  @override
  String get addTaskTitle => 'Tugas baru';

  @override
  String get addTaskWhat => 'Mau mengerjakan apa?';

  @override
  String get addTaskWhen => 'Kapan?';

  @override
  String get addTaskWho => 'Siapa?';

  @override
  String get addTaskPickDate => 'Pilih tanggal';

  @override
  String get addTaskPickTime => 'Pilih jam';

  @override
  String get addTaskNoTime => 'Tanpa jam';

  @override
  String get addTaskImportant => 'Tandai penting';

  @override
  String get addTaskListShared => 'Daftar bersama';

  @override
  String get addTaskListPersonal => 'Daftar pribadi';

  @override
  String get addTaskPickList => 'Pilih daftar';

  @override
  String get errorTitleRequired => 'Tulis dulu apa yang mau dikerjakan.';

  @override
  String get errorTitleLong => 'Judul paling banyak 200 karakter.';

  @override
  String get taskDetailTitle => 'Detail tugas';

  @override
  String get taskNotesLabel => 'Catatan';

  @override
  String get taskNotesHint => 'Tambahkan catatan kalau perlu';

  @override
  String get taskListLabel => 'Daftar';

  @override
  String get taskDelete => 'Hapus tugas';

  @override
  String get taskClearDate => 'Hapus tenggat';

  @override
  String get taskGone => 'Tugas ini sudah tidak ada.';

  @override
  String get taskAutosaved => 'Perubahan tersimpan otomatis.';

  @override
  String get errorNotesLong => 'Catatan paling banyak 5.000 karakter.';

  @override
  String get listsManageTitle => 'Kelola daftar';

  @override
  String get listNew => 'Daftar baru';

  @override
  String get listEdit => 'Ubah daftar';

  @override
  String get listNameLabel => 'Nama daftar';

  @override
  String get listNameHint => 'Misalnya Belanja';

  @override
  String get listEmojiLabel => 'Emoji (opsional)';

  @override
  String get listEmojiHint => 'Ketik satu emoji';

  @override
  String get listColorLabel => 'Warna';

  @override
  String get spaceWhereLabel => 'Simpan di mana?';

  @override
  String get listArchive => 'Arsipkan';

  @override
  String get listUnarchive => 'Keluarkan dari arsip';

  @override
  String get listArchivedSection => 'Diarsipkan';

  @override
  String get listDelete => 'Hapus daftar';

  @override
  String listDeleteConfirmTitle(String name) {
    return 'Hapus daftar $name?';
  }

  @override
  String listDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tugas di dalamnya ikut terhapus.',
      zero: 'Daftar ini belum berisi tugas.',
    );
    return '$_temp0';
  }

  @override
  String get listLastActive => 'Setiap ruang harus punya minimal satu daftar aktif.';

  @override
  String get listReorderHint => 'Tahan lalu geser untuk mengurutkan.';

  @override
  String listReorderHandle(String name) {
    return 'Geser untuk mengurutkan $name';
  }

  @override
  String get errorListNameRequired => 'Nama daftar belum diisi.';

  @override
  String get errorEmojiInvalid => 'Isi dengan satu emoji saja.';

  @override
  String get colorMawar => 'Mawar';

  @override
  String get colorUngu => 'Ungu';

  @override
  String get colorToska => 'Toska';

  @override
  String get colorBata => 'Bata';

  @override
  String get colorBiru => 'Biru';

  @override
  String get colorLavender => 'Lavender';

  @override
  String colorSemantic(String name) {
    return 'Warna $name';
  }

  @override
  String get savingsTitle => 'Tabungan';

  @override
  String get savingsNewGoal => 'Tambah target';

  @override
  String get savingsEmpty => 'Belum ada target tabungan. Buat satu, lalu catat setoran pertama kalian.';

  @override
  String get savingsEmptySolo => 'Belum ada target tabungan. Buat satu, lalu catat setoran pertamamu.';

  @override
  String savingsArchivedCount(int count) {
    return 'Diarsipkan ($count)';
  }

  @override
  String savingsOf(String saved, String target) {
    return '$saved dari $target';
  }

  @override
  String savingsFrom(String target) {
    return 'dari $target';
  }

  @override
  String get savingsCollected => 'terkumpul';

  @override
  String savingsRemaining(String amount) {
    return 'Sisa $amount';
  }

  @override
  String savingsTargetDate(String date) {
    return 'Target $date';
  }

  @override
  String savingsWeekly(String amount) {
    return 'Perlu $amount per minggu';
  }

  @override
  String get savingsDeposit => 'Setor';

  @override
  String get savingsWithdraw => 'Ambil';

  @override
  String get savingsMonthly => 'Setoran per bulan';

  @override
  String get savingsContributions => 'Kontribusi';

  @override
  String get savingsContributionFormer => 'Anggota lain';

  @override
  String get savingsContributionTotal => 'Total';

  @override
  String get percentUnderOne => '<1%';

  @override
  String savingsMonthlySemantic(String month, String amount) {
    return '$month: $amount';
  }

  @override
  String get savingsHistory => 'Riwayat tabungan';

  @override
  String get savingsHistoryEmpty => 'Belum ada setoran. Ketuk Setor untuk mencatat yang pertama.';

  @override
  String savingsHistoryWho(String who, String note) {
    return '$who · $note';
  }

  @override
  String savingsHistoryWithdrawal(String who) {
    return '$who mengambil';
  }

  @override
  String savingsHistoryWithdrawalNote(String who, String note) {
    return '$who mengambil · $note';
  }

  @override
  String savingsAchieved(String name) {
    return '$name tercapai. Selamat, kalian berhasil!';
  }

  @override
  String savingsAchievedSolo(String name) {
    return '$name tercapai. Selamat, kamu berhasil!';
  }

  @override
  String get goalMenuArchive => 'Arsipkan';

  @override
  String get goalMenuUnarchive => 'Keluarkan dari arsip';

  @override
  String goalDeleteConfirmTitle(String name) {
    return 'Hapus target $name?';
  }

  @override
  String goalDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count setoran di dalamnya ikut terhapus.',
      zero: 'Target ini belum punya setoran.',
    );
    return '$_temp0';
  }

  @override
  String get goalGone => 'Target ini sudah tidak ada.';

  @override
  String get goalFormNew => 'Target baru';

  @override
  String get goalFormEdit => 'Ubah target';

  @override
  String get goalNameLabel => 'Menabung untuk apa?';

  @override
  String get goalNameHint => 'Misalnya Dana Liburan';

  @override
  String get goalAmountLabel => 'Berapa targetnya?';

  @override
  String get goalCurrencyLabel => 'Mata uang';

  @override
  String get goalCurrencyLocked => 'Mata uang hanya bisa dipilih saat target dibuat.';

  @override
  String get goalDateLabel => 'Mau tercapai kapan? (opsional)';

  @override
  String get goalDatePick => 'Pilih tanggal';

  @override
  String get goalDateClear => 'Hapus tanggal';

  @override
  String get errorAmountRequired => 'Isi nominalnya dulu, lebih dari 0.';

  @override
  String get errorAmountTooLarge => 'Nominalnya terlalu besar.';

  @override
  String get errorGoalNameRequired => 'Nama target belum diisi.';

  @override
  String get depositTitle => 'Setor tabungan';

  @override
  String get depositEditTitle => 'Ubah setoran';

  @override
  String get depositAmountLabel => 'Berapa?';

  @override
  String get depositDateLabel => 'Kapan?';

  @override
  String get depositNoteLabel => 'Catatan (opsional)';

  @override
  String get depositNoteHint => 'Misalnya sisa gajian';

  @override
  String get depositDelete => 'Hapus setoran';

  @override
  String depositDeleteConfirm(String amount) {
    return 'Hapus setoran $amount?';
  }

  @override
  String get withdrawTitle => 'Ambil tabungan';

  @override
  String get withdrawEditTitle => 'Ubah penarikan';

  @override
  String get withdrawAmountLabel => 'Berapa yang diambil?';

  @override
  String withdrawAvailable(String amount) {
    return 'Terkumpul $amount, jadi paling banyak segitu yang bisa diambil.';
  }

  @override
  String withdrawTooMuch(String amount) {
    return 'Paling banyak $amount, sebesar yang terkumpul.';
  }

  @override
  String get withdrawNoteHint => 'Misalnya untuk tiket pesawat';

  @override
  String get withdrawDelete => 'Hapus penarikan';

  @override
  String withdrawDeleteConfirm(String amount) {
    return 'Hapus penarikan $amount?';
  }

  @override
  String get errorNoteLong => 'Catatan paling banyak 200 karakter.';

  @override
  String get pairingTitle => 'Pakai berdua, lebih ringan';

  @override
  String get pairingBody =>
      'Ajak pasanganmu masuk ke Ruang Bersama. Kode berlaku 48 jam dan hanya bisa dipakai sekali.';

  @override
  String get pairingYourCode => 'Kode undanganmu';

  @override
  String get pairingCopy => 'Salin';

  @override
  String get pairingCopied => 'Kode disalin.';

  @override
  String get pairingShare => 'Bagikan lewat WhatsApp';

  @override
  String pairingShareText(String code, String expires) {
    return 'Yuk pakai Denly Days berdua. Masukkan kode $code di layar Ajak pasangan. Kode berlaku sampai $expires.';
  }

  @override
  String pairingExpires(String when) {
    return 'Berlaku sampai $when';
  }

  @override
  String get pairingOr => 'atau';

  @override
  String get pairingHaveCode => 'Punya kode dari pasangan?';

  @override
  String get pairingCodeHint => 'Contoh: K7P2QM';

  @override
  String get pairingJoin => 'Gabung';

  @override
  String get pairingCodeLoadFailed => 'Kode belum bisa diambil. Periksa koneksimu, lalu coba lagi.';

  @override
  String get pairingJoined => 'Kalian sudah terhubung. Ruang Bersama siap dipakai.';

  @override
  String pairingCodeSemantic(String code) {
    return 'Kode undangan $code';
  }

  @override
  String get pairedTitle => 'Ruang Bersama';

  @override
  String pairedBody(String name) {
    return 'Kamu dan $name berbagi tugas dan tabungan di sini.';
  }

  @override
  String pairedSince(String date) {
    return 'Bersama sejak $date';
  }

  @override
  String pairedYou(String name) {
    return '$name (kamu)';
  }

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsProfileSub => 'Foto, nama, tanggal lahir, warna diri';

  @override
  String get settingsSharedSpace => 'Ruang Bersama';

  @override
  String get settingsSharedSpacePaired => 'Kamu dan pasangan · 2 anggota';

  @override
  String get settingsSharedSpaceUnpaired => 'Belum berpasangan · ajak pasanganmu';

  @override
  String get settingsSpecialDates => 'Tanggal penting';

  @override
  String get settingsSpecialDatesSub => 'Ulang tahun dan anniversary';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemePick => 'Pilih tema warna';

  @override
  String get settingsModePick => 'Mode tampilan';

  @override
  String get themeMawar => 'Mawar';

  @override
  String get themeMawarCode => 'Palet C · D · I';

  @override
  String get themeAnggrek => 'Anggrek';

  @override
  String get themeAnggrekCode => 'Palet H · G · E';

  @override
  String get modeLight => 'Terang';

  @override
  String get modeDark => 'Gelap';

  @override
  String get modeSystem => 'Ikuti sistem';

  @override
  String get settingsNotifications => 'Notifikasi';

  @override
  String get notifTaskReminders => 'Pengingat tugas';

  @override
  String get notifTaskRemindersSub => 'Saat tenggat tiba';

  @override
  String get notifPartnerActivity => 'Aktivitas pasangan';

  @override
  String get notifPartnerActivitySub => 'Titipan baru, tugas selesai, kenangan baru, komentar, dan reaksi';

  @override
  String get notifSavingsActivity => 'Setoran tabungan';

  @override
  String get notifSavingsActivitySub => 'Setoran, penarikan, dan target tercapai';

  @override
  String get notifSpecialDates => 'Tanggal penting';

  @override
  String get notifSpecialDatesSub => 'H-7, H-1, dan hari H pukul 08.00';

  @override
  String get notifTripReminders => 'Pengingat perjalanan';

  @override
  String get notifTripRemindersSub => 'H-7 dan H-1 pukul 08.00';

  @override
  String get notifSavingsReminders => 'Pengingat setor';

  @override
  String get notifSavingsRemindersSub => 'Hari setor yang dipilih di target, pukul 08.00';

  @override
  String get settingsCurrency => 'Mata uang';

  @override
  String get settingsCurrencySheet => 'Mata uang untuk target baru';

  @override
  String get settingsWidget => 'Widget di layar utama';

  @override
  String get settingsWidgetSub => 'Tugas hari ini dan target tabungan utama';

  @override
  String get settingsWidgetManual => 'Tekan lama layar utama HP, pilih Widget, lalu cari Denly Days.';

  @override
  String get settingsBackup => 'Backup dan ekspor';

  @override
  String get settingsBackupSub => 'Tersimpan otomatis di server · ekspor di v1.0';

  @override
  String get settingsBackupInfo =>
      'Datamu tersimpan otomatis di server setiap kali online. Ekspor data menyusul di v1.0.';

  @override
  String get settingsLogout => 'Keluar';

  @override
  String get logoutConfirmTitle => 'Keluar dari akun ini?';

  @override
  String get logoutConfirmBody => 'Kamu bisa masuk lagi kapan saja.';

  @override
  String logoutPendingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Masih ada $count perubahan yang belum terkirim. Perubahan itu tetap tersimpan di HP ini dan baru dikirim saat kamu masuk lagi.',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileChangePhoto => 'Ubah foto profil';

  @override
  String get profileCamera => 'Kamera';

  @override
  String get profileGallery => 'Galeri';

  @override
  String get profileRemovePhoto => 'Hapus foto';

  @override
  String get profilePhotoNote => 'Foto dipotong persegi dan hanya terlihat oleh anggota Ruang Bersama.';

  @override
  String get profileBirthDate => 'Tanggal lahir';

  @override
  String get profileBirthDateHelp => 'Dipakai untuk pengingat ulang tahun. Tahun lahir boleh dikosongkan.';

  @override
  String get profileBirthDateEmpty => 'Belum diisi';

  @override
  String get profileColor => 'Warna diri (penanda tugasmu)';

  @override
  String get profileSaved => 'Profil disimpan.';

  @override
  String get profilePhotoUpdated => 'Foto profil diperbarui.';

  @override
  String get profilePhotoRemoved => 'Foto profil dihapus.';

  @override
  String get profilePhotoFailed => 'Foto belum bisa diproses. Coba lagi saat online.';

  @override
  String get profileCropTitle => 'Potong foto';

  @override
  String get birthDay => 'Tanggal';

  @override
  String get birthMonth => 'Bulan';

  @override
  String get birthYear => 'Tahun (opsional)';

  @override
  String get birthInvalid => 'Tanggal itu tidak ada di kalender.';

  @override
  String get birthClear => 'Hapus tanggal lahir';

  @override
  String get datesTitle => 'Tanggal penting';

  @override
  String get datesToday => 'Hari ini';

  @override
  String get datesTomorrow => 'Besok';

  @override
  String datesDaysShort(int count) {
    return '$count hari';
  }

  @override
  String datesTogetherSince(String date) {
    return 'Bersama sejak $date';
  }

  @override
  String datesTogetherDays(String days) {
    return '$days hari';
  }

  @override
  String datesTogetherNextDays(String title, int count) {
    return '$title tinggal $count hari lagi';
  }

  @override
  String datesTogetherNextTomorrow(String title) {
    return '$title besok';
  }

  @override
  String datesTogetherNextToday(String title) {
    return '$title hari ini';
  }

  @override
  String get datesUpcoming => 'Akan datang';

  @override
  String get datesEmpty =>
      'Belum ada tanggal penting. Simpan hari jadi atau ulang tahun orang tersayang, nanti kalian diingatkan.';

  @override
  String get datesBirthdayMine => 'Ulang tahunmu';

  @override
  String datesBirthdayOf(String name) {
    return 'Ulang tahun $name';
  }

  @override
  String datesOrdinal(String title, int count) {
    return '$title ke-$count';
  }

  @override
  String get datesInShared => 'Ruang Bersama';

  @override
  String get datesInPrivate => 'Pribadi, untuk kejutan';

  @override
  String datesRowSemantic(String title, String date, String countdown) {
    return '$title, $date, $countdown';
  }

  @override
  String get datesBirthdayMissing => 'Tanggal lahirmu belum diisi';

  @override
  String get datesBirthdayMissingSub => 'Isi di Profil supaya pasanganmu diingatkan.';

  @override
  String get datesReminders => 'Pengingat';

  @override
  String get datesRemindersSwitch => 'Kirim pengingat';

  @override
  String get datesRemindersNote =>
      'Ulang tahun kalian diambil dari Profil dan hanya diingatkan ke pasangan, supaya tetap jadi kejutan.';

  @override
  String get datesPrivacyNote =>
      'Simpan di Ruang Pribadi kalau ingin menyiapkan kejutan; pasanganmu tidak akan melihatnya.';

  @override
  String get datesAdd => 'Tambah tanggal';

  @override
  String get dateSheetNew => 'Tanggal baru';

  @override
  String get dateSheetEdit => 'Ubah tanggal';

  @override
  String get dateTypeLabel => 'Jenis apa?';

  @override
  String get dateTypeBirthday => 'Ulang tahun';

  @override
  String get dateTypeAnniversary => 'Anniversary';

  @override
  String get dateTypeOther => 'Lainnya';

  @override
  String get dateTitleLabel => 'Apa namanya?';

  @override
  String get dateTitleHintBirthday => 'Misalnya Ulang tahun Ibu';

  @override
  String get dateTitleHintAnniversary => 'Misalnya Hari jadi kita';

  @override
  String get dateTitleHintOther => 'Misalnya Hari pernikahan';

  @override
  String get dateWhenLabel => 'Kapan?';

  @override
  String get dateWhenPick => 'Pilih tanggal';

  @override
  String get dateWhenHelp => 'Tahun boleh dikosongkan. Kalau diisi, kalian bisa melihat ini yang ke berapa.';

  @override
  String get dateWherePrivateHelp => 'Pasanganmu tidak akan melihat tanggal ini.';

  @override
  String get dateDelete => 'Hapus tanggal';

  @override
  String dateDeleteConfirmTitle(String title) {
    return 'Hapus $title?';
  }

  @override
  String get dateDeleteConfirmBody => 'Pengingatnya ikut berhenti.';

  @override
  String get errorDateTitleRequired => 'Nama tanggal belum diisi.';

  @override
  String get errorDateRequired => 'Pilih tanggalnya dulu.';

  @override
  String outboxRelocated(String list) {
    return 'Daftarnya sudah tidak tersedia, jadi tugas dipindah ke $list.';
  }

  @override
  String get notifTapMissingTask => 'Tugas itu belum tersedia di HP ini.';

  @override
  String get notifTapMissingGoal => 'Target itu belum tersedia di HP ini.';

  @override
  String get notifTapMissingTrip => 'Perjalanan itu belum tersedia di HP ini.';

  @override
  String get tripsTitle => 'Liburan';

  @override
  String get tripsNew => 'Buat perjalanan';

  @override
  String get tripsEmpty => 'Belum ada rencana liburan. Buat perjalanan, lalu siapkan checklistnya bersama pasangan.';

  @override
  String get tripsEmptySolo => 'Belum ada rencana liburan. Buat perjalanan, lalu catat persiapannya di checklist.';

  @override
  String tripsDoneCount(int count) {
    return 'Sudah selesai ($count)';
  }

  @override
  String get tripsReminders => 'Pengingat';

  @override
  String get tripsRemindersSwitch => 'Ingatkan sebelum berangkat';

  @override
  String get tripsRemindersSub => 'H-7 dan H-1 pukul 08.00, dengan progres persiapan';

  @override
  String tripInDays(int count) {
    return '$count hari lagi';
  }

  @override
  String get tripTomorrow => 'Besok berangkat';

  @override
  String get tripUndated => 'Tanggal belum pasti';

  @override
  String tripOngoingDay(int day, int total) {
    return 'Hari ke-$day dari $total';
  }

  @override
  String get tripOngoing => 'Sedang berlangsung';

  @override
  String get tripDone => 'Selesai';

  @override
  String tripDays(int count) {
    return '$count hari';
  }

  @override
  String tripChecklistProgress(int done, int total) {
    return '$done dari $total beres';
  }

  @override
  String get tripChecklistNone => 'Belum ada persiapan';

  @override
  String tripDeleteConfirmTitle(String title) {
    return 'Hapus $title?';
  }

  @override
  String tripDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Checklist persiapannya ($count item) ikut terhapus.',
      zero: 'Pengingatnya ikut berhenti.',
    );
    return '$_temp0';
  }

  @override
  String get tripGone => 'Perjalanan ini sudah tidak ada.';

  @override
  String get tripChecklistTitle => 'Persiapan';

  @override
  String get tripChecklistEmpty =>
      'Belum ada persiapan. Catat barang bawaan dan hal yang perlu diurus sebelum berangkat.';

  @override
  String get tripChecklistAdd => 'Tambah persiapan';

  @override
  String tripChecklistMore(int count) {
    return '$count item lain belum beres';
  }

  @override
  String get tripChecklistAllDone => 'Persiapan beres semua. Selamat berlibur!';

  @override
  String get tripFundTitle => 'Dana';

  @override
  String get tripFundEmpty => 'Tautkan target tabungan supaya progres dana perjalanan ini terlihat di sini.';

  @override
  String get tripFundPick => 'Pilih target';

  @override
  String get tripFundCreate => 'Buat target';

  @override
  String get tripFundChange => 'Ganti';

  @override
  String get tripFundPickerTitle => 'Dana perjalanan';

  @override
  String get tripFundNone => 'Tanpa tabungan';

  @override
  String get tripFundPickerEmpty => 'Belum ada target tabungan di ruang ini.';

  @override
  String tripFundDefaultName(String title) {
    return 'Dana $title';
  }

  @override
  String get tripNotesTitle => 'Catatan';

  @override
  String get checklistAddHint => 'Misalnya Bawa sunscreen';

  @override
  String get checklistEmpty => 'Belum ada persiapan. Ketik di bawah untuk menambah item pertama.';

  @override
  String get tripSheetNew => 'Perjalanan baru';

  @override
  String get tripSheetEdit => 'Ubah perjalanan';

  @override
  String get tripTitleLabel => 'Apa nama perjalanannya?';

  @override
  String get tripTitleHint => 'Misalnya Liburan ke Bali';

  @override
  String get tripDestinationLabel => 'Ke mana?';

  @override
  String get tripDestinationHint => 'Misalnya Bali';

  @override
  String get tripStartLabel => 'Kapan berangkat?';

  @override
  String get tripEndLabel => 'Kapan pulang?';

  @override
  String get tripDatePick => 'Pilih tanggal';

  @override
  String get tripStartHelp => 'Boleh dikosongkan kalau belum pasti. Pengingat dikirim H-7 dan H-1.';

  @override
  String get tripEndHelp => 'Kosongkan kalau perjalanannya hanya sehari.';

  @override
  String get tripDateClear => 'Kosongkan tanggal';

  @override
  String get tripNotesLabel => 'Catatan';

  @override
  String get tripNotesHint => 'Hotel, rencana harian, atau hal lain yang perlu diingat';

  @override
  String get tripWherePrivateHelp => 'Pasanganmu tidak akan melihat perjalanan ini.';

  @override
  String get errorTripTitleRequired => 'Nama perjalanan belum diisi.';

  @override
  String get errorDestinationLong => 'Tujuan paling banyak 100 karakter.';

  @override
  String get savingsReminderOff => 'Ingatkan setor';

  @override
  String get savingsReminderOffSub => 'Mingguan atau bulanan, pukul 08.00';

  @override
  String savingsReminderWeekly(String day) {
    return 'Ingatkan setor tiap $day';
  }

  @override
  String savingsReminderMonthly(int day) {
    return 'Ingatkan setor tiap tanggal $day';
  }

  @override
  String get savingsReminderSubShared => 'Pukul 08.00, ke kalian berdua';

  @override
  String get savingsReminderSubPersonal => 'Pukul 08.00';

  @override
  String get savingsReminderPrefsOff => 'Pengingat setor sedang dimatikan di Pengaturan.';

  @override
  String get savingsReminderSheet => 'Pengingat setor';

  @override
  String get savingsReminderHowOften => 'Seberapa sering?';

  @override
  String get savingsReminderWeeklyOption => 'Mingguan';

  @override
  String get savingsReminderMonthlyOption => 'Bulanan';

  @override
  String get savingsReminderWhichDay => 'Hari apa?';

  @override
  String get savingsReminderWhichDate => 'Tanggal berapa?';

  @override
  String savingsReminderDateOption(int day) {
    return 'Tanggal $day';
  }

  @override
  String get savingsReminderShortMonth => 'Di bulan yang lebih pendek, pengingat dikirim di hari terakhir bulan itu.';

  @override
  String get savingsReminderNote => 'Dikirim pukul 08.00 selama target belum tercapai.';

  @override
  String get savingsReminderNoteShared => 'Dikirim pukul 08.00 ke kalian berdua selama target belum tercapai.';

  @override
  String get savingsReminderTurnOff => 'Matikan pengingat';

  @override
  String get memoriesTitle => 'Kenangan';

  @override
  String get memoriesNew => 'Kenangan baru';

  @override
  String get memoriesEmpty =>
      'Belum ada kenangan. Simpan tempat yang pernah kalian datangi, lengkap dengan foto dan ceritanya.';

  @override
  String get memoriesEmptySolo =>
      'Belum ada kenangan. Simpan tempat yang pernah kamu datangi, lengkap dengan foto dan ceritanya.';

  @override
  String memoriesYearCount(int count) {
    return '$count kenangan';
  }

  @override
  String memoryPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count foto', zero: 'Belum ada foto');
    return '$_temp0';
  }

  @override
  String get memoryGone => 'Kenangan ini sudah tidak ada.';

  @override
  String memoryFromTrip(String title) {
    return 'Dari perjalanan $title';
  }

  @override
  String get memoryStoryTitle => 'Cerita';

  @override
  String get memoryPhotosTitle => 'Foto';

  @override
  String get memoryPhotosAdd => 'Tambah foto';

  @override
  String get memoryPhotosEmpty => 'Belum ada foto. Tambahkan dari galeri HP supaya kenangan ini lebih hidup.';

  @override
  String memoryPhotosFull(int max) {
    return 'Satu kenangan paling banyak $max foto.';
  }

  @override
  String memoryPhotosUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto tidak bisa dibaca, jadi tidak ditambahkan.',
    );
    return '$_temp0';
  }

  @override
  String memoryPhotosPreparing(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Menyiapkan $count foto');
    return '$_temp0';
  }

  @override
  String get memoryPhotoPending => 'Menunggu terkirim';

  @override
  String memoryPhotoLabel(int index, int total) {
    return 'Foto $index dari $total';
  }

  @override
  String memoryDeleteConfirmTitle(String title) {
    return 'Hapus $title?';
  }

  @override
  String memoryDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotonya ikut terhapus dan tidak bisa dikembalikan.',
    );
    return '$_temp0';
  }

  @override
  String get memoryDeletedSnack => 'Kenangan dihapus.';

  @override
  String get memoryFormNew => 'Kenangan baru';

  @override
  String get memoryFormEdit => 'Ubah kenangan';

  @override
  String get memoryTitleLabel => 'Mau dikenang sebagai apa?';

  @override
  String get memoryTitleHint => 'Misalnya Liburan ke Bali';

  @override
  String get memoryPlaceLabel => 'Di mana?';

  @override
  String get memoryPlaceHint => 'Misalnya Ubud, Bali';

  @override
  String get memoryDateLabel => 'Kapan?';

  @override
  String get memoryStoryLabel => 'Ceritanya?';

  @override
  String get memoryStoryHint => 'Apa yang paling diingat dari hari itu?';

  @override
  String get memoryPhotosLabel => 'Fotonya?';

  @override
  String memoryPhotosHelp(int max) {
    return 'Paling banyak $max foto. Foto dikecilkan sebelum diunggah, dan lokasinya tidak ikut tersimpan.';
  }

  @override
  String get memoryPhotosPick => 'Pilih foto';

  @override
  String memoryPhotoUnpick(int index) {
    return 'Batal pilih foto $index';
  }

  @override
  String get memoryWherePrivateHelp => 'Pasanganmu tidak akan melihat kenangan ini.';

  @override
  String get errorMemoryTitleRequired => 'Judul kenangan belum diisi.';

  @override
  String get errorPlaceLong => 'Nama tempat paling banyak 100 karakter.';

  @override
  String get errorStoryLong => 'Cerita paling banyak 10.000 karakter.';

  @override
  String galleryCounter(int index, int total) {
    return '$index dari $total';
  }

  @override
  String get galleryMakeCover => 'Jadikan sampul';

  @override
  String get galleryIsCover => 'Foto sampul';

  @override
  String get galleryCoverSet => 'Foto ini jadi sampul.';

  @override
  String get galleryDelete => 'Hapus foto';

  @override
  String get galleryDeletedSnack => 'Foto dihapus.';

  @override
  String galleryTakenAt(String date, String time) {
    return 'Diambil $date, $time';
  }

  @override
  String get galleryGone => 'Foto ini sudah tidak ada.';

  @override
  String get tripSaveAsMemory => 'Simpan jadi kenangan';

  @override
  String get tripMemoriesTitle => 'Kenangan';

  @override
  String get notifTapMissingMemory => 'Kenangan itu belum tersedia di HP ini.';

  @override
  String get repeatAdd => 'Ulangi';

  @override
  String get repeatSheetTitle => 'Ulangi tugas';

  @override
  String get repeatHowOften => 'Seberapa sering?';

  @override
  String get repeatNone => 'Tidak diulang';

  @override
  String get repeatDaily => 'Harian';

  @override
  String get repeatWeekly => 'Mingguan';

  @override
  String get repeatMonthly => 'Bulanan';

  @override
  String get repeatYearly => 'Tahunan';

  @override
  String get repeatEvery => 'Setiap berapa?';

  @override
  String repeatEveryDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Tiap $count hari', one: 'Tiap hari');
    return '$_temp0';
  }

  @override
  String repeatEveryWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Tiap $count minggu', one: 'Tiap minggu');
    return '$_temp0';
  }

  @override
  String repeatEveryMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Tiap $count bulan', one: 'Tiap bulan');
    return '$_temp0';
  }

  @override
  String repeatEveryYear(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Tiap $count tahun', one: 'Tiap tahun');
    return '$_temp0';
  }

  @override
  String get repeatFewer => 'Kurangi';

  @override
  String get repeatMore => 'Tambah';

  @override
  String get repeatNote => 'Begitu tugas ini selesai, tugas berikutnya dibuat dengan tenggat baru.';

  @override
  String get repeatShortMonth => 'Di bulan yang lebih pendek, tenggatnya jatuh di hari terakhir bulan itu.';

  @override
  String get repeatLeapDay => 'Di tahun biasa, tenggatnya jatuh pada 28 Februari.';

  @override
  String repeatNextTask(String date) {
    return 'Tugas berikutnya: $date';
  }

  @override
  String get taskCompletedRepeatSnack => 'Tugas selesai. Yang berikutnya muncul setelah tersimpan di server.';
}
