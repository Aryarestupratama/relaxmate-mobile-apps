/// Konstanta produk di sisi klien (RULE-M026). Nilai yang berasal dari server
/// (batas pesan, kuota, versi minimum) sengaja tidak ada di sini.
abstract final class AppConstants {
  /// Awalan seluruh endpoint (Architecture-M bagian 5).
  static const String apiPrefix = '/api/v1';

  /// Timeout permintaan; lewat batas ini dianggap `ai_unavailable` (FR-M007).
  static const Duration requestTimeout = Duration(seconds: 20);
}
