/// Keadaan izin yang dibutuhkan maskot mengambang (FR-M022).
class OverlayPermissions {
  const OverlayPermissions({
    required this.canDrawOverlays,
    required this.notificationsGranted,
  });

  /// Platform tidak mendukung (bukan Android, atau saluran native tidak ada).
  static const OverlayPermissions unsupported = OverlayPermissions(
    canDrawOverlays: false,
    notificationsGranted: false,
  );

  /// Izin "tampil di atas aplikasi lain" (`SYSTEM_ALERT_WINDOW`).
  final bool canDrawOverlays;

  /// Notifikasi aplikasi aktif (izin runtime Android 13+ atau tidak dimatikan pengguna).
  final bool notificationsGranted;
}
