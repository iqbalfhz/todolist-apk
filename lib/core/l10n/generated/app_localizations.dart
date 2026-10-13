import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('id')];

  /// No description provided for @commonSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get commonBack;

  /// No description provided for @commonUndo.
  ///
  /// In id, this message translates to:
  /// **'Urungkan'**
  String get commonUndo;

  /// No description provided for @commonRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get commonRetry;

  /// No description provided for @commonContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get commonContinue;

  /// No description provided for @commonSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get commonSkip;

  /// No description provided for @commonLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get commonLater;

  /// No description provided for @commonSeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get commonSeeAll;

  /// No description provided for @commonShowLess.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan lebih sedikit'**
  String get commonShowLess;

  /// No description provided for @commonEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get commonEdit;

  /// No description provided for @commonOptions.
  ///
  /// In id, this message translates to:
  /// **'Opsi lainnya'**
  String get commonOptions;

  /// No description provided for @commonOk.
  ///
  /// In id, this message translates to:
  /// **'Oke'**
  String get commonOk;

  /// No description provided for @labelMe.
  ///
  /// In id, this message translates to:
  /// **'Aku'**
  String get labelMe;

  /// No description provided for @labelPartner.
  ///
  /// In id, this message translates to:
  /// **'Pasangan'**
  String get labelPartner;

  /// No description provided for @labelUs.
  ///
  /// In id, this message translates to:
  /// **'Kita'**
  String get labelUs;

  /// No description provided for @labelShared.
  ///
  /// In id, this message translates to:
  /// **'Bersama'**
  String get labelShared;

  /// No description provided for @labelPersonal.
  ///
  /// In id, this message translates to:
  /// **'Pribadi'**
  String get labelPersonal;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In id, this message translates to:
  /// **'Tugas'**
  String get navTasks;

  /// No description provided for @navSavings.
  ///
  /// In id, this message translates to:
  /// **'Tabungan'**
  String get navSavings;

  /// No description provided for @navLabel.
  ///
  /// In id, this message translates to:
  /// **'Navigasi utama'**
  String get navLabel;

  /// No description provided for @offlineBanner.
  ///
  /// In id, this message translates to:
  /// **'Sedang offline. Perubahanmu aman dan dikirim saat online.'**
  String get offlineBanner;

  /// No description provided for @updateBanner.
  ///
  /// In id, this message translates to:
  /// **'Versi app ini sudah tertinggal. Perbarui app supaya perubahanmu terkirim.'**
  String get updateBanner;

  /// No description provided for @needsConnection.
  ///
  /// In id, this message translates to:
  /// **'Butuh koneksi internet. Coba lagi saat online.'**
  String get needsConnection;

  /// No description provided for @genericError.
  ///
  /// In id, this message translates to:
  /// **'Ada yang tidak beres. Coba lagi sebentar lagi.'**
  String get genericError;

  /// No description provided for @sessionExpired.
  ///
  /// In id, this message translates to:
  /// **'Sesi kamu sudah berakhir. Silakan masuk lagi.'**
  String get sessionExpired;

  /// No description provided for @loginTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Senang melihatmu lagi.'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buat akun untuk mulai mencatat berdua.'**
  String get registerSubtitle;

  /// No description provided for @fieldEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldEmailHint.
  ///
  /// In id, this message translates to:
  /// **'nama@email.com'**
  String get fieldEmailHint;

  /// No description provided for @fieldPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get fieldPassword;

  /// No description provided for @fieldPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get fieldPasswordHint;

  /// No description provided for @fieldName.
  ///
  /// In id, this message translates to:
  /// **'Nama panggilan'**
  String get fieldName;

  /// No description provided for @fieldNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama yang dilihat pasangan'**
  String get fieldNameHint;

  /// No description provided for @loginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get loginNoAccount;

  /// No description provided for @registerHasAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get registerHasAccount;

  /// No description provided for @showPassword.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kata sandi'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan kata sandi'**
  String get hidePassword;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Tulis email yang benar, misalnya nama@email.com.'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi belum diisi.'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordShort.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 8 karakter.'**
  String get errorPasswordShort;

  /// No description provided for @errorNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama panggilan belum diisi.'**
  String get errorNameRequired;

  /// No description provided for @errorNameLong.
  ///
  /// In id, this message translates to:
  /// **'Paling banyak 50 karakter.'**
  String get errorNameLong;

  /// No description provided for @notifTitle.
  ///
  /// In id, this message translates to:
  /// **'Biar tidak ada yang terlewat'**
  String get notifTitle;

  /// No description provided for @notifBody.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi memberi tahu saat tenggat tiba, saat pasangan menitipkan tugas, dan saat ada setoran baru. Kamu bisa mengaturnya kapan saja di Pengaturan.'**
  String get notifBody;

  /// No description provided for @notifAllow.
  ///
  /// In id, this message translates to:
  /// **'Izinkan notifikasi'**
  String get notifAllow;

  /// No description provided for @notifAllowed.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi sudah diizinkan.'**
  String get notifAllowed;

  /// No description provided for @notifDenied.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi belum diizinkan. Kamu bisa menyalakannya nanti dari pengaturan HP.'**
  String get notifDenied;

  /// No description provided for @notifOpenSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan notifikasi'**
  String get notifOpenSettings;

  /// No description provided for @batteryTitle.
  ///
  /// In id, this message translates to:
  /// **'Supaya pengingat tetap sampai'**
  String get batteryTitle;

  /// No description provided for @batteryBody.
  ///
  /// In id, this message translates to:
  /// **'HP {brand} sering menghentikan app di latar belakang untuk menghemat baterai, jadi pengingat bisa telat. Matikan penghematan baterai untuk app ini:'**
  String batteryBody(String brand);

  /// No description provided for @batteryStepsXiaomi.
  ///
  /// In id, this message translates to:
  /// **'1. Buka Pengaturan > Aplikasi > Kelola aplikasi, lalu pilih app ini.\n2. Ketuk Penghemat baterai, lalu pilih Tanpa batasan.\n3. Nyalakan Mulai otomatis.'**
  String get batteryStepsXiaomi;

  /// No description provided for @batteryStepsOppo.
  ///
  /// In id, this message translates to:
  /// **'1. Buka Pengaturan > Baterai > Pengaturan lainnya > Optimalkan penggunaan baterai.\n2. Pilih app ini, lalu pilih Jangan optimalkan.\n3. Di Pengaturan > Aplikasi > Mulai otomatis, izinkan app ini.'**
  String get batteryStepsOppo;

  /// No description provided for @batteryStepsVivo.
  ///
  /// In id, this message translates to:
  /// **'1. Buka Pengaturan > Baterai > Konsumsi daya tinggi di latar belakang.\n2. Nyalakan untuk app ini.\n3. Di Pengaturan > Aplikasi > Mulai otomatis, izinkan app ini.'**
  String get batteryStepsVivo;

  /// No description provided for @batteryStepsRealme.
  ///
  /// In id, this message translates to:
  /// **'1. Buka Pengaturan > Baterai > Pengaturan lainnya > Optimalkan penggunaan baterai.\n2. Pilih app ini, lalu pilih Jangan optimalkan.\n3. Di Pengaturan > Aplikasi > Mulai otomatis, izinkan app ini.'**
  String get batteryStepsRealme;

  /// No description provided for @batteryNote.
  ///
  /// In id, this message translates to:
  /// **'Nama menunya bisa sedikit berbeda di HP-mu.'**
  String get batteryNote;

  /// No description provided for @batteryOpen.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan baterai'**
  String get batteryOpen;

  /// No description provided for @batteryOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan baterai tidak bisa dibuka dari sini. Buka lewat Pengaturan HP.'**
  String get batteryOpenFailed;

  /// No description provided for @greetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi!'**
  String get greetingMorning;

  /// No description provided for @greetingNoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang!'**
  String get greetingNoon;

  /// No description provided for @greetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore!'**
  String get greetingAfternoon;

  /// No description provided for @greetingNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam!'**
  String get greetingNight;

  /// No description provided for @homeOpenSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get homeOpenSettings;

  /// No description provided for @homeTodayTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas hari ini'**
  String get homeTodayTitle;

  /// No description provided for @homeTodayProgress.
  ///
  /// In id, this message translates to:
  /// **'{done} dari {total} beres'**
  String homeTodayProgress(int done, int total);

  /// No description provided for @homeTodayEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas hari ini. Santai dulu, atau tambah yang baru.'**
  String get homeTodayEmpty;

  /// No description provided for @homeTodayAllDone.
  ///
  /// In id, this message translates to:
  /// **'Beres semua! Hari ini kalian keren.'**
  String get homeTodayAllDone;

  /// No description provided for @homeTodayAllDoneSolo.
  ///
  /// In id, this message translates to:
  /// **'Beres semua! Hari ini kamu keren.'**
  String get homeTodayAllDoneSolo;

  /// No description provided for @homeTodayFilterEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tugas hari ini untuk pilihan ini.'**
  String get homeTodayFilterEmpty;

  /// No description provided for @homeSavingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tabungan'**
  String get homeSavingsTitle;

  /// No description provided for @homeSavingsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada target tabungan. Mulai dari satu target dulu.'**
  String get homeSavingsEmpty;

  /// No description provided for @homeSavingsCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat target'**
  String get homeSavingsCreate;

  /// No description provided for @filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get filterAll;

  /// No description provided for @filterPeopleLabel.
  ///
  /// In id, this message translates to:
  /// **'Filter penanggung jawab'**
  String get filterPeopleLabel;

  /// No description provided for @addTask.
  ///
  /// In id, this message translates to:
  /// **'Tambah tugas'**
  String get addTask;

  /// No description provided for @percent.
  ///
  /// In id, this message translates to:
  /// **'{value}%'**
  String percent(int value);

  /// No description provided for @tasksTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas'**
  String get tasksTitle;

  /// No description provided for @tasksNewList.
  ///
  /// In id, this message translates to:
  /// **'Buat daftar baru'**
  String get tasksNewList;

  /// No description provided for @statusLabel.
  ///
  /// In id, this message translates to:
  /// **'Status tugas'**
  String get statusLabel;

  /// No description provided for @statusAll.
  ///
  /// In id, this message translates to:
  /// **'Semua tugas'**
  String get statusAll;

  /// No description provided for @statusOpen.
  ///
  /// In id, this message translates to:
  /// **'Belum selesai'**
  String get statusOpen;

  /// No description provided for @statusDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get statusDone;

  /// No description provided for @peopleAll.
  ///
  /// In id, this message translates to:
  /// **'Semua orang'**
  String get peopleAll;

  /// No description provided for @tasksDoneCount.
  ///
  /// In id, this message translates to:
  /// **'Selesai ({count})'**
  String tasksDoneCount(int count);

  /// No description provided for @listSpaceCount.
  ///
  /// In id, this message translates to:
  /// **'{space} · {count}'**
  String listSpaceCount(String space, int count);

  /// No description provided for @tasksEmptyList.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas di daftar ini.'**
  String get tasksEmptyList;

  /// No description provided for @tasksEmptyFiltered.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tugas untuk pilihan ini.'**
  String get tasksEmptyFiltered;

  /// No description provided for @tasksEmptyDone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas yang selesai.'**
  String get tasksEmptyDone;

  /// No description provided for @taskMarkDone.
  ///
  /// In id, this message translates to:
  /// **'Tandai selesai: {title}'**
  String taskMarkDone(String title);

  /// No description provided for @taskMarkUndone.
  ///
  /// In id, this message translates to:
  /// **'Batalkan selesai: {title}'**
  String taskMarkUndone(String title);

  /// No description provided for @taskCompletedSnack.
  ///
  /// In id, this message translates to:
  /// **'Tugas selesai.'**
  String get taskCompletedSnack;

  /// No description provided for @taskDeletedSnack.
  ///
  /// In id, this message translates to:
  /// **'Tugas dihapus.'**
  String get taskDeletedSnack;

  /// No description provided for @dueToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In id, this message translates to:
  /// **'Besok'**
  String get dueTomorrow;

  /// No description provided for @dueYesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get dueYesterday;

  /// No description provided for @dueNone.
  ///
  /// In id, this message translates to:
  /// **'Tanpa tenggat'**
  String get dueNone;

  /// No description provided for @dueWithTime.
  ///
  /// In id, this message translates to:
  /// **'{day}, {time}'**
  String dueWithTime(String day, String time);

  /// No description provided for @dueOverdue.
  ///
  /// In id, this message translates to:
  /// **'Terlewat · {when}'**
  String dueOverdue(String when);

  /// No description provided for @dueImportant.
  ///
  /// In id, this message translates to:
  /// **'Penting'**
  String get dueImportant;

  /// No description provided for @taskCompletedBy.
  ///
  /// In id, this message translates to:
  /// **'Diselesaikan {who}, {when}'**
  String taskCompletedBy(String who, String when);

  /// No description provided for @manageList.
  ///
  /// In id, this message translates to:
  /// **'Kelola daftar {name}'**
  String manageList(String name);

  /// No description provided for @addTaskTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas baru'**
  String get addTaskTitle;

  /// No description provided for @addTaskWhat.
  ///
  /// In id, this message translates to:
  /// **'Mau mengerjakan apa?'**
  String get addTaskWhat;

  /// No description provided for @addTaskWhen.
  ///
  /// In id, this message translates to:
  /// **'Kapan?'**
  String get addTaskWhen;

  /// No description provided for @addTaskWho.
  ///
  /// In id, this message translates to:
  /// **'Siapa?'**
  String get addTaskWho;

  /// No description provided for @addTaskPickDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get addTaskPickDate;

  /// No description provided for @addTaskPickTime.
  ///
  /// In id, this message translates to:
  /// **'Pilih jam'**
  String get addTaskPickTime;

  /// No description provided for @addTaskNoTime.
  ///
  /// In id, this message translates to:
  /// **'Tanpa jam'**
  String get addTaskNoTime;

  /// No description provided for @addTaskImportant.
  ///
  /// In id, this message translates to:
  /// **'Tandai penting'**
  String get addTaskImportant;

  /// No description provided for @addTaskListShared.
  ///
  /// In id, this message translates to:
  /// **'Daftar bersama'**
  String get addTaskListShared;

  /// No description provided for @addTaskListPersonal.
  ///
  /// In id, this message translates to:
  /// **'Daftar pribadi'**
  String get addTaskListPersonal;

  /// No description provided for @addTaskPickList.
  ///
  /// In id, this message translates to:
  /// **'Pilih daftar'**
  String get addTaskPickList;

  /// No description provided for @errorTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Tulis dulu apa yang mau dikerjakan.'**
  String get errorTitleRequired;

  /// No description provided for @errorTitleLong.
  ///
  /// In id, this message translates to:
  /// **'Judul paling banyak 200 karakter.'**
  String get errorTitleLong;

  /// No description provided for @taskDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail tugas'**
  String get taskDetailTitle;

  /// No description provided for @taskNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get taskNotesLabel;

  /// No description provided for @taskNotesHint.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan catatan kalau perlu'**
  String get taskNotesHint;

  /// No description provided for @taskListLabel.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get taskListLabel;

  /// No description provided for @taskDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus tugas'**
  String get taskDelete;

  /// No description provided for @taskClearDate.
  ///
  /// In id, this message translates to:
  /// **'Hapus tenggat'**
  String get taskClearDate;

  /// No description provided for @taskGone.
  ///
  /// In id, this message translates to:
  /// **'Tugas ini sudah tidak ada.'**
  String get taskGone;

  /// No description provided for @taskAutosaved.
  ///
  /// In id, this message translates to:
  /// **'Perubahan tersimpan otomatis.'**
  String get taskAutosaved;

  /// No description provided for @errorNotesLong.
  ///
  /// In id, this message translates to:
  /// **'Catatan paling banyak 5.000 karakter.'**
  String get errorNotesLong;

  /// No description provided for @listsManageTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola daftar'**
  String get listsManageTitle;

  /// No description provided for @listNew.
  ///
  /// In id, this message translates to:
  /// **'Daftar baru'**
  String get listNew;

  /// No description provided for @listEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah daftar'**
  String get listEdit;

  /// No description provided for @listNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama daftar'**
  String get listNameLabel;

  /// No description provided for @listNameHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Belanja'**
  String get listNameHint;

  /// No description provided for @listEmojiLabel.
  ///
  /// In id, this message translates to:
  /// **'Emoji (opsional)'**
  String get listEmojiLabel;

  /// No description provided for @listEmojiHint.
  ///
  /// In id, this message translates to:
  /// **'Ketik satu emoji'**
  String get listEmojiHint;

  /// No description provided for @listColorLabel.
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get listColorLabel;

  /// No description provided for @spaceWhereLabel.
  ///
  /// In id, this message translates to:
  /// **'Simpan di mana?'**
  String get spaceWhereLabel;

  /// No description provided for @listArchive.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get listArchive;

  /// No description provided for @listUnarchive.
  ///
  /// In id, this message translates to:
  /// **'Keluarkan dari arsip'**
  String get listUnarchive;

  /// No description provided for @listArchivedSection.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan'**
  String get listArchivedSection;

  /// No description provided for @listDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus daftar'**
  String get listDelete;

  /// No description provided for @listDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus daftar {name}?'**
  String listDeleteConfirmTitle(String name);

  /// No description provided for @listDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Daftar ini belum berisi tugas.} other{{count} tugas di dalamnya ikut terhapus.}}'**
  String listDeleteConfirmBody(int count);

  /// No description provided for @listLastActive.
  ///
  /// In id, this message translates to:
  /// **'Setiap ruang harus punya minimal satu daftar aktif.'**
  String get listLastActive;

  /// No description provided for @listReorderHint.
  ///
  /// In id, this message translates to:
  /// **'Tahan lalu geser untuk mengurutkan.'**
  String get listReorderHint;

  /// No description provided for @listReorderHandle.
  ///
  /// In id, this message translates to:
  /// **'Geser untuk mengurutkan {name}'**
  String listReorderHandle(String name);

  /// No description provided for @errorListNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama daftar belum diisi.'**
  String get errorListNameRequired;

  /// No description provided for @errorEmojiInvalid.
  ///
  /// In id, this message translates to:
  /// **'Isi dengan satu emoji saja.'**
  String get errorEmojiInvalid;

  /// No description provided for @colorMawar.
  ///
  /// In id, this message translates to:
  /// **'Mawar'**
  String get colorMawar;

  /// No description provided for @colorUngu.
  ///
  /// In id, this message translates to:
  /// **'Ungu'**
  String get colorUngu;

  /// No description provided for @colorToska.
  ///
  /// In id, this message translates to:
  /// **'Toska'**
  String get colorToska;

  /// No description provided for @colorBata.
  ///
  /// In id, this message translates to:
  /// **'Bata'**
  String get colorBata;

  /// No description provided for @colorBiru.
  ///
  /// In id, this message translates to:
  /// **'Biru'**
  String get colorBiru;

  /// No description provided for @colorLavender.
  ///
  /// In id, this message translates to:
  /// **'Lavender'**
  String get colorLavender;

  /// No description provided for @colorSemantic.
  ///
  /// In id, this message translates to:
  /// **'Warna {name}'**
  String colorSemantic(String name);

  /// No description provided for @savingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tabungan'**
  String get savingsTitle;

  /// No description provided for @savingsNewGoal.
  ///
  /// In id, this message translates to:
  /// **'Tambah target'**
  String get savingsNewGoal;

  /// No description provided for @savingsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada target tabungan. Buat satu, lalu catat setoran pertama kalian.'**
  String get savingsEmpty;

  /// No description provided for @savingsEmptySolo.
  ///
  /// In id, this message translates to:
  /// **'Belum ada target tabungan. Buat satu, lalu catat setoran pertamamu.'**
  String get savingsEmptySolo;

  /// No description provided for @savingsArchivedCount.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan ({count})'**
  String savingsArchivedCount(int count);

  /// No description provided for @savingsOf.
  ///
  /// In id, this message translates to:
  /// **'{saved} dari {target}'**
  String savingsOf(String saved, String target);

  /// No description provided for @savingsFrom.
  ///
  /// In id, this message translates to:
  /// **'dari {target}'**
  String savingsFrom(String target);

  /// No description provided for @savingsCollected.
  ///
  /// In id, this message translates to:
  /// **'terkumpul'**
  String get savingsCollected;

  /// No description provided for @savingsRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa {amount}'**
  String savingsRemaining(String amount);

  /// No description provided for @savingsTargetDate.
  ///
  /// In id, this message translates to:
  /// **'Target {date}'**
  String savingsTargetDate(String date);

  /// No description provided for @savingsWeekly.
  ///
  /// In id, this message translates to:
  /// **'Perlu {amount} per minggu'**
  String savingsWeekly(String amount);

  /// No description provided for @savingsDeposit.
  ///
  /// In id, this message translates to:
  /// **'Setor'**
  String get savingsDeposit;

  /// No description provided for @savingsMonthly.
  ///
  /// In id, this message translates to:
  /// **'Setoran per bulan'**
  String get savingsMonthly;

  /// No description provided for @savingsMonthlySemantic.
  ///
  /// In id, this message translates to:
  /// **'{month}: {amount}'**
  String savingsMonthlySemantic(String month, String amount);

  /// No description provided for @savingsHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat tabungan'**
  String get savingsHistory;

  /// No description provided for @savingsHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada setoran. Ketuk Setor untuk mencatat yang pertama.'**
  String get savingsHistoryEmpty;

  /// No description provided for @savingsHistoryWho.
  ///
  /// In id, this message translates to:
  /// **'{who} · {note}'**
  String savingsHistoryWho(String who, String note);

  /// No description provided for @savingsAchieved.
  ///
  /// In id, this message translates to:
  /// **'{name} tercapai. Selamat, kalian berhasil!'**
  String savingsAchieved(String name);

  /// No description provided for @savingsAchievedSolo.
  ///
  /// In id, this message translates to:
  /// **'{name} tercapai. Selamat, kamu berhasil!'**
  String savingsAchievedSolo(String name);

  /// No description provided for @goalMenuArchive.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get goalMenuArchive;

  /// No description provided for @goalMenuUnarchive.
  ///
  /// In id, this message translates to:
  /// **'Keluarkan dari arsip'**
  String get goalMenuUnarchive;

  /// No description provided for @goalDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus target {name}?'**
  String goalDeleteConfirmTitle(String name);

  /// No description provided for @goalDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Target ini belum punya setoran.} other{{count} setoran di dalamnya ikut terhapus.}}'**
  String goalDeleteConfirmBody(int count);

  /// No description provided for @goalGone.
  ///
  /// In id, this message translates to:
  /// **'Target ini sudah tidak ada.'**
  String get goalGone;

  /// No description provided for @goalFormNew.
  ///
  /// In id, this message translates to:
  /// **'Target baru'**
  String get goalFormNew;

  /// No description provided for @goalFormEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah target'**
  String get goalFormEdit;

  /// No description provided for @goalNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Menabung untuk apa?'**
  String get goalNameLabel;

  /// No description provided for @goalNameHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Dana Liburan'**
  String get goalNameHint;

  /// No description provided for @goalAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Berapa targetnya?'**
  String get goalAmountLabel;

  /// No description provided for @goalCurrencyLabel.
  ///
  /// In id, this message translates to:
  /// **'Mata uang'**
  String get goalCurrencyLabel;

  /// No description provided for @goalCurrencyLocked.
  ///
  /// In id, this message translates to:
  /// **'Mata uang hanya bisa dipilih saat target dibuat.'**
  String get goalCurrencyLocked;

  /// No description provided for @goalDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Mau tercapai kapan? (opsional)'**
  String get goalDateLabel;

  /// No description provided for @goalDatePick.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get goalDatePick;

  /// No description provided for @goalDateClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus tanggal'**
  String get goalDateClear;

  /// No description provided for @errorAmountRequired.
  ///
  /// In id, this message translates to:
  /// **'Isi nominalnya dulu, lebih dari 0.'**
  String get errorAmountRequired;

  /// No description provided for @errorAmountTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Nominalnya terlalu besar.'**
  String get errorAmountTooLarge;

  /// No description provided for @errorGoalNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama target belum diisi.'**
  String get errorGoalNameRequired;

  /// No description provided for @depositTitle.
  ///
  /// In id, this message translates to:
  /// **'Setor tabungan'**
  String get depositTitle;

  /// No description provided for @depositEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah setoran'**
  String get depositEditTitle;

  /// No description provided for @depositAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Berapa?'**
  String get depositAmountLabel;

  /// No description provided for @depositDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Kapan?'**
  String get depositDateLabel;

  /// No description provided for @depositNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get depositNoteLabel;

  /// No description provided for @depositNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya sisa gajian'**
  String get depositNoteHint;

  /// No description provided for @depositDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus setoran'**
  String get depositDelete;

  /// No description provided for @depositDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus setoran {amount}?'**
  String depositDeleteConfirm(String amount);

  /// No description provided for @errorNoteLong.
  ///
  /// In id, this message translates to:
  /// **'Catatan paling banyak 200 karakter.'**
  String get errorNoteLong;

  /// No description provided for @pairingTitle.
  ///
  /// In id, this message translates to:
  /// **'Pakai berdua, lebih ringan'**
  String get pairingTitle;

  /// No description provided for @pairingBody.
  ///
  /// In id, this message translates to:
  /// **'Ajak pasanganmu masuk ke Ruang Bersama. Kode berlaku 48 jam dan hanya bisa dipakai sekali.'**
  String get pairingBody;

  /// No description provided for @pairingYourCode.
  ///
  /// In id, this message translates to:
  /// **'Kode undanganmu'**
  String get pairingYourCode;

  /// No description provided for @pairingCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get pairingCopy;

  /// No description provided for @pairingCopied.
  ///
  /// In id, this message translates to:
  /// **'Kode disalin.'**
  String get pairingCopied;

  /// No description provided for @pairingShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan lewat WhatsApp'**
  String get pairingShare;

  /// No description provided for @pairingShareText.
  ///
  /// In id, this message translates to:
  /// **'Yuk pakai app to-do ini berdua. Masukkan kode {code} di layar Ajak pasangan. Kode berlaku sampai {expires}.'**
  String pairingShareText(String code, String expires);

  /// No description provided for @pairingExpires.
  ///
  /// In id, this message translates to:
  /// **'Berlaku sampai {when}'**
  String pairingExpires(String when);

  /// No description provided for @pairingOr.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get pairingOr;

  /// No description provided for @pairingHaveCode.
  ///
  /// In id, this message translates to:
  /// **'Punya kode dari pasangan?'**
  String get pairingHaveCode;

  /// No description provided for @pairingCodeHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: K7P2QM'**
  String get pairingCodeHint;

  /// No description provided for @pairingJoin.
  ///
  /// In id, this message translates to:
  /// **'Gabung'**
  String get pairingJoin;

  /// No description provided for @pairingCodeLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Kode belum bisa diambil. Periksa koneksimu, lalu coba lagi.'**
  String get pairingCodeLoadFailed;

  /// No description provided for @pairingJoined.
  ///
  /// In id, this message translates to:
  /// **'Kalian sudah terhubung. Ruang Bersama siap dipakai.'**
  String get pairingJoined;

  /// No description provided for @pairingCodeSemantic.
  ///
  /// In id, this message translates to:
  /// **'Kode undangan {code}'**
  String pairingCodeSemantic(String code);

  /// No description provided for @pairedTitle.
  ///
  /// In id, this message translates to:
  /// **'Ruang Bersama'**
  String get pairedTitle;

  /// No description provided for @pairedBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu dan {name} berbagi tugas dan tabungan di sini.'**
  String pairedBody(String name);

  /// No description provided for @pairedSince.
  ///
  /// In id, this message translates to:
  /// **'Bersama sejak {date}'**
  String pairedSince(String date);

  /// No description provided for @pairedYou.
  ///
  /// In id, this message translates to:
  /// **'{name} (kamu)'**
  String pairedYou(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsProfileSub.
  ///
  /// In id, this message translates to:
  /// **'Foto, nama, tanggal lahir, warna diri'**
  String get settingsProfileSub;

  /// No description provided for @settingsSharedSpace.
  ///
  /// In id, this message translates to:
  /// **'Ruang Bersama'**
  String get settingsSharedSpace;

  /// No description provided for @settingsSharedSpacePaired.
  ///
  /// In id, this message translates to:
  /// **'Kamu dan pasangan · 2 anggota'**
  String get settingsSharedSpacePaired;

  /// No description provided for @settingsSharedSpaceUnpaired.
  ///
  /// In id, this message translates to:
  /// **'Belum berpasangan · ajak pasanganmu'**
  String get settingsSharedSpaceUnpaired;

  /// No description provided for @settingsTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemePick.
  ///
  /// In id, this message translates to:
  /// **'Pilih tema warna'**
  String get settingsThemePick;

  /// No description provided for @settingsModePick.
  ///
  /// In id, this message translates to:
  /// **'Mode tampilan'**
  String get settingsModePick;

  /// No description provided for @themeMawar.
  ///
  /// In id, this message translates to:
  /// **'Mawar'**
  String get themeMawar;

  /// No description provided for @themeMawarCode.
  ///
  /// In id, this message translates to:
  /// **'Palet C · D · I'**
  String get themeMawarCode;

  /// No description provided for @themeAnggrek.
  ///
  /// In id, this message translates to:
  /// **'Anggrek'**
  String get themeAnggrek;

  /// No description provided for @themeAnggrekCode.
  ///
  /// In id, this message translates to:
  /// **'Palet H · G · E'**
  String get themeAnggrekCode;

  /// No description provided for @modeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get modeLight;

  /// No description provided for @modeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get modeDark;

  /// No description provided for @modeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get modeSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get settingsNotifications;

  /// No description provided for @notifTaskReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat tugas'**
  String get notifTaskReminders;

  /// No description provided for @notifTaskRemindersSub.
  ///
  /// In id, this message translates to:
  /// **'Saat tenggat tiba'**
  String get notifTaskRemindersSub;

  /// No description provided for @notifPartnerActivity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas pasangan'**
  String get notifPartnerActivity;

  /// No description provided for @notifPartnerActivitySub.
  ///
  /// In id, this message translates to:
  /// **'Titipan baru dan tugas selesai'**
  String get notifPartnerActivitySub;

  /// No description provided for @notifSavingsActivity.
  ///
  /// In id, this message translates to:
  /// **'Setoran tabungan'**
  String get notifSavingsActivity;

  /// No description provided for @notifSavingsActivitySub.
  ///
  /// In id, this message translates to:
  /// **'Setoran baru dan target tercapai'**
  String get notifSavingsActivitySub;

  /// No description provided for @settingsCurrency.
  ///
  /// In id, this message translates to:
  /// **'Mata uang'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencySheet.
  ///
  /// In id, this message translates to:
  /// **'Mata uang untuk target baru'**
  String get settingsCurrencySheet;

  /// No description provided for @settingsBackup.
  ///
  /// In id, this message translates to:
  /// **'Backup dan ekspor'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSub.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan otomatis di server · ekspor di v1.0'**
  String get settingsBackupSub;

  /// No description provided for @settingsBackupInfo.
  ///
  /// In id, this message translates to:
  /// **'Datamu tersimpan otomatis di server setiap kali online. Ekspor data menyusul di v1.0.'**
  String get settingsBackupInfo;

  /// No description provided for @settingsLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get settingsLogout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari akun ini?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa masuk lagi kapan saja.'**
  String get logoutConfirmBody;

  /// No description provided for @logoutPendingBody.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{Masih ada {count} perubahan yang belum terkirim. Perubahan itu tetap tersimpan di HP ini dan baru dikirim saat kamu masuk lagi.}}'**
  String logoutPendingBody(int count);

  /// No description provided for @profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileChangePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ubah foto profil'**
  String get profileChangePhoto;

  /// No description provided for @profileCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get profileCamera;

  /// No description provided for @profileGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get profileGallery;

  /// No description provided for @profileRemovePhoto.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get profileRemovePhoto;

  /// No description provided for @profilePhotoNote.
  ///
  /// In id, this message translates to:
  /// **'Foto dipotong persegi dan hanya terlihat oleh anggota Ruang Bersama.'**
  String get profilePhotoNote;

  /// No description provided for @profileBirthDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahir'**
  String get profileBirthDate;

  /// No description provided for @profileBirthDateHelp.
  ///
  /// In id, this message translates to:
  /// **'Dipakai untuk pengingat ulang tahun. Tahun lahir boleh dikosongkan.'**
  String get profileBirthDateHelp;

  /// No description provided for @profileBirthDateEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum diisi'**
  String get profileBirthDateEmpty;

  /// No description provided for @profileColor.
  ///
  /// In id, this message translates to:
  /// **'Warna diri (penanda tugasmu)'**
  String get profileColor;

  /// No description provided for @profileSaved.
  ///
  /// In id, this message translates to:
  /// **'Profil disimpan.'**
  String get profileSaved;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In id, this message translates to:
  /// **'Foto profil diperbarui.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoRemoved.
  ///
  /// In id, this message translates to:
  /// **'Foto profil dihapus.'**
  String get profilePhotoRemoved;

  /// No description provided for @profilePhotoFailed.
  ///
  /// In id, this message translates to:
  /// **'Foto belum bisa diproses. Coba lagi saat online.'**
  String get profilePhotoFailed;

  /// No description provided for @profileCropTitle.
  ///
  /// In id, this message translates to:
  /// **'Potong foto'**
  String get profileCropTitle;

  /// No description provided for @birthDay.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get birthDay;

  /// No description provided for @birthMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get birthMonth;

  /// No description provided for @birthYear.
  ///
  /// In id, this message translates to:
  /// **'Tahun (opsional)'**
  String get birthYear;

  /// No description provided for @birthInvalid.
  ///
  /// In id, this message translates to:
  /// **'Tanggal itu tidak ada di kalender.'**
  String get birthInvalid;

  /// No description provided for @birthClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus tanggal lahir'**
  String get birthClear;

  /// No description provided for @outboxRelocated.
  ///
  /// In id, this message translates to:
  /// **'Daftarnya sudah tidak tersedia, jadi tugas dipindah ke {list}.'**
  String outboxRelocated(String list);

  /// No description provided for @notifTapMissingTask.
  ///
  /// In id, this message translates to:
  /// **'Tugas itu belum tersedia di HP ini.'**
  String get notifTapMissingTask;

  /// No description provided for @notifTapMissingGoal.
  ///
  /// In id, this message translates to:
  /// **'Target itu belum tersedia di HP ini.'**
  String get notifTapMissingGoal;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
