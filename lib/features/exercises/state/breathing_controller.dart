import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/exercises/data/breathing_phase.dart';
import 'package:relaxmate/features/exercises/data/breathing_plan.dart';
import 'package:relaxmate/features/exercises/state/breathing_state.dart';

/// Pemilik alur latihan napas (FR-M014): memilih durasi, berjalan tahap demi tahap, selesai.
/// Berjalan sepenuhnya di perangkat; tanpa jaringan, tanpa AI, tanpa kuota.
///
/// Satu `Timer` sekali jalan dijadwalkan per tahap, jadi tidak ada ketukan berkala. Lingkaran
/// panduan menganimasikan dirinya sendiri dari tahap yang dipublikasikan di sini. Timer dibatalkan
/// saat layar ditutup.
class BreathingController extends Notifier<BreathingState> {
  Timer? _timer;

  @override
  BreathingState build() {
    ref.onDispose(_cancel);
    return const BreathingState();
  }

  void selectMinutes(int minutes) {
    if (state.stage != BreathingStage.choosing) {
      return;
    }
    state = state.copyWith(minutes: minutes);
  }

  void setHaptics(bool enabled) {
    state = state.copyWith(haptics: enabled);
  }

  /// Mulai dari putaran pertama, tahap tarik napas.
  void start() {
    if (state.stage == BreathingStage.running) {
      return;
    }
    _cancel();
    state = state.copyWith(
      stage: BreathingStage.running,
      cycle: 1,
      totalCycles: BreathingPlan(state.minutes).cycles,
      phase: BreathingPhase.inhale,
    );
    _enter(BreathingPhase.inhale);
  }

  /// Kembali memilih durasi (dipakai tombol "Ulangi").
  void reset() {
    _cancel();
    state = state.copyWith(stage: BreathingStage.choosing);
  }

  void _enter(BreathingPhase phase) {
    if (state.haptics) {
      unawaited(HapticFeedback.lightImpact());
    }
    _timer = Timer(phase.duration, _advance);
  }

  void _advance() {
    if (!ref.mounted || state.stage != BreathingStage.running) {
      return;
    }
    final next = state.phase.next;
    if (next != null) {
      state = state.copyWith(phase: next);
      _enter(next);
      return;
    }
    if (state.cycle >= state.totalCycles) {
      state = state.copyWith(stage: BreathingStage.finished);
      return;
    }
    state = state.copyWith(
      cycle: state.cycle + 1,
      phase: BreathingPhase.inhale,
    );
    _enter(BreathingPhase.inhale);
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

final NotifierProvider<BreathingController, BreathingState>
    breathingControllerProvider =
    NotifierProvider.autoDispose<BreathingController, BreathingState>(
  BreathingController.new,
);
