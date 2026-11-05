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
