import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/domain/user.dart';
import '../../home/presentation/main_shell.dart';
import '../../spaces/presentation/member_avatar.dart';
import '../../tasks/presentation/list_form_sheet.dart';

/// Profil: foto, nama panggilan, tanggal lahir, dan warna diri.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// Foto dipotong persegi dan dikecilkan ke ukuran ini sebelum diunggah.
  static const int _avatarSize = 512;

  final TextEditingController _name = TextEditingController();

  bool _filled = false;
  String? _color;
  BirthDate? _birthDate;
  bool _birthDateChanged = false;
  String? _nameError;
  bool _photoBusy = false;

  @override
  void initState() {
    super.initState();
    _fill(ref.read(profileProvider).value);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _fill(User? me) {
    if (me == null || _filled) return;
    _filled = true;
    _name.text = me.name;
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.settings);

  Future<void> _pickPhoto(ImageSource source) async {
    final l10n = context.l10n;
    final palette = context.palette;
    final messenger = ScaffoldMessenger.of(context);
    final account = ref.read(accountProvider);
    if (account == null || _photoBusy) return;

    setState(() => _photoBusy = true);
    try {
      final picked = await ImagePicker().pickImage(source: source, requestFullMetadata: false);
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.profileCropTitle,
            toolbarColor: palette.surface,
            toolbarWidgetColor: palette.text,
            backgroundColor: palette.bg,
            activeControlsWidgetColor: palette.primary,
            initAspectRatio: CropAspectRatioPreset.square,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
            lockAspectRatio: true,
          ),
        ],
      );
      if (cropped == null) return;

      final bytes = await FlutterImageCompress.compressWithFile(
        cropped.path,
        minWidth: _avatarSize,
        minHeight: _avatarSize,
        quality: 85,
      );
      if (bytes == null) throw const FormatException('Foto tidak bisa diolah');

      await account.profile.uploadAvatar(bytes);
      // Supaya foto baru juga tampil di daftar anggota Ruang Bersama.
      await account.spaces.refresh();
      messenger.showSnackBar(SnackBar(content: Text(l10n.profilePhotoUpdated)));
    } on ApiError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.messageFor('photo'))));
    } on NetworkFailure {
      messenger.showSnackBar(SnackBar(content: Text(l10n.profilePhotoFailed)));
    } on PlatformException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.profilePhotoFailed)));
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.profilePhotoFailed)));
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _removePhoto() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final account = ref.read(accountProvider);
    if (account == null || _photoBusy) return;

    setState(() => _photoBusy = true);
    try {
      await account.profile.deleteAvatar();
      await account.spaces.refresh();
      messenger.showSnackBar(SnackBar(content: Text(l10n.profilePhotoRemoved)));
    } on ApiError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } on NetworkFailure {
      messenger.showSnackBar(SnackBar(content: Text(l10n.needsConnection)));
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _photoOptions(User me) => showAppSheet<void>(
    context,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;

      Widget option(IconData icon, String label, VoidCallback onTap, {Color? color}) => InkWell(
        onTap: () {
          Navigator.of(sheetContext).pop();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
          child: Row(
            children: [
              Icon(icon, size: AppDimens.iconLg, color: color),
              const SizedBox(width: AppDimens.gap12),
              Text(label, style: sheetContext.text.rowTitle.copyWith(color: color)),
            ],
          ),
        ),
      );

      return AppSheet(
        title: l10n.profileChangePhoto,
        children: [
          option(Symbols.photo_camera_rounded, l10n.profileCamera, () => _pickPhoto(ImageSource.camera)),
          option(Symbols.image_rounded, l10n.profileGallery, () => _pickPhoto(ImageSource.gallery)),
          if (me.avatarUrl != null)
            option(Symbols.delete_rounded, l10n.profileRemovePhoto, _removePhoto, color: sheetContext.palette.danger),
        ],
      );
    },
  );

  Future<void> _editBirthDate(BirthDate? current) async {
    final result = await showDialog<_BirthDateResult>(
      context: context,
      builder: (_) => _BirthDateDialog(initial: current),
    );
    if (result == null || !mounted) return;

    setState(() {
      _birthDate = result.value;
      _birthDateChanged = true;
    });
  }

  Future<void> _save(User me) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final name = _name.text.trim();

    if (name.isEmpty) return setState(() => _nameError = l10n.errorNameRequired);
    if (textLength(name) > Limits.name) return setState(() => _nameError = l10n.errorNameLong);

    final profile = ref.read(accountProvider)?.profile;
    if (profile == null) return;

    // PATCH /me lewat antrean, jadi tersimpan walau sedang offline.
    if (_birthDateChanged) {
      await profile.update(name: name, color: _color ?? me.color, birthDate: _birthDate?.toContract());
    } else {
      await profile.update(name: name, color: _color ?? me.color);
    }

    messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    if (mounted) _back();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;

    ref.listen(profileProvider, (_, next) => _fill(next.value));
    final me = ref.watch(profileProvider).value;

    if (me == null) {
      return AppScaffold(
        child: PageBody(
          children: [
            ScreenHeader(title: l10n.profileTitle, onBack: _back),
            const SizedBox(height: AppDimens.gap16),
            const SkeletonCard(lines: 4),
          ],
        ),
      );
    }

    final color = _color ?? me.color;
    final birthDate = _birthDateChanged ? _birthDate : BirthDate.tryParse(me.birthDate);

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(title: l10n.profileTitle, onBack: _back),
          const SizedBox(height: AppDimens.gap16),
          Center(
            child: SizedBox(
              width: AppDimens.avatarLarge + AppDimens.gap4,
              height: AppDimens.avatarLarge + AppDimens.gap4,
              child: Stack(
                children: [
                  // Warna yang sedang dipilih langsung terlihat di avatar.
                  PersonAvatar(
                    name: _name.text.trim().isEmpty ? me.name : _name.text,
                    colorKey: color,
                    size: AppDimens.avatarLarge,
                    filled: true,
                    avatarUrl: me.avatarUrl,
                    cacheKey: avatarCacheKey(me.id, me.avatarVersion),
                    onImageError: () => refreshAvatarUrls(ref.read(accountProvider)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: palette.primary,
                      shape: CircleBorder(
                        side: BorderSide(color: palette.bg, width: AppDimens.avatarBorderLarge),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppIconButton(
                        icon: Symbols.photo_camera_rounded,
                        label: l10n.profileChangePhoto,
                        color: palette.onPrimary,
                        iconSize: AppDimens.iconMd,
                        onPressed: _photoBusy ? null : () => _photoOptions(me),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.gap10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimens.gap8,
            children: [
              AppFilterChip(
                label: l10n.profileCamera,
                icon: Symbols.photo_camera_rounded,
                selected: false,
                onTap: _photoBusy ? null : () => _pickPhoto(ImageSource.camera),
              ),
              AppFilterChip(
                label: l10n.profileGallery,
                icon: Symbols.image_rounded,
                selected: false,
                onTap: _photoBusy ? null : () => _pickPhoto(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gap6),
          Text(l10n.profilePhotoNote, style: text.small, textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.gap20),
          LabeledField(
            label: l10n.fieldName,
            child: TextField(
              controller: _name,
              style: text.input,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: l10n.fieldNameHint, errorText: _nameError),
              onChanged: (_) => setState(() => _nameError = null),
            ),
          ),
          const SizedBox(height: AppDimens.gap14),
          // Email belum bisa diubah di v0.1.
          LabeledField(
            label: l10n.fieldEmail,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppDimens.chipHeight),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(me.email, style: text.rowTitlePlain.copyWith(color: palette.muted)),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.gap10),
          LabeledField(
            label: l10n.profileBirthDate,
            help: l10n.profileBirthDateHelp,
            child: _FieldButton(
              label: birthDate?.format() ?? l10n.profileBirthDateEmpty,
              filled: birthDate != null,
              icon: Symbols.calendar_today_rounded,
              onTap: () => _editBirthDate(birthDate),
            ),
          ),
          const SizedBox(height: AppDimens.gap16),
          LabeledField(
            label: l10n.profileColor,
            child: ColorPicker(selected: color, onChanged: (key) => setState(() => _color = key)),
          ),
          const SizedBox(height: AppDimens.gap24),
          PrimaryButton(label: l10n.commonSave, onPressed: () => _save(me)),
        ],
      ),
    );
  }
}

/// Tombol berbentuk isian teks, untuk nilai yang dipilih lewat dialog.
class _FieldButton extends StatelessWidget {
  const _FieldButton({required this.label, required this.filled, required this.icon, required this.onTap});

  final String label;
  final bool filled;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
        side: BorderSide(color: palette.line, width: AppDimens.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppDimens.fieldHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.fieldSidePadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(label, style: context.text.input.copyWith(color: filled ? palette.text : palette.muted)),
                ),
                Icon(icon, size: AppDimens.iconMd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BirthDateResult {
  const _BirthDateResult(this.value);

  /// `null` berarti tanggal lahir dihapus.
  final BirthDate? value;
}

/// Pilih tanggal lahir. Tahun boleh dikosongkan.
class _BirthDateDialog extends StatefulWidget {
  const _BirthDateDialog({this.initial});

  final BirthDate? initial;

  @override
  State<_BirthDateDialog> createState() => _BirthDateDialogState();
}

class _BirthDateDialogState extends State<_BirthDateDialog> {
  late int _day = widget.initial?.day ?? 1;
  late int _month = widget.initial?.month ?? 1;
  late final TextEditingController _year = TextEditingController(text: widget.initial?.year?.toString() ?? '');
  String? _error;

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  void _submit() {
    final yearText = _year.text.trim();
    final date = BirthDate(year: yearText.isEmpty ? null : int.tryParse(yearText), month: _month, day: _day);

    // Dicek dengan kalender: 30 Februari ditolak, 29 Februari boleh tanpa tahun.
    if ((yearText.isNotEmpty && date.year == null) || !date.isValid) {
      return setState(() => _error = context.l10n.birthInvalid);
    }
    Navigator.of(context).pop(_BirthDateResult(date));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;

    return AlertDialog(
      title: Text(l10n.profileBirthDate),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: LabeledField(
                    label: l10n.birthDay,
                    child: DropdownButtonFormField<int>(
                      initialValue: _day,
                      style: text.input,
                      items: [for (var day = 1; day <= 31; day++) DropdownMenuItem(value: day, child: Text('$day'))],
                      onChanged: (day) => setState(() {
                        _day = day ?? _day;
                        _error = null;
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.gap8),
                Expanded(
                  flex: 3,
                  child: LabeledField(
                    label: l10n.birthMonth,
                    child: DropdownButtonFormField<int>(
                      initialValue: _month,
                      style: text.input,
                      isExpanded: true,
                      items: [
                        for (var month = 1; month <= 12; month++)
                          DropdownMenuItem(
                            value: month,
                            child: Text(DateFormat('MMMM', dateLocale).format(DateTime.utc(2000, month))),
                          ),
                      ],
                      onChanged: (month) => setState(() {
                        _month = month ?? _month;
                        _error = null;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gap12),
            LabeledField(
              label: l10n.birthYear,
              child: TextField(
                controller: _year,
                style: text.input,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                decoration: InputDecoration(errorText: _error),
                onChanged: (_) => setState(() => _error = null),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.initial != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const _BirthDateResult(null)),
            style: TextButton.styleFrom(foregroundColor: context.palette.danger),
            child: Text(l10n.birthClear),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}
