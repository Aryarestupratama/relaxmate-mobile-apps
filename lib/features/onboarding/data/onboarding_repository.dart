import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penanda "sambutan sudah dilihat" di `shared_preferences` (tidak sensitif, tanpa
/// jaringan). Gagal membaca dianggap belum dilihat; gagal menulis tidak mengganggu layar
/// (sambutan paling banyak tampil sekali lagi pada pembukaan berikutnya).
class OnboardingRepository {
  const OnboardingRepository();

  Future<bool> isSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.settingsOnboardingSeenKey) ?? false;
    } on Object {
      return false;
    }
  }

  Future<void> markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.settingsOnboardingSeenKey, true);
    } on Object {
      // Tidak tersimpan: sambutan boleh tampil lagi pada pembukaan berikutnya.
    }
  }
}

final Provider<OnboardingRepository> onboardingRepositoryProvider =
    Provider<OnboardingRepository>((ref) => const OnboardingRepository());
