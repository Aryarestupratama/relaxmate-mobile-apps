/// Hasil pemeriksaan versi saat aplikasi dibuka.
enum VersionGateStatus {
  /// Boleh lanjut (versi cukup baru, atau pemeriksaan tidak bisa dilakukan).
  ok,

  /// Versi terpasang lebih lama dari `min_app_version` dari server.
  updateRequired,
}
