import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/onboarding/data/onboarding_repository.dart';

/// Apakah layar sambutan sudah dilihat di perangkat ini.
enum OnboardingStatus {
  /// Penanda sedang dibaca dari penyimpanan (beberapa milidetik saat aplikasi dibuka).
  loading,

  /// Belum pernah dilihat: tamu diarahkan ke sambutan.
  unseen,

  /// Sudah dilihat: tamu langsung ke Masuk.
  seen,
}

/// Pemilik penanda sambutan. Dibaca sekali saat dibuat; `markSeen` mengubah keadaan lebih
/// dulu lalu menyimpan, supaya router langsung mengikuti.
class OnboardingController extends Notifier<OnboardingStatus> {
  @override
  OnboardingStatus build() {
    unawaited(Future<void>.microtask(_load));
    return OnboardingStatus.loading;
  }

  Future<void> _load() async {
    final seen = await ref.read(onboardingRepositoryProvider).isSeen();
    // `markSeen` mungkin sudah berjalan selama membaca: jangan menimpanya dengan `unseen`.
    if (ref.mounted && state == OnboardingStatus.loading) {
      state = seen ? OnboardingStatus.seen : OnboardingStatus.unseen;
    }
  }

  Future<void> markSeen() async {
    state = OnboardingStatus.seen;
    await ref.read(onboardingRepositoryProvider).markSeen();
  }
}

final NotifierProvider<OnboardingController, OnboardingStatus>
    onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingStatus>(
  OnboardingController.new,
);
