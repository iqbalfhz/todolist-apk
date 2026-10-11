import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Tarik untuk menyegarkan: kirim antrean sekarang juga, lalu tarik perubahan dari server.
Future<void> refreshFromServer(WidgetRef ref) async {
  await ref.read(accountProvider)?.sync.sync(retryNow: true);
}
