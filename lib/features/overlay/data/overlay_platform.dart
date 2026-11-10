import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/overlay/data/overlay_permissions.dart';

/// Jembatan ke Kotlin (`OverlayChannel`) untuk memeriksa dan mengarahkan izin maskot
/// mengambang (TASK-M032). Galat saluran (bukan Android, atau modul dilepas) dijawab dengan
/// nilai aman, bukan pengecualian, supaya layar tidak rusak.
class OverlayPlatform {
  const OverlayPlatform();

  static const MethodChannel _channel =
      MethodChannel('id.my.relaxboss.relaxmate/overlay');

  Future<OverlayPermissions> status() async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>('status');
      if (result == null) {
        return OverlayPermissions.unsupported;
      }
      return OverlayPermissions(
        canDrawOverlays: result['canDrawOverlays'] == true,
        notificationsGranted: result['notificationsGranted'] == true,
      );
    } on PlatformException {
      return OverlayPermissions.unsupported;
    } on MissingPluginException {
      return OverlayPermissions.unsupported;
    }
  }

  /// Membuka halaman izin "tampil di atas aplikasi lain" untuk aplikasi ini. Hasil izin tidak
  /// dikembalikan; periksa ulang `status()` saat aplikasi kembali ke depan.
  Future<bool> openOverlaySettings() => _invokeBool('openOverlaySettings');

  /// Meminta izin notifikasi (dialog sistem di Android 13+). `true` bila notifikasi aktif.
  Future<bool> requestNotifications() => _invokeBool('requestNotifications');

  Future<bool> openNotificationSettings() =>
      _invokeBool('openNotificationSettings');

  Future<bool> _invokeBool(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

final Provider<OverlayPlatform> overlayPlatformProvider =
    Provider<OverlayPlatform>((ref) => const OverlayPlatform());
