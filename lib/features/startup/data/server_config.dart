import 'package:relaxmate/core/api/json_map.dart';

/// Konfigurasi dari server (API-M007). Hanya kolom yang dipakai saat ini;
/// `[Assumption]` nama kolom sampai TASK-M014 menetapkan kontraknya.
class ServerConfig {
  const ServerConfig({this.minAppVersion, this.overlayEnabled = true});

  factory ServerConfig.fromJson(JsonMap json) {
    final value = json['min_app_version'];
    final features = json['features'];
    return ServerConfig(
      minAppVersion:
          value is String && value.trim().isNotEmpty ? value.trim() : null,
      // Hanya `false` yang eksplisit mematikan fitur; kolom hilang berarti nyala.
      overlayEnabled: !(features is Map && features['overlay'] == false),
    );
  }

  /// Versi aplikasi paling lama yang masih diizinkan; null berarti tanpa batas.
  final String? minAppVersion;

  /// `features.overlay`: sakelar jarak jauh untuk maskot mengambang (R-M4).
  final bool overlayEnabled;
}
