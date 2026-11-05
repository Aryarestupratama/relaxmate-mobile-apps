import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/config/app_version.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/startup/data/server_config_repository.dart';
import 'package:relaxmate/features/startup/state/version_gate_status.dart';

/// Memeriksa `min_app_version` sekali per pembukaan aplikasi (SCR-M01).
///
/// Gagal terbuka (fail-open): tanpa internet, timeout, atau galat server tetap
/// mengizinkan aplikasi lanjut, agar kontak bantuan dan latihan tetap bisa dipakai
/// offline (RULE-M034, NFR-M06). Hanya versi yang terbukti terlalu lama yang diblokir.
final FutureProvider<VersionGateStatus> versionGateProvider =
    FutureProvider<VersionGateStatus>((ref) async {
  final repository = ref.read(serverConfigRepositoryProvider);
  final installedFuture = ref.read(appVersionProvider.future);

  try {
    final installed = await installedFuture;
    final config =
        await repository.fetch().timeout(AppConstants.versionCheckTimeout);
    final minimum = config.minAppVersion;

    if (minimum != null && AppVersion.isOlder(installed, minimum)) {
      return VersionGateStatus.updateRequired;
    }
    return VersionGateStatus.ok;
  } on ApiException {
    return VersionGateStatus.ok;
  } on TimeoutException {
    return VersionGateStatus.ok;
  }
});
