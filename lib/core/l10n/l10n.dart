import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Teks layar. Semua teks berbahasa Indonesia dan diambil dari `app_id.arb`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
