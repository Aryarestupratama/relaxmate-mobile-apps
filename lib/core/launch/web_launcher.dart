import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka halaman web di peramban perangkat (mis. Ketentuan dan Kebijakan Privasi).
/// Mengembalikan false bila gagal dibuka.
class WebLauncher {
  const WebLauncher();

  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}

final Provider<WebLauncher> webLauncherProvider = Provider<WebLauncher>(
  (ref) => const WebLauncher(),
);
