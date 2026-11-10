import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/features/settings/data/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pengaturan lokal di `shared_preferences` (tidak sensitif, tanpa jaringan). Gagal membaca
/// atau menulis tidak boleh mengganggu layar: bacaan jatuh ke nilai bawaan.
class SettingsRepository {
  const SettingsRepository();

  Future<AppSettings> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppSettings(
        breathingHaptics:
            prefs.getBool(AppConstants.settingsBreathingHapticsKey) ??
                AppSettings.defaults.breathingHaptics,
        privacyCover: prefs.getBool(AppConstants.settingsPrivacyCoverKey) ??
            AppSettings.defaults.privacyCover,
      );
    } on Object {
      return AppSettings.defaults;
    }
  }

  Future<void> write(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        AppConstants.settingsBreathingHapticsKey,
        settings.breathingHaptics,
      );
      await prefs.setBool(
        AppConstants.settingsPrivacyCoverKey,
        settings.privacyCover,
      );
    } on Object {
      // Pengaturan tetap berlaku selama aplikasi terbuka; hanya tidak tersimpan.
    }
  }
}

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => const SettingsRepository());
