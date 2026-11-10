import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Waktu istirahat maskot. Ditulis oleh layanan Kotlin ("Istirahat 1 jam" atau "sampai besok")
/// dan dibersihkan dari sini saat pengguna menyalakan kembali atau menolak tawaran. Selalu
/// dibaca ulang dari disk karena sisi native menulis berkas yang sama. Gagal baca dianggap
/// tidak istirahat.
class OverlaySnoozeRepository {
  const OverlaySnoozeRepository();

  Future<DateTime?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final millis = prefs.getInt(AppConstants.overlaySnoozeUntilKey) ?? 0;
      return millis > 0 ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
    } on Object {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.overlaySnoozeUntilKey, 0);
    } on Object {
      // Tawaran mungkin muncul lagi; tidak berbahaya.
    }
  }
}

final Provider<OverlaySnoozeRepository> overlaySnoozeRepositoryProvider =
    Provider<OverlaySnoozeRepository>((ref) => const OverlaySnoozeRepository());
