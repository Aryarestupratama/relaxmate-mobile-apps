import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/overlay/data/overlay_platform.dart';
import 'package:relaxmate/features/overlay/data/overlay_snooze_repository.dart';
import 'package:relaxmate/features/overlay/state/overlay_feature_provider.dart';
import 'package:relaxmate/features/settings/state/settings_controller.dart';

/// Pemeriksaan saat layar utama (chat) dibuka, hanya Android. Hasil `true` berarti tawarkan
/// menyalakan maskot lagi.
///
/// 1. Sakelar jarak jauh mati: layanan dihentikan dan pilihan dimatikan (R-M4).
/// 2. Waktu istirahat sudah lewat, layanan tidak berjalan, dan izin overlay masih ada
///    (mis. setelah "Istirahat sampai besok"): tawarkan. Menyalakan sendiri dari latar
///    belakang tidak dilakukan (Android 15, Architecture-M 6.4).
final FutureProvider<bool> overlayHomeProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return false;
  }
  final platform = ref.read(overlayPlatformProvider);
  final status = await platform.status();

  final featureOn = await ref.watch(overlayFeatureProvider.future);
  if (!featureOn) {
    if (status.running) {
      await platform.stop();
    }
    final settings = ref.read(settingsControllerProvider);
    if (settings.overlayEnabled) {
      await ref.read(settingsControllerProvider.notifier).setOverlayEnabled(
            false,
          );
    }
    return false;
  }

  final snoozeUntil = await ref.read(overlaySnoozeRepositoryProvider).read();
  if (snoozeUntil == null || snoozeUntil.isAfter(DateTime.now())) {
    return false;
  }
  return status.canDrawOverlays && !status.running;
});

/// Waktu istirahat yang masih berlaku, untuk layar Maskot mengambang. `null` bila tidak
/// sedang istirahat.
final FutureProvider<DateTime?> overlayRestProvider =
    FutureProvider.autoDispose<DateTime?>((ref) async {
  final until = await ref.read(overlaySnoozeRepositoryProvider).read();
  if (until == null || !until.isAfter(DateTime.now())) {
    return null;
  }
  return until;
});
