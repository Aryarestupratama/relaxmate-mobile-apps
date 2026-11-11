import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/app.dart';
import 'package:relaxmate/config_error_app.dart';
import 'package:relaxmate/core/config/app_config.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/config/app_flavor.dart';

/// Titik masuk bersama untuk semua flavor.
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  _silenceReleaseLogs();

  // Hanya portrait pada rilis pertama (Design-M A-D1).
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  final config = _loadConfig(flavor);
  if (config == null) {
    runApp(const ConfigErrorApp());
    return;
  }

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const RelaxMateApp(),
    ),
  );
}

AppConfig? _loadConfig(AppFlavor flavor) {
  try {
    return AppConfig.load(flavor);
  } on AppConfigException {
    return null;
  }
}

/// Pada build rilis tidak ada keluaran log dari aplikasi (RULE-M040). Galat yang lolos ke
/// kerangka kerja biasanya dicetak lengkap dengan pesan dan jejak tumpukan, yang bisa memuat
/// teks dari pengguna. Build debug tetap memakai perilaku bawaan agar pengembangan tidak buta.
void _silenceReleaseLogs() {
  if (!kReleaseMode) {
    return;
  }
  debugPrint = (String? message, {int? wrapWidth}) {};
  FlutterError.onError = (FlutterErrorDetails details) {};
  WidgetsBinding.instance.platformDispatcher.onError =
      (Object error, StackTrace stack) => true;
}
