import 'package:relaxmate/core/api/json_map.dart';

/// Konfigurasi dari server (API-M007). Hanya kolom yang dipakai saat ini;
/// `[Assumption]` nama kolom sampai TASK-M014 menetapkan kontraknya.
class ServerConfig {
  const ServerConfig({this.minAppVersion});

  factory ServerConfig.fromJson(JsonMap json) {
    final value = json['min_app_version'];
    return ServerConfig(
      minAppVersion:
          value is String && value.trim().isNotEmpty ? value.trim() : null,
    );
  }

  /// Versi aplikasi paling lama yang masih diizinkan; null berarti tanpa batas.
  final String? minAppVersion;
}
