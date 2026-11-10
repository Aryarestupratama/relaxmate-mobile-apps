import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/settings/data/app_settings.dart';
import 'package:relaxmate/features/settings/data/settings_repository.dart';

/// Pemilik pengaturan lokal. Dimuat sekali saat aplikasi dibuka (oleh `PrivacyCover` di
/// akar aplikasi); sebelum selesai, nilai bawaan berlaku. Perubahan langsung berlaku di
/// layar dan disimpan tanpa menunggu.
class SettingsController extends Notifier<AppSettings> {
  bool _touched = false;

  @override
  AppSettings build() {
    unawaited(Future<void>.microtask(_load));
    return AppSettings.defaults;
  }

  Future<void> _load() async {
    final stored = await ref.read(settingsRepositoryProvider).read();
    // Pengguna sudah mengubah sesuatu selama membaca: jangan menimpanya.
    if (ref.mounted && !_touched) {
      state = stored;
    }
  }

  Future<void> setBreathingHaptics(bool enabled) {
    return _update(state.copyWith(breathingHaptics: enabled));
  }

  Future<void> setPrivacyCover(bool enabled) {
    return _update(state.copyWith(privacyCover: enabled));
  }

  Future<void> setOverlayEnabled(bool enabled) {
    return _update(state.copyWith(overlayEnabled: enabled));
  }

  Future<void> _update(AppSettings next) async {
    _touched = true;
    state = next;
    await ref.read(settingsRepositoryProvider).write(next);
  }
}

final NotifierProvider<SettingsController, AppSettings>
    settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
