import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_error.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/domain/user.dart';
import '../../home/presentation/main_shell.dart';
import '../domain/household.dart';
import 'member_avatar.dart';

/// Ajak pasangan: kode undangan sendiri dan isian kode dari pasangan.
///
/// Kalau sudah berpasangan, layar ini menampilkan Ruang Bersama dan kedua
/// anggotanya, bukan kode.
class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final TextEditingController _code = TextEditingController();

  Invitation? _invitation;
  bool _loadingCode = false;
  bool _codeFailed = false;
  String? _joinError;
  bool _joining = false;

  /// Alur pertama kali: belum ada layar untuk kembali, dan "Nanti saja" menyelesaikan langkah ini.
  bool get _onboarding => !ref.read(onboardingProvider).pairingDone;

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  /// Ambil kode undangan aktif, atau buat yang baru. Butuh koneksi.
  Future<void> _loadCode() async {
    final account = ref.read(accountProvider);
    if (account == null || _loadingCode) return;

    // Kode dari profil ditampilkan dulu selagi yang terbaru diambil.
    final cached = (await account.profile.current())?.invitation;
    if (!mounted) return;
    setState(() {
      if (cached != null && cached.isActiveAt(DateTime.now())) _invitation = cached;
      _loadingCode = true;
      _codeFailed = false;
    });

    try {
      final invitation = await account.spaces.invitation();
      if (mounted) setState(() => _invitation = invitation);
    } on ApiError catch (error) {
      // Sudah punya pasangan: cache akan menyusul lewat sync.
      if (error.code == ApiErrorCode.sharedSpaceExists) {
        account.sync.sync().ignore();
      } else if (mounted) {
        setState(() => _codeFailed = _invitation == null);
      }
    } on NetworkFailure {
      if (mounted) setState(() => _codeFailed = _invitation == null);
    } finally {
      if (mounted) setState(() => _loadingCode = false);
    }
  }

  Future<void> _copy(Invitation invitation) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: invitation.code));
    messenger.showSnackBar(SnackBar(content: Text(l10n.pairingCopied)));
  }

  Future<void> _share(Invitation invitation) async {
    final text = context.l10n.pairingShareText(invitation.code, _expiryText(invitation));
    await SharePlus.instance.share(ShareParams(text: text));
  }

  static String _expiryText(Invitation invitation) =>
      DateFormat('EEE, d MMM HH.mm', dateLocale).format(invitation.expiresAt.toLocal());

  Future<void> _join() async {
    final l10n = context.l10n;
    final account = ref.read(accountProvider);
    if (account == null || _joining || !isValidInvitationCode(_code.text)) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _joining = true;
      _joinError = null;
    });

    try {
      await account.spaces.accept(_code.text);
      // Setelah berhasil gabung: sync, lalu Beranda.
      await account.sync.sync(retryNow: true);
      await ref.read(onboardingProvider.notifier).completePairing();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.pairingJoined)));
      context.go(Routes.home);
    } on ApiError catch (error) {
      if (mounted) setState(() => _joinError = error.messageFor('code'));
    } on NetworkFailure {
      if (mounted) setState(() => _joinError = l10n.needsConnection);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _later() async {
    await ref.read(onboardingProvider.notifier).completePairing();
    if (mounted) context.go(Routes.home);
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.home);

  @override
  Widget build(BuildContext context) {
    final household = ref.watch(householdProvider);
    final onboarding = _onboarding;

    return AppScaffold(
      child: PageBody(
        children: [
          ScreenHeader(onBack: onboarding ? null : _back),
          if (household == null)
            const SkeletonCard(lines: 4)
          else if (household.isPaired)
            ..._paired(context, household, onboarding)
          else
            ..._unpaired(context, household),
        ],
      ),
    );
  }

  /// Dua avatar besar dengan tanda tambah di tengah.
  Widget _hero(BuildContext context, Household household) {
    final palette = context.palette;
    final partner = household.partner;

    // Lencana di tengah menumpuk 8 di atas tiap avatar.
    const width = AppDimens.avatarMedium * 2 + AppDimens.navIndicatorHeight - AppDimens.gap16;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.gap8),
        child: Center(
          child: SizedBox(
            width: width,
            height: AppDimens.avatarMedium,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: MyAvatar(user: household.me, size: AppDimens.avatarMedium, filled: true),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: partner != null
                      ? MemberAvatar(member: partner, size: AppDimens.avatarMedium, filled: true)
                      : Container(
                          width: AppDimens.avatarMedium,
                          height: AppDimens.avatarMedium,
                          decoration: BoxDecoration(
                            color: palette.soft,
                            shape: BoxShape.circle,
                            border: Border.all(color: palette.accent, width: AppDimens.avatarBorderLarge),
                          ),
                          child: Icon(Symbols.person_rounded, size: AppDimens.iconXxl, color: palette.muted),
                        ),
                ),
                Container(
                  width: AppDimens.navIndicatorHeight,
                  height: AppDimens.navIndicatorHeight,
                  decoration: BoxDecoration(color: palette.primary, shape: BoxShape.circle),
                  child: Icon(
                    partner == null ? Symbols.add_rounded : Symbols.check_rounded,
                    size: AppDimens.iconMd,
                    color: palette.onPrimary,
                    weight: 700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _unpaired(BuildContext context, Household household) {
    final l10n = context.l10n;
    final palette = context.palette;
    final text = context.text;
    final invitation = _invitation;
    final canJoin = isValidInvitationCode(_code.text) && !_joining;

    return [
      _hero(context, household),
      const SizedBox(height: AppDimens.gap8),
      Semantics(
        header: true,
        child: Text(l10n.pairingTitle, style: text.heroTitle, textAlign: TextAlign.center),
      ),
      const SizedBox(height: AppDimens.gap6),
      Text(l10n.pairingBody, style: text.body, textAlign: TextAlign.center),
      const SizedBox(height: AppDimens.gap20),
      AppCard(
        semanticLabel: l10n.pairingYourCode,
        padding: const EdgeInsets.fromLTRB(
          AppDimens.cardPadding,
          AppDimens.gap8,
          AppDimens.cardPadding,
          AppDimens.cardPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.pairingYourCode, style: text.label)),
                TextButton.icon(
                  onPressed: invitation == null ? null : () => _copy(invitation),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap4)),
                  icon: const Icon(Symbols.content_copy_rounded, size: AppDimens.iconSm),
                  label: Text(l10n.pairingCopy),
                ),
              ],
            ),
            if (invitation != null) ...[
              _CodeBoxes(code: invitation.code),
              const SizedBox(height: AppDimens.gap8),
              Text(l10n.pairingExpires(_expiryText(invitation)), style: text.small, textAlign: TextAlign.center),
            ] else if (_codeFailed) ...[
              Text(l10n.pairingCodeLoadFailed, style: text.body),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _loadCode,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(l10n.commonRetry),
                ),
              ),
            ] else
              const SkeletonBox(height: AppDimens.codeBoxHeight, radius: AppDimens.codeBoxRadius),
          ],
        ),
      ),
      const SizedBox(height: AppDimens.gap12),
      PrimaryButton(
        label: l10n.pairingShare,
        icon: Symbols.share_rounded,
        onPressed: invitation == null ? null : () => _share(invitation),
      ),
      const SizedBox(height: AppDimens.gap20),
      ExcludeSemantics(
        child: Row(
          children: [
            Expanded(child: Divider(color: palette.line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap12),
              child: Text(l10n.pairingOr, style: text.caption),
            ),
            Expanded(child: Divider(color: palette.line)),
          ],
        ),
      ),
      const SizedBox(height: AppDimens.gap20),
      Text(l10n.pairingHaveCode, style: text.rowTitle),
      const SizedBox(height: AppDimens.gap8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _code,
              style: text.inputStrong.copyWith(letterSpacing: AppDimens.gap2),
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                TextInputFormatter.withFunction((_, next) {
                  // Seragam dengan server: huruf besar, tanpa spasi dan tanda hubung.
                  final code = normalizeInvitationCode(next.text);
                  final clipped = code.length > Limits.invitationCode ? code.substring(0, Limits.invitationCode) : code;
                  return TextEditingValue(
                    text: clipped,
                    selection: TextSelection.collapsed(offset: clipped.length),
                  );
                }),
              ],
              decoration: InputDecoration(hintText: l10n.pairingCodeHint, errorText: _joinError),
              onChanged: (_) => setState(() => _joinError = null),
              onSubmitted: (_) => _join(),
            ),
          ),
          const SizedBox(width: AppDimens.gap8),
          OutlinedButton(onPressed: canJoin ? _join : null, child: Text(l10n.pairingJoin)),
        ],
      ),
      const SizedBox(height: AppDimens.gap12),
      Center(
        child: TextButton(
          onPressed: _later,
          style: TextButton.styleFrom(foregroundColor: palette.muted, textStyle: text.chipSelected),
          child: Text(l10n.commonLater),
        ),
      ),
    ];
  }

  List<Widget> _paired(BuildContext context, Household household, bool onboarding) {
    final l10n = context.l10n;
    final text = context.text;
    final shared = household.shared!;
    final partner = household.partner;

    return [
      _hero(context, household),
      const SizedBox(height: AppDimens.gap8),
      Semantics(
        header: true,
        child: Text(l10n.pairedTitle, style: text.heroTitle, textAlign: TextAlign.center),
      ),
      const SizedBox(height: AppDimens.gap6),
      Text(l10n.pairedBody(partner?.name ?? l10n.labelPartner), style: text.body, textAlign: TextAlign.center),
      const SizedBox(height: AppDimens.gap20),
      AppCard(
        semanticLabel: l10n.pairedTitle,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.cardPadding, vertical: AppDimens.gap4),
        child: Column(
          children: [
            _memberRow(
              context,
              avatar: MyAvatar(user: household.me, size: AppDimens.avatarRow),
              name: l10n.pairedYou(household.me.name),
            ),
            if (partner != null) ...[
              const RowDivider(),
              _memberRow(
                context,
                avatar: MemberAvatar(member: partner, size: AppDimens.avatarRow),
                name: partner.name,
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: AppDimens.gap12),
      Text(
        l10n.pairedSince(formatDateMedium(ymdOf(shared.createdAt.toLocal()))),
        style: text.small,
        textAlign: TextAlign.center,
      ),
      if (onboarding) ...[
        const SizedBox(height: AppDimens.gap20),
        PrimaryButton(label: l10n.commonContinue, onPressed: _later),
      ],
    ];
  }

  Widget _memberRow(BuildContext context, {required Widget avatar, required String name}) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: AppDimens.rowMinHeightTall),
    child: Row(
      children: [
        avatar,
        const SizedBox(width: AppDimens.gap12),
        Expanded(child: Text(name, style: context.text.rowTitle)),
      ],
    ),
  );
}

/// Enam kotak karakter kode undangan.
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      label: context.l10n.pairingCodeSemantic(code.split('').join(' ')),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (final (index, character) in code.split('').indexed) ...[
              if (index > 0) const SizedBox(width: AppDimens.gap8),
              Expanded(
                child: Container(
                  height: AppDimens.codeBoxHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.soft,
                    borderRadius: BorderRadius.circular(AppDimens.codeBoxRadius),
                  ),
                  child: FittedBox(child: Text(character, style: context.text.homeTitle)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
