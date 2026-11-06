import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/config/app_flavor.dart';

/// Galat konfigurasi build. `code` hanya kode singkat dan tidak memuat URL.
class AppConfigException implements Exception {
  const AppConfigException(this.code);

  final String code;

  @override
  String toString() => 'AppConfigException($code)';
}

/// Konfigurasi runtime dari flavor dan `--dart-define` (RULE-M026).
/// URL API tidak pernah ditulis di kode.
class AppConfig {
  const AppConfig._({required this.flavor, required this.apiBaseUrl});

  static const String _rawApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  final AppFlavor flavor;

  /// Alamat dasar API, sudah mengandung `/api/v1`, tanpa garis miring penutup.
  final Uri apiBaseUrl;

  /// Alamat halaman web RelaxBoss (mis. `/ketentuan`). Web dan API satu aplikasi
  /// Laravel di host yang sama, jadi tidak ada URL kedua yang ditulis di klien
  /// (RULE-M026).
  Uri webUri(String path) => apiBaseUrl.replace(path: path);

  /// Membaca `API_BASE_URL` dari `--dart-define`.
  /// `rawApiBaseUrl` hanya untuk pengujian manual atau unit test.
  ///
  /// Aturan: wajib terisi, hanya `http`/`https`, tanpa path, query, atau fragmen.
  /// Flavor `prod` wajib `https` (RULE-M048).
  factory AppConfig.load(AppFlavor flavor, {String? rawApiBaseUrl}) {
    final raw = (rawApiBaseUrl ?? _rawApiBaseUrl).trim();
    if (raw.isEmpty) {
      throw const AppConfigException('missing_api_base_url');
    }

    final uri = Uri.tryParse(raw);
    final validScheme =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (uri == null ||
        !validScheme ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw const AppConfigException('invalid_api_base_url');
    }

    if (flavor.isProd && uri.scheme != 'https') {
      throw const AppConfigException('insecure_api_base_url');
    }

    return AppConfig._(
      flavor: flavor,
      apiBaseUrl: uri.replace(path: AppConstants.apiPrefix),
    );
  }
}
