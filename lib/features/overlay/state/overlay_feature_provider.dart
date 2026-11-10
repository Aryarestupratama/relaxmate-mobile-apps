import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/startup/data/server_config_repository.dart';

/// `features.overlay` dari `GET /config` (API-M007): sakelar jarak jauh maskot mengambang
/// (R-M4). Dibaca sekali per pembukaan aplikasi. Gagal terbuka: tanpa internet atau galat server
/// dianggap nyala, supaya fitur yang sudah dinyalakan pengguna tidak hilang hanya karena
/// sinyal; mematikannya dari jauh berlaku begitu aplikasi berhasil terhubung.
final FutureProvider<bool> overlayFeatureProvider =
    FutureProvider<bool>((ref) async {
  try {
    final config = await ref
        .read(serverConfigRepositoryProvider)
        .fetch()
        .timeout(AppConstants.versionCheckTimeout);
    return config.overlayEnabled;
  } on ApiException {
    return true;
  } on TimeoutException {
    return true;
  }
});
