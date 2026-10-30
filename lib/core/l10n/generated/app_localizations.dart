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

  /// No description provided for @navTrips.
  ///
  /// In id, this message translates to:
  /// **'Liburan'**
  String get navTrips;

  /// No description provided for @navMemories.
  ///
  /// In id, this message translates to:
  /// **'Kenangan'**
  String get navMemories;

  /// No description provided for @navLabel.
  ///
  /// In id, this message translates to:
  /// **'Navigasi utama'**
  String get navLabel;

  /// No description provided for @commentsTitle.
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get commentsTitle;

  /// No description provided for @commentsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} komentar'**
  String commentsCount(int count);

  /// No description provided for @commentsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada komentar. Tulis yang pertama.'**
  String get commentsEmpty;

  /// No description provided for @commentHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis komentar…'**
  String get commentHint;

  /// No description provided for @commentSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim komentar'**
  String get commentSend;

  /// No description provided for @commentRequired.
  ///
  /// In id, this message translates to:
  /// **'Komentarnya masih kosong.'**
  String get commentRequired;

  /// No description provided for @commentTooLong.
  ///
  /// In id, this message translates to:
  /// **'Komentar paling banyak 1.000 karakter.'**
  String get commentTooLong;

  /// No description provided for @commentEdited.
  ///
  /// In id, this message translates to:
  /// **'diedit'**
  String get commentEdited;

  /// No description provided for @commentOptions.
  ///
  /// In id, this message translates to:
  /// **'Opsi komentar'**
  String get commentOptions;

  /// No description provided for @commentEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah komentar'**
  String get commentEditTitle;

  /// No description provided for @commentDeleted.
  ///
  /// In id, this message translates to:
  /// **'Komentar dihapus.'**
  String get commentDeleted;

  /// No description provided for @reactionAdd.
  ///
  /// In id, this message translates to:
  /// **'Beri reaksi'**
  String get reactionAdd;

  /// No description provided for @reactionClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup pilihan reaksi'**
  String get reactionClose;

  /// No description provided for @reactionPick.
  ///
  /// In id, this message translates to:
  /// **'Reaksi {emoji}'**
  String reactionPick(String emoji);

  /// No description provided for @reactionBy.
  ///
  /// In id, this message translates to:
  /// **'Reaksi {emoji} dari {people}'**
  String reactionBy(String emoji, String people);

  /// No description provided for @listAnd.
  ///
  /// In id, this message translates to:
  /// **' dan '**
  String get listAnd;

  /// No description provided for @conversationSummary.
  ///
  /// In id, this message translates to:
  /// **'{reactions} reaksi, {comments} komentar'**
  String conversationSummary(int reactions, int comments);

  /// No description provided for @entryDetailDeposit.
  ///
  /// In id, this message translates to:
  /// **'Setoran'**
  String get entryDetailDeposit;

  /// No description provided for @entryGone.
  ///
  /// In id, this message translates to:
  /// **'Setoran ini sudah dihapus.'**
  String get entryGone;

  /// No description provided for @entryDetailWithdrawal.
  ///
  /// In id, this message translates to:
  /// **'Penarikan'**
  String get entryDetailWithdrawal;

  /// No description provided for @osmAttribution.
  ///
  /// In id, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get osmAttribution;

  /// No description provided for @memoryPinLabel.
  ///
  /// In id, this message translates to:
  /// **'Tepatnya di titik mana?'**
  String get memoryPinLabel;

  /// No description provided for @memoryPinHelp.
  ///
  /// In id, this message translates to:
  /// **'Opsional. Kenangan berpin tampil di Peta kenangan.'**
  String get memoryPinHelp;

  /// No description provided for @memoryPinAdd.
  ///
  /// In id, this message translates to:
  /// **'Pasang pin di peta'**
  String get memoryPinAdd;

  /// No description provided for @memoryPinChange.
  ///
  /// In id, this message translates to:
  /// **'Ubah pin'**
  String get memoryPinChange;

  /// No description provided for @memoryPinRemove.
  ///
  /// In id, this message translates to:
  /// **'Lepas pin'**
  String get memoryPinRemove;

  /// No description provided for @memoryPinPreview.
  ///
  /// In id, this message translates to:
  /// **'Lokasi di peta. Ketuk untuk mengubah pin.'**
  String get memoryPinPreview;

  /// No description provided for @memoryMapPreview.
  ///
  /// In id, this message translates to:
  /// **'Lokasi di peta. Ketuk untuk membuka Peta kenangan.'**
  String get memoryMapPreview;

  /// No description provided for @pickerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih lokasi'**
  String get pickerTitle;

  /// No description provided for @pickerSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari tempat, misalnya Ubud'**
  String get pickerSearchHint;

  /// No description provided for @pickerSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari tempat'**
  String get pickerSearch;

  /// No description provided for @pickerTapHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk peta untuk memasang pin'**
  String get pickerTapHint;

  /// No description provided for @pickerMapSemantic.
  ///
  /// In id, this message translates to:
  /// **'Peta. Ketuk untuk memasang pin di titik itu.'**
  String get pickerMapSemantic;

  /// No description provided for @pickerUse.
  ///
  /// In id, this message translates to:
  /// **'Pakai titik ini'**
  String get pickerUse;

  /// No description provided for @pickerQueryShort.
  ///
  /// In id, this message translates to:
  /// **'Ketik paling sedikit {count} huruf, lalu ketuk Cari.'**
  String pickerQueryShort(int count);

  /// No description provided for @pickerNoResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tempat yang cocok dengan \"{query}\". Coba kata lain, atau ketuk peta.'**
  String pickerNoResults(String query);

  /// No description provided for @pickerOffline.
  ///
  /// In id, this message translates to:
  /// **'Mencari tempat butuh koneksi internet. Pin tetap bisa dipasang dengan mengetuk peta.'**
  String get pickerOffline;

  /// No description provided for @pickerTooOften.
  ///
  /// In id, this message translates to:
  /// **'Terlalu sering mencari. Coba lagi sebentar lagi, atau ketuk peta.'**
  String get pickerTooOften;

  /// No description provided for @memoriesMapTitle.
  ///
  /// In id, this message translates to:
  /// **'Peta kenangan'**
  String get memoriesMapTitle;

  /// No description provided for @memoriesMapEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kenangan berpin. Pasang pin lewat Ubah kenangan.'**
  String get memoriesMapEmpty;

  /// No description provided for @memoriesMapCount.
  ///
  /// In id, this message translates to:
  /// **'{count} kenangan berpin'**
  String memoriesMapCount(int count);

  /// No description provided for @memoriesMapOpen.
  ///
  /// In id, this message translates to:
  /// **'Buka kenangan'**
  String get memoriesMapOpen;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Mau cari apa?'**
  String get searchHint;

  /// No description provided for @searchClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus kata kunci'**
  String get searchClear;

  /// No description provided for @searchIntro.
  ///
  /// In id, this message translates to:
  /// **'Cari tugas, tabungan, setoran, liburan, kenangan, dan tanggal penting. Bisa juga saat offline.'**
  String get searchIntro;

  /// No description provided for @searchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ketemu \"{query}\". Coba kata lain.'**
  String searchEmpty(String query);

  /// No description provided for @searchCount.
  ///
  /// In id, this message translates to:
  /// **'{count} hasil'**
  String searchCount(int count);

  /// No description provided for @searchShowAll.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan semua ({count})'**
  String searchShowAll(int count);

  /// No description provided for @searchSectionEntries.
  ///
  /// In id, this message translates to:
  /// **'Setoran'**
  String get searchSectionEntries;

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

  /// No description provided for @authOr.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get authOr;

  /// No description provided for @googleSignIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get googleSignIn;

  /// No description provided for @googleSignUp.
  ///
  /// In id, this message translates to:
  /// **'Daftar dengan Google'**
  String get googleSignUp;

  /// No description provided for @googleUsingAccount.
  ///
  /// In id, this message translates to:
  /// **'Memakai akun Google {email}…'**
  String googleUsingAccount(String email);

  /// No description provided for @googleAccountCreated.
  ///
  /// In id, this message translates to:
  /// **'Akun baru dibuat untuk {email}.'**
  String googleAccountCreated(String email);

  /// No description provided for @googleSignInFailed.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google gagal. Coba lagi.'**
  String get googleSignInFailed;

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

  /// No description provided for @homeDatesAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah tanggal'**
  String get homeDatesAdd;

  /// No description provided for @homeDatesInDays.
  ///
  /// In id, this message translates to:
  /// **'{count} hari lagi'**
  String homeDatesInDays(int count);

  /// No description provided for @homeDatesGreeting.
  ///
  /// In id, this message translates to:
  /// **'{title}. Selamat!'**
  String homeDatesGreeting(String title);

  /// No description provided for @homeDatesCaption.
  ///
  /// In id, this message translates to:
  /// **'{title} · {date}'**
  String homeDatesCaption(String title, String date);

  /// No description provided for @homeDatesEmptyCaption.
  ///
  /// In id, this message translates to:
  /// **'Hari jadi dan ulang tahun'**
  String get homeDatesEmptyCaption;

  /// No description provided for @homeDatesSemantic.
  ///
  /// In id, this message translates to:
  /// **'Tanggal penting: {detail}'**
  String homeDatesSemantic(String detail);

  /// No description provided for @homeOnThisDay.
  ///
  /// In id, this message translates to:
  /// **'{years, plural, =1{Setahun lalu, hari ini} other{{years} tahun lalu, hari ini}}'**
  String homeOnThisDay(int years);

  /// No description provided for @homeOnThisDayMore.
  ///
  /// In id, this message translates to:
  /// **'{count} kenangan lain di tanggal ini'**
  String homeOnThisDayMore(int count);

  /// No description provided for @homeSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get homeSearch;

  /// No description provided for @homeTripTitle.
  ///
  /// In id, this message translates to:
  /// **'Persiapan liburan'**
  String get homeTripTitle;

  /// No description provided for @homeTripProgress.
  ///
  /// In id, this message translates to:
  /// **'{done} dari {total}'**
  String homeTripProgress(int done, int total);

  /// No description provided for @homeTripCaption.
  ///
  /// In id, this message translates to:
  /// **'Persiapan {title}'**
  String homeTripCaption(String title);

  /// No description provided for @homeTripEmpty.
  ///
  /// In id, this message translates to:
  /// **'Rencanakan liburan'**
  String get homeTripEmpty;

  /// No description provided for @homeTripEmptyCaption.
  ///
  /// In id, this message translates to:
  /// **'Buat perjalanan dan checklistnya'**
  String get homeTripEmptyCaption;

  /// No description provided for @homeTripSemantic.
  ///
  /// In id, this message translates to:
  /// **'Persiapan liburan: {detail}'**
  String homeTripSemantic(String detail);

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

  /// No description provided for @savingsWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Ambil'**
  String get savingsWithdraw;

  /// No description provided for @savingsMonthly.
  ///
  /// In id, this message translates to:
  /// **'Setoran per bulan'**
  String get savingsMonthly;

  /// No description provided for @savingsContributions.
  ///
  /// In id, this message translates to:
  /// **'Kontribusi'**
  String get savingsContributions;

  /// No description provided for @savingsContributionFormer.
  ///
  /// In id, this message translates to:
  /// **'Anggota lain'**
  String get savingsContributionFormer;

  /// No description provided for @savingsContributionTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get savingsContributionTotal;

  /// No description provided for @percentUnderOne.
  ///
  /// In id, this message translates to:
  /// **'<1%'**
  String get percentUnderOne;

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

  /// No description provided for @savingsHistoryWithdrawal.
  ///
  /// In id, this message translates to:
  /// **'{who} mengambil'**
  String savingsHistoryWithdrawal(String who);

  /// No description provided for @savingsHistoryWithdrawalNote.
  ///
  /// In id, this message translates to:
  /// **'{who} mengambil · {note}'**
  String savingsHistoryWithdrawalNote(String who, String note);

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

  /// No description provided for @withdrawTitle.
  ///
  /// In id, this message translates to:
  /// **'Ambil tabungan'**
  String get withdrawTitle;

  /// No description provided for @withdrawEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah penarikan'**
  String get withdrawEditTitle;

  /// No description provided for @withdrawAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Berapa yang diambil?'**
  String get withdrawAmountLabel;

  /// No description provided for @withdrawAvailable.
  ///
  /// In id, this message translates to:
  /// **'Terkumpul {amount}, jadi paling banyak segitu yang bisa diambil.'**
  String withdrawAvailable(String amount);

  /// No description provided for @withdrawTooMuch.
  ///
  /// In id, this message translates to:
  /// **'Paling banyak {amount}, sebesar yang terkumpul.'**
  String withdrawTooMuch(String amount);

  /// No description provided for @withdrawNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya untuk tiket pesawat'**
  String get withdrawNoteHint;

  /// No description provided for @withdrawDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus penarikan'**
  String get withdrawDelete;

  /// No description provided for @withdrawDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus penarikan {amount}?'**
  String withdrawDeleteConfirm(String amount);

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
  /// **'Yuk pakai Denly Days berdua. Masukkan kode {code} di layar Ajak pasangan. Kode berlaku sampai {expires}.'**
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

  /// No description provided for @settingsSpecialDates.
  ///
  /// In id, this message translates to:
  /// **'Tanggal penting'**
  String get settingsSpecialDates;

  /// No description provided for @settingsSpecialDatesSub.
  ///
  /// In id, this message translates to:
  /// **'Ulang tahun dan anniversary'**
  String get settingsSpecialDatesSub;

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
  /// **'Titipan baru, tugas selesai, kenangan baru, komentar, dan reaksi'**
  String get notifPartnerActivitySub;

  /// No description provided for @notifSavingsActivity.
  ///
  /// In id, this message translates to:
  /// **'Setoran tabungan'**
  String get notifSavingsActivity;

  /// No description provided for @notifSavingsActivitySub.
  ///
  /// In id, this message translates to:
  /// **'Setoran, penarikan, dan target tercapai'**
  String get notifSavingsActivitySub;

  /// No description provided for @notifSpecialDates.
  ///
  /// In id, this message translates to:
  /// **'Tanggal penting'**
  String get notifSpecialDates;

  /// No description provided for @notifSpecialDatesSub.
  ///
  /// In id, this message translates to:
  /// **'H-7, H-1, dan hari H pukul 08.00'**
  String get notifSpecialDatesSub;

  /// No description provided for @notifTripReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat perjalanan'**
  String get notifTripReminders;

  /// No description provided for @notifTripRemindersSub.
  ///
  /// In id, this message translates to:
  /// **'H-7 dan H-1 pukul 08.00'**
  String get notifTripRemindersSub;

  /// No description provided for @notifSavingsReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat setor'**
  String get notifSavingsReminders;

  /// No description provided for @notifSavingsRemindersSub.
  ///
  /// In id, this message translates to:
  /// **'Hari setor yang dipilih di target, pukul 08.00'**
  String get notifSavingsRemindersSub;

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

  /// No description provided for @settingsWidget.
  ///
  /// In id, this message translates to:
  /// **'Widget di layar utama'**
  String get settingsWidget;

  /// No description provided for @settingsWidgetSub.
  ///
  /// In id, this message translates to:
  /// **'Tugas hari ini dan target tabungan utama'**
  String get settingsWidgetSub;

  /// No description provided for @settingsWidgetManual.
  ///
  /// In id, this message translates to:
  /// **'Tekan lama layar utama HP, pilih Widget, lalu cari Denly Days.'**
  String get settingsWidgetManual;

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

  /// No description provided for @datesTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanggal penting'**
  String get datesTitle;

  /// No description provided for @datesToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get datesToday;

  /// No description provided for @datesTomorrow.
  ///
  /// In id, this message translates to:
  /// **'Besok'**
  String get datesTomorrow;

  /// No description provided for @datesDaysShort.
  ///
  /// In id, this message translates to:
  /// **'{count} hari'**
  String datesDaysShort(int count);

  /// No description provided for @datesTogetherSince.
  ///
  /// In id, this message translates to:
  /// **'Bersama sejak {date}'**
  String datesTogetherSince(String date);

  /// No description provided for @datesTogetherDays.
  ///
  /// In id, this message translates to:
  /// **'{days} hari'**
  String datesTogetherDays(String days);

  /// No description provided for @datesTogetherNextDays.
  ///
  /// In id, this message translates to:
  /// **'{title} tinggal {count} hari lagi'**
  String datesTogetherNextDays(String title, int count);

  /// No description provided for @datesTogetherNextTomorrow.
  ///
  /// In id, this message translates to:
  /// **'{title} besok'**
  String datesTogetherNextTomorrow(String title);

  /// No description provided for @datesTogetherNextToday.
  ///
  /// In id, this message translates to:
  /// **'{title} hari ini'**
  String datesTogetherNextToday(String title);

  /// No description provided for @datesUpcoming.
  ///
  /// In id, this message translates to:
  /// **'Akan datang'**
  String get datesUpcoming;

  /// No description provided for @datesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tanggal penting. Simpan hari jadi atau ulang tahun orang tersayang, nanti kalian diingatkan.'**
  String get datesEmpty;

  /// No description provided for @datesBirthdayMine.
  ///
  /// In id, this message translates to:
  /// **'Ulang tahunmu'**
  String get datesBirthdayMine;

  /// No description provided for @datesBirthdayOf.
  ///
  /// In id, this message translates to:
  /// **'Ulang tahun {name}'**
  String datesBirthdayOf(String name);

  /// No description provided for @datesOrdinal.
  ///
  /// In id, this message translates to:
  /// **'{title} ke-{count}'**
  String datesOrdinal(String title, int count);

  /// No description provided for @datesInShared.
  ///
  /// In id, this message translates to:
  /// **'Ruang Bersama'**
  String get datesInShared;

  /// No description provided for @datesInPrivate.
  ///
  /// In id, this message translates to:
  /// **'Pribadi, untuk kejutan'**
  String get datesInPrivate;

  /// No description provided for @datesRowSemantic.
  ///
  /// In id, this message translates to:
  /// **'{title}, {date}, {countdown}'**
  String datesRowSemantic(String title, String date, String countdown);

  /// No description provided for @datesBirthdayMissing.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahirmu belum diisi'**
  String get datesBirthdayMissing;

  /// No description provided for @datesBirthdayMissingSub.
  ///
  /// In id, this message translates to:
  /// **'Isi di Profil supaya pasanganmu diingatkan.'**
  String get datesBirthdayMissingSub;

  /// No description provided for @datesReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get datesReminders;

  /// No description provided for @datesRemindersSwitch.
  ///
  /// In id, this message translates to:
  /// **'Kirim pengingat'**
  String get datesRemindersSwitch;

  /// No description provided for @datesRemindersNote.
  ///
  /// In id, this message translates to:
  /// **'Ulang tahun kalian diambil dari Profil dan hanya diingatkan ke pasangan, supaya tetap jadi kejutan.'**
  String get datesRemindersNote;

  /// No description provided for @datesPrivacyNote.
  ///
  /// In id, this message translates to:
  /// **'Simpan di Ruang Pribadi kalau ingin menyiapkan kejutan; pasanganmu tidak akan melihatnya.'**
  String get datesPrivacyNote;

  /// No description provided for @datesAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah tanggal'**
  String get datesAdd;

  /// No description provided for @dateSheetNew.
  ///
  /// In id, this message translates to:
  /// **'Tanggal baru'**
  String get dateSheetNew;

  /// No description provided for @dateSheetEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah tanggal'**
  String get dateSheetEdit;

  /// No description provided for @dateTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis apa?'**
  String get dateTypeLabel;

  /// No description provided for @dateTypeBirthday.
  ///
  /// In id, this message translates to:
  /// **'Ulang tahun'**
  String get dateTypeBirthday;

  /// No description provided for @dateTypeAnniversary.
  ///
  /// In id, this message translates to:
  /// **'Anniversary'**
  String get dateTypeAnniversary;

  /// No description provided for @dateTypeOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get dateTypeOther;

  /// No description provided for @dateTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Apa namanya?'**
  String get dateTitleLabel;

  /// No description provided for @dateTitleHintBirthday.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Ulang tahun Ibu'**
  String get dateTitleHintBirthday;

  /// No description provided for @dateTitleHintAnniversary.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Hari jadi kita'**
  String get dateTitleHintAnniversary;

  /// No description provided for @dateTitleHintOther.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Hari pernikahan'**
  String get dateTitleHintOther;

  /// No description provided for @dateWhenLabel.
  ///
  /// In id, this message translates to:
  /// **'Kapan?'**
  String get dateWhenLabel;

  /// No description provided for @dateWhenPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get dateWhenPick;

  /// No description provided for @dateWhenHelp.
  ///
  /// In id, this message translates to:
  /// **'Tahun boleh dikosongkan. Kalau diisi, kalian bisa melihat ini yang ke berapa.'**
  String get dateWhenHelp;

  /// No description provided for @dateWherePrivateHelp.
  ///
  /// In id, this message translates to:
  /// **'Pasanganmu tidak akan melihat tanggal ini.'**
  String get dateWherePrivateHelp;

  /// No description provided for @dateDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus tanggal'**
  String get dateDelete;

  /// No description provided for @dateDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {title}?'**
  String dateDeleteConfirmTitle(String title);

  /// No description provided for @dateDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Pengingatnya ikut berhenti.'**
  String get dateDeleteConfirmBody;

  /// No description provided for @errorDateTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama tanggal belum diisi.'**
  String get errorDateTitleRequired;

  /// No description provided for @errorDateRequired.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggalnya dulu.'**
  String get errorDateRequired;

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

  /// No description provided for @notifTapMissingTrip.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan itu belum tersedia di HP ini.'**
  String get notifTapMissingTrip;

  /// No description provided for @tripsTitle.
  ///
  /// In id, this message translates to:
  /// **'Liburan'**
  String get tripsTitle;

  /// No description provided for @tripsNew.
  ///
  /// In id, this message translates to:
  /// **'Buat perjalanan'**
  String get tripsNew;

  /// No description provided for @tripsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rencana liburan. Buat perjalanan, lalu siapkan checklistnya bersama pasangan.'**
  String get tripsEmpty;

  /// No description provided for @tripsEmptySolo.
  ///
  /// In id, this message translates to:
  /// **'Belum ada rencana liburan. Buat perjalanan, lalu catat persiapannya di checklist.'**
  String get tripsEmptySolo;

  /// No description provided for @tripsDoneCount.
  ///
  /// In id, this message translates to:
  /// **'Sudah selesai ({count})'**
  String tripsDoneCount(int count);

  /// No description provided for @tripsReminders.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get tripsReminders;

  /// No description provided for @tripsRemindersSwitch.
  ///
  /// In id, this message translates to:
  /// **'Ingatkan sebelum berangkat'**
  String get tripsRemindersSwitch;

  /// No description provided for @tripsRemindersSub.
  ///
  /// In id, this message translates to:
  /// **'H-7 dan H-1 pukul 08.00, dengan progres persiapan'**
  String get tripsRemindersSub;

  /// No description provided for @tripInDays.
  ///
  /// In id, this message translates to:
  /// **'{count} hari lagi'**
  String tripInDays(int count);

  /// No description provided for @tripTomorrow.
  ///
  /// In id, this message translates to:
  /// **'Besok berangkat'**
  String get tripTomorrow;

  /// No description provided for @tripUndated.
  ///
  /// In id, this message translates to:
  /// **'Tanggal belum pasti'**
  String get tripUndated;

  /// No description provided for @tripOngoingDay.
  ///
  /// In id, this message translates to:
  /// **'Hari ke-{day} dari {total}'**
  String tripOngoingDay(int day, int total);

  /// No description provided for @tripOngoing.
  ///
  /// In id, this message translates to:
  /// **'Sedang berlangsung'**
  String get tripOngoing;

  /// No description provided for @tripDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get tripDone;

  /// No description provided for @tripDays.
  ///
  /// In id, this message translates to:
  /// **'{count} hari'**
  String tripDays(int count);

  /// No description provided for @tripChecklistProgress.
  ///
  /// In id, this message translates to:
  /// **'{done} dari {total} beres'**
  String tripChecklistProgress(int done, int total);

  /// No description provided for @tripChecklistNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada persiapan'**
  String get tripChecklistNone;

  /// No description provided for @tripDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {title}?'**
  String tripDeleteConfirmTitle(String title);

  /// No description provided for @tripDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Pengingatnya ikut berhenti.} other{Checklist persiapannya ({count} item) ikut terhapus.}}'**
  String tripDeleteConfirmBody(int count);

  /// No description provided for @tripGone.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan ini sudah tidak ada.'**
  String get tripGone;

  /// No description provided for @tripChecklistTitle.
  ///
  /// In id, this message translates to:
  /// **'Persiapan'**
  String get tripChecklistTitle;

  /// No description provided for @tripChecklistEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada persiapan. Catat barang bawaan dan hal yang perlu diurus sebelum berangkat.'**
  String get tripChecklistEmpty;

  /// No description provided for @tripChecklistAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah persiapan'**
  String get tripChecklistAdd;

  /// No description provided for @tripChecklistMore.
  ///
  /// In id, this message translates to:
  /// **'{count} item lain belum beres'**
  String tripChecklistMore(int count);

  /// No description provided for @tripChecklistAllDone.
  ///
  /// In id, this message translates to:
  /// **'Persiapan beres semua. Selamat berlibur!'**
  String get tripChecklistAllDone;

  /// No description provided for @tripFundTitle.
  ///
  /// In id, this message translates to:
  /// **'Dana'**
  String get tripFundTitle;

  /// No description provided for @tripFundEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tautkan target tabungan supaya progres dana perjalanan ini terlihat di sini.'**
  String get tripFundEmpty;

  /// No description provided for @tripFundPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih target'**
  String get tripFundPick;

  /// No description provided for @tripFundCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat target'**
  String get tripFundCreate;

  /// No description provided for @tripFundChange.
  ///
  /// In id, this message translates to:
  /// **'Ganti'**
  String get tripFundChange;

  /// No description provided for @tripFundPickerTitle.
  ///
  /// In id, this message translates to:
  /// **'Dana perjalanan'**
  String get tripFundPickerTitle;

  /// No description provided for @tripFundNone.
  ///
  /// In id, this message translates to:
  /// **'Tanpa tabungan'**
  String get tripFundNone;

  /// No description provided for @tripFundPickerEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada target tabungan di ruang ini.'**
  String get tripFundPickerEmpty;

  /// No description provided for @tripFundDefaultName.
  ///
  /// In id, this message translates to:
  /// **'Dana {title}'**
  String tripFundDefaultName(String title);

  /// No description provided for @tripNotesTitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get tripNotesTitle;

  /// No description provided for @checklistAddHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Bawa sunscreen'**
  String get checklistAddHint;

  /// No description provided for @checklistEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada persiapan. Ketik di bawah untuk menambah item pertama.'**
  String get checklistEmpty;

  /// No description provided for @tripSheetNew.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan baru'**
  String get tripSheetNew;

  /// No description provided for @tripSheetEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah perjalanan'**
  String get tripSheetEdit;

  /// No description provided for @tripTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Apa nama perjalanannya?'**
  String get tripTitleLabel;

  /// No description provided for @tripTitleHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Liburan ke Bali'**
  String get tripTitleHint;

  /// No description provided for @tripDestinationLabel.
  ///
  /// In id, this message translates to:
  /// **'Ke mana?'**
  String get tripDestinationLabel;

  /// No description provided for @tripDestinationHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Bali'**
  String get tripDestinationHint;

  /// No description provided for @tripStartLabel.
  ///
  /// In id, this message translates to:
  /// **'Kapan berangkat?'**
  String get tripStartLabel;

  /// No description provided for @tripEndLabel.
  ///
  /// In id, this message translates to:
  /// **'Kapan pulang?'**
  String get tripEndLabel;

  /// No description provided for @tripDatePick.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get tripDatePick;

  /// No description provided for @tripStartHelp.
  ///
  /// In id, this message translates to:
  /// **'Boleh dikosongkan kalau belum pasti. Pengingat dikirim H-7 dan H-1.'**
  String get tripStartHelp;

  /// No description provided for @tripEndHelp.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan kalau perjalanannya hanya sehari.'**
  String get tripEndHelp;

  /// No description provided for @tripDateClear.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan tanggal'**
  String get tripDateClear;

  /// No description provided for @tripNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get tripNotesLabel;

  /// No description provided for @tripNotesHint.
  ///
  /// In id, this message translates to:
  /// **'Hotel, rencana harian, atau hal lain yang perlu diingat'**
  String get tripNotesHint;

  /// No description provided for @tripWherePrivateHelp.
  ///
  /// In id, this message translates to:
  /// **'Pasanganmu tidak akan melihat perjalanan ini.'**
  String get tripWherePrivateHelp;

  /// No description provided for @errorTripTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama perjalanan belum diisi.'**
  String get errorTripTitleRequired;

  /// No description provided for @errorDestinationLong.
  ///
  /// In id, this message translates to:
  /// **'Tujuan paling banyak 100 karakter.'**
  String get errorDestinationLong;

  /// No description provided for @savingsReminderOff.
  ///
  /// In id, this message translates to:
  /// **'Ingatkan setor'**
  String get savingsReminderOff;

  /// No description provided for @savingsReminderOffSub.
  ///
  /// In id, this message translates to:
  /// **'Mingguan atau bulanan, pukul 08.00'**
  String get savingsReminderOffSub;

  /// No description provided for @savingsReminderWeekly.
  ///
  /// In id, this message translates to:
  /// **'Ingatkan setor tiap {day}'**
  String savingsReminderWeekly(String day);

  /// No description provided for @savingsReminderMonthly.
  ///
  /// In id, this message translates to:
  /// **'Ingatkan setor tiap tanggal {day}'**
  String savingsReminderMonthly(int day);

  /// No description provided for @savingsReminderSubShared.
  ///
  /// In id, this message translates to:
  /// **'Pukul 08.00, ke kalian berdua'**
  String get savingsReminderSubShared;

  /// No description provided for @savingsReminderSubPersonal.
  ///
  /// In id, this message translates to:
  /// **'Pukul 08.00'**
  String get savingsReminderSubPersonal;

  /// No description provided for @savingsReminderPrefsOff.
  ///
  /// In id, this message translates to:
  /// **'Pengingat setor sedang dimatikan di Pengaturan.'**
  String get savingsReminderPrefsOff;

  /// No description provided for @savingsReminderSheet.
  ///
  /// In id, this message translates to:
  /// **'Pengingat setor'**
  String get savingsReminderSheet;

  /// No description provided for @savingsReminderHowOften.
  ///
  /// In id, this message translates to:
  /// **'Seberapa sering?'**
  String get savingsReminderHowOften;

  /// No description provided for @savingsReminderWeeklyOption.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get savingsReminderWeeklyOption;

  /// No description provided for @savingsReminderMonthlyOption.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get savingsReminderMonthlyOption;

  /// No description provided for @savingsReminderWhichDay.
  ///
  /// In id, this message translates to:
  /// **'Hari apa?'**
  String get savingsReminderWhichDay;

  /// No description provided for @savingsReminderWhichDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal berapa?'**
  String get savingsReminderWhichDate;

  /// No description provided for @savingsReminderDateOption.
  ///
  /// In id, this message translates to:
  /// **'Tanggal {day}'**
  String savingsReminderDateOption(int day);

  /// No description provided for @savingsReminderShortMonth.
  ///
  /// In id, this message translates to:
  /// **'Di bulan yang lebih pendek, pengingat dikirim di hari terakhir bulan itu.'**
  String get savingsReminderShortMonth;

  /// No description provided for @savingsReminderNote.
  ///
  /// In id, this message translates to:
  /// **'Dikirim pukul 08.00 selama target belum tercapai.'**
  String get savingsReminderNote;

  /// No description provided for @savingsReminderNoteShared.
  ///
  /// In id, this message translates to:
  /// **'Dikirim pukul 08.00 ke kalian berdua selama target belum tercapai.'**
  String get savingsReminderNoteShared;

  /// No description provided for @savingsReminderTurnOff.
  ///
  /// In id, this message translates to:
  /// **'Matikan pengingat'**
  String get savingsReminderTurnOff;

  /// No description provided for @memoriesTitle.
  ///
  /// In id, this message translates to:
  /// **'Kenangan'**
  String get memoriesTitle;

  /// No description provided for @memoriesNew.
  ///
  /// In id, this message translates to:
  /// **'Kenangan baru'**
  String get memoriesNew;

  /// No description provided for @memoriesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kenangan. Simpan tempat yang pernah kalian datangi, lengkap dengan foto dan ceritanya.'**
  String get memoriesEmpty;

  /// No description provided for @memoriesEmptySolo.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kenangan. Simpan tempat yang pernah kamu datangi, lengkap dengan foto dan ceritanya.'**
  String get memoriesEmptySolo;

  /// No description provided for @memoriesYearCount.
  ///
  /// In id, this message translates to:
  /// **'{count} kenangan'**
  String memoriesYearCount(int count);

  /// No description provided for @memoryPhotoCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Belum ada foto} other{{count} foto}}'**
  String memoryPhotoCount(int count);

  /// No description provided for @memoryGone.
  ///
  /// In id, this message translates to:
  /// **'Kenangan ini sudah tidak ada.'**
  String get memoryGone;

  /// No description provided for @memoryFromTrip.
  ///
  /// In id, this message translates to:
  /// **'Dari perjalanan {title}'**
  String memoryFromTrip(String title);

  /// No description provided for @memoryStoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Cerita'**
  String get memoryStoryTitle;

  /// No description provided for @memoryPhotosTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get memoryPhotosTitle;

  /// No description provided for @memoryPhotosAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto'**
  String get memoryPhotosAdd;

  /// No description provided for @memoryPhotosEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada foto. Tambahkan dari galeri HP supaya kenangan ini lebih hidup.'**
  String get memoryPhotosEmpty;

  /// No description provided for @memoryPhotosFull.
  ///
  /// In id, this message translates to:
  /// **'Satu kenangan paling banyak {max} foto.'**
  String memoryPhotosFull(int max);

  /// No description provided for @memoryPhotosUnreadable.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} foto tidak bisa dibaca, jadi tidak ditambahkan.}}'**
  String memoryPhotosUnreadable(int count);

  /// No description provided for @memoryPhotosPreparing.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{Menyiapkan {count} foto}}'**
  String memoryPhotosPreparing(int count);

  /// No description provided for @memoryPhotoPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu terkirim'**
  String get memoryPhotoPending;

  /// No description provided for @memoryPhotoLabel.
  ///
  /// In id, this message translates to:
  /// **'Foto {index} dari {total}'**
  String memoryPhotoLabel(int index, int total);

  /// No description provided for @memoryDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {title}?'**
  String memoryDeleteConfirmTitle(String title);

  /// No description provided for @memoryDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} fotonya ikut terhapus dan tidak bisa dikembalikan.}}'**
  String memoryDeleteConfirmBody(int count);

  /// No description provided for @memoryDeletedSnack.
  ///
  /// In id, this message translates to:
  /// **'Kenangan dihapus.'**
  String get memoryDeletedSnack;

  /// No description provided for @memoryFormNew.
  ///
  /// In id, this message translates to:
  /// **'Kenangan baru'**
  String get memoryFormNew;

  /// No description provided for @memoryFormEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah kenangan'**
  String get memoryFormEdit;

  /// No description provided for @memoryTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Mau dikenang sebagai apa?'**
  String get memoryTitleLabel;

  /// No description provided for @memoryTitleHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Liburan ke Bali'**
  String get memoryTitleHint;

  /// No description provided for @memoryPlaceLabel.
  ///
  /// In id, this message translates to:
  /// **'Di mana?'**
  String get memoryPlaceLabel;

  /// No description provided for @memoryPlaceHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya Ubud, Bali'**
  String get memoryPlaceHint;

  /// No description provided for @memoryDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Kapan?'**
  String get memoryDateLabel;

  /// No description provided for @memoryStoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Ceritanya?'**
  String get memoryStoryLabel;

  /// No description provided for @memoryStoryHint.
  ///
  /// In id, this message translates to:
  /// **'Apa yang paling diingat dari hari itu?'**
  String get memoryStoryHint;

  /// No description provided for @memoryPhotosLabel.
  ///
  /// In id, this message translates to:
  /// **'Fotonya?'**
  String get memoryPhotosLabel;

  /// No description provided for @memoryPhotosHelp.
  ///
  /// In id, this message translates to:
  /// **'Paling banyak {max} foto. Foto dikecilkan sebelum diunggah, dan lokasinya tidak ikut tersimpan.'**
  String memoryPhotosHelp(int max);

  /// No description provided for @memoryPhotosPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih foto'**
  String get memoryPhotosPick;

  /// No description provided for @memoryPhotoUnpick.
  ///
  /// In id, this message translates to:
  /// **'Batal pilih foto {index}'**
  String memoryPhotoUnpick(int index);

  /// No description provided for @memoryWherePrivateHelp.
  ///
  /// In id, this message translates to:
  /// **'Pasanganmu tidak akan melihat kenangan ini.'**
  String get memoryWherePrivateHelp;

  /// No description provided for @errorMemoryTitleRequired.
  ///
  /// In id, this message translates to:
  /// **'Judul kenangan belum diisi.'**
  String get errorMemoryTitleRequired;

  /// No description provided for @errorPlaceLong.
  ///
  /// In id, this message translates to:
  /// **'Nama tempat paling banyak 100 karakter.'**
  String get errorPlaceLong;

  /// No description provided for @errorStoryLong.
  ///
  /// In id, this message translates to:
  /// **'Cerita paling banyak 10.000 karakter.'**
  String get errorStoryLong;

  /// No description provided for @galleryCounter.
  ///
  /// In id, this message translates to:
  /// **'{index} dari {total}'**
  String galleryCounter(int index, int total);

  /// No description provided for @galleryMakeCover.
  ///
  /// In id, this message translates to:
  /// **'Jadikan sampul'**
  String get galleryMakeCover;

  /// No description provided for @galleryIsCover.
  ///
  /// In id, this message translates to:
  /// **'Foto sampul'**
  String get galleryIsCover;

  /// No description provided for @galleryCoverSet.
  ///
  /// In id, this message translates to:
  /// **'Foto ini jadi sampul.'**
  String get galleryCoverSet;

  /// No description provided for @galleryDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get galleryDelete;

  /// No description provided for @galleryDeletedSnack.
  ///
  /// In id, this message translates to:
  /// **'Foto dihapus.'**
  String get galleryDeletedSnack;

  /// No description provided for @galleryTakenAt.
  ///
  /// In id, this message translates to:
  /// **'Diambil {date}, {time}'**
  String galleryTakenAt(String date, String time);

  /// No description provided for @galleryGone.
  ///
  /// In id, this message translates to:
  /// **'Foto ini sudah tidak ada.'**
  String get galleryGone;

  /// No description provided for @tripSaveAsMemory.
  ///
  /// In id, this message translates to:
  /// **'Simpan jadi kenangan'**
  String get tripSaveAsMemory;

  /// No description provided for @tripMemoriesTitle.
  ///
  /// In id, this message translates to:
  /// **'Kenangan'**
  String get tripMemoriesTitle;

  /// No description provided for @notifTapMissingMemory.
  ///
  /// In id, this message translates to:
  /// **'Kenangan itu belum tersedia di HP ini.'**
  String get notifTapMissingMemory;

  /// No description provided for @repeatAdd.
  ///
  /// In id, this message translates to:
  /// **'Ulangi'**
  String get repeatAdd;

  /// No description provided for @repeatSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Ulangi tugas'**
  String get repeatSheetTitle;

  /// No description provided for @repeatHowOften.
  ///
  /// In id, this message translates to:
  /// **'Seberapa sering?'**
  String get repeatHowOften;

  /// No description provided for @repeatNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak diulang'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In id, this message translates to:
  /// **'Tahunan'**
  String get repeatYearly;

  /// No description provided for @repeatEvery.
  ///
  /// In id, this message translates to:
  /// **'Setiap berapa?'**
  String get repeatEvery;

  /// No description provided for @repeatEveryDay.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Tiap hari} other{Tiap {count} hari}}'**
  String repeatEveryDay(int count);

  /// No description provided for @repeatEveryWeek.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Tiap minggu} other{Tiap {count} minggu}}'**
  String repeatEveryWeek(int count);

  /// No description provided for @repeatEveryMonth.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Tiap bulan} other{Tiap {count} bulan}}'**
  String repeatEveryMonth(int count);

  /// No description provided for @repeatEveryYear.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Tiap tahun} other{Tiap {count} tahun}}'**
  String repeatEveryYear(int count);

  /// No description provided for @repeatFewer.
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get repeatFewer;

  /// No description provided for @repeatMore.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get repeatMore;

  /// No description provided for @repeatNote.
  ///
  /// In id, this message translates to:
  /// **'Begitu tugas ini selesai, tugas berikutnya dibuat dengan tenggat baru.'**
  String get repeatNote;

  /// No description provided for @repeatShortMonth.
  ///
  /// In id, this message translates to:
  /// **'Di bulan yang lebih pendek, tenggatnya jatuh di hari terakhir bulan itu.'**
  String get repeatShortMonth;

  /// No description provided for @repeatLeapDay.
  ///
  /// In id, this message translates to:
  /// **'Di tahun biasa, tenggatnya jatuh pada 28 Februari.'**
  String get repeatLeapDay;

  /// No description provided for @repeatNextTask.
  ///
  /// In id, this message translates to:
  /// **'Tugas berikutnya: {date}'**
  String repeatNextTask(String date);

  /// No description provided for @taskCompletedRepeatSnack.
  ///
  /// In id, this message translates to:
  /// **'Tugas selesai. Yang berikutnya muncul setelah tersimpan di server.'**
  String get taskCompletedRepeatSnack;
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
