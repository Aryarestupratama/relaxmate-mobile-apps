import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka halaman aplikasi di toko. Mengembalikan false bila gagal dibuka.
class StoreLauncher {
  const StoreLauncher();

  Future<bool> openStore() async {
    try {
      return await launchUrl(
        Uri.parse(AppConstants.storeUrl),
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      return false;
    }
  }
}

final Provider<StoreLauncher> storeLauncherProvider = Provider<StoreLauncher>(
  (ref) => const StoreLauncher(),
);
