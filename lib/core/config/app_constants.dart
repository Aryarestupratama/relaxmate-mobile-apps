/// Konstanta produk di sisi klien (RULE-M026). Nilai yang berasal dari server
/// (batas pesan, kuota, versi minimum) sengaja tidak ada di sini.
abstract final class AppConstants {
  /// Awalan seluruh endpoint (Architecture-M bagian 5).
  static const String apiPrefix = '/api/v1';

  /// Timeout permintaan; lewat batas ini dianggap `ai_unavailable` (FR-M007).
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Pemeriksaan versi saat pembuka tidak boleh menahan aplikasi lama-lama.
  static const Duration versionCheckTimeout = Duration(seconds: 5);

  /// Nama kunci token di penyimpanan aman.
  static const String tokenStorageKey = 'auth_token';

  /// Halaman aplikasi di Play Store. `[Assumption]` Application ID A-MA5.
  static const String storeUrl =
      'https://play.google.com/store/apps/details?id=id.my.relaxboss.relaxmate';
}
