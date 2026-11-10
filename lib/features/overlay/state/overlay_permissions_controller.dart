import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/overlay/data/overlay_permissions.dart';
import 'package:relaxmate/features/overlay/data/overlay_platform.dart';

/// Status izin maskot mengambang. Dibaca saat layar dibuka dan dibaca ulang setiap aplikasi
/// kembali ke depan (pengguna baru saja dari halaman izin sistem). Dibuang saat layar ditutup.
class OverlayPermissionsController extends AsyncNotifier<OverlayPermissions> {
  @override
  Future<OverlayPermissions> build() {
    return ref.read(overlayPlatformProvider).status();
  }

  /// Membaca ulang tanpa menampilkan indikator muat (nilai lama tetap tampil).
  Future<OverlayPermissions> refresh() async {
    final fresh = await ref.read(overlayPlatformProvider).status();
    if (ref.mounted) {
      state = AsyncData<OverlayPermissions>(fresh);
    }
    return fresh;
  }
}

final AsyncNotifierProvider<OverlayPermissionsController, OverlayPermissions>
    overlayPermissionsControllerProvider = AsyncNotifierProvider.autoDispose<
        OverlayPermissionsController, OverlayPermissions>(
  OverlayPermissionsController.new,
);
