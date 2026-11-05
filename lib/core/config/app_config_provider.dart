import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_config.dart';

/// Konfigurasi aplikasi. Wajib di-override di `ProviderScope` oleh `bootstrap`.
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider belum di-override.'),
);
