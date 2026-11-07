import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/consent/data/consent_prompt.dart';
import 'package:relaxmate/features/consent/data/consent_repository.dart';
import 'package:relaxmate/features/consent/data/consent_state.dart';
import 'package:relaxmate/features/consent/data/training_choice.dart';
import 'package:relaxmate/features/consent/state/consent_gate_state.dart';

/// Pemilik keadaan consent (FR-M002). Memeriksa status setelah pengguna masuk dan email-nya
/// terverifikasi, lalu menyimpan persetujuan. Status dibaca ulang setiap identitas pengguna
/// berganti (masuk, keluar), jadi consent akun lain tidak terbawa.
///
/// Metode yang gagal melempar `ApiException` (pesannya aman ditampilkan).
class ConsentController extends Notifier<ConsentGateState> {
  int _epoch = 0;

  @override
  ConsentGateState build() {
    _epoch++;
    final identity = ref.watch(authControllerProvider.select(_identityOf));
    if (identity != null) {
      // Dijalankan setelah `build` selesai agar `state` sudah terpasang.
      unawaited(Future<void>.microtask(load));
    }
    return const ConsentChecking();
  }

  /// Email pengguna yang sudah terverifikasi; `null` selain itu. Hanya perubahan nilai ini
  /// yang memicu pemeriksaan ulang (pembaruan sesi biasa tidak).
  static String? _identityOf(AuthState auth) {
    if (auth is AuthAuthenticated && auth.user.emailVerified) {
      return auth.user.email;
    }
    return null;
  }

  /// Membaca teks dan status consent dari server (`GET /consent`). Juga dipakai tombol
  /// "Coba lagi".
  Future<void> load() async {
    final epoch = _epoch;
    state = const ConsentChecking();
    try {
      final prompt = await ref.read(consentRepositoryProvider).fetch();
      if (_stale(epoch)) {
        return;
      }
      state = prompt.state.complete
          ? const ConsentComplete()
          : ConsentRequired(prompt);
    } on ApiException catch (error) {
      if (_stale(epoch)) {
        return;
      }
      state = ConsentCheckFailed(error);
    }
  }

  /// Menyimpan persetujuan yang masih kurang: consent AI bila belum, lalu pilihan pelatihan
  /// bila belum dijawab dan [training] diisi. Kemajuan sebagian tetap dicatat bila langkah
  /// berikutnya gagal (galatnya dilempar ke layar), jadi percobaan ulang tidak mengulang
  /// langkah yang sudah berhasil.
  Future<void> submit({TrainingChoice? training}) async {
    final current = state;
    if (current is! ConsentRequired) {
      return;
    }

    final epoch = _epoch;
    final repository = ref.read(consentRepositoryProvider);
    var consent = current.prompt.state;
    try {
      if (!consent.aiGranted) {
        consent = await repository.grantAi();
      }
      if (!consent.trainingAnswered && training != null) {
        consent = await repository.setTraining(training);
      }
    } finally {
      _apply(epoch, current.prompt, consent);
    }
  }

  void _apply(int epoch, ConsentPrompt prompt, ConsentState consent) {
    if (_stale(epoch)) {
      return;
    }
    state = consent.complete
        ? const ConsentComplete()
        : ConsentRequired(prompt.withState(consent));
  }

  /// Pengguna sudah berganti atau provider sudah dibuang selama permintaan berjalan.
  bool _stale(int epoch) => epoch != _epoch || !ref.mounted;
}

final NotifierProvider<ConsentController, ConsentGateState>
    consentControllerProvider =
    NotifierProvider<ConsentController, ConsentGateState>(
  ConsentController.new,
);
