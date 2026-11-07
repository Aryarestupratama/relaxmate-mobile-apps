import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/features/exercises/data/breathing_phase.dart';

/// Tahap layar latihan napas (SCR-M11).
enum BreathingStage { choosing, running, finished }

/// Keadaan latihan napas. Hanya di memori; hilang saat layar ditutup.
class BreathingState {
  const BreathingState({
    this.stage = BreathingStage.choosing,
    this.minutes = AppConstants.breathingDefaultMinutes,
    this.cycle = 1,
    this.totalCycles = 0,
    this.phase = BreathingPhase.inhale,
    this.haptics = false,
  });

  final BreathingStage stage;

  /// Durasi pilihan pengguna dalam menit.
  final int minutes;

  /// Putaran yang sedang berjalan (mulai dari 1) dan banyak putaran sesi ini.
  final int cycle;
  final int totalCycles;

  /// Tahap napas yang sedang berjalan.
  final BreathingPhase phase;

  /// Getar halus di setiap pergantian tahap (opsional, bawaan mati).
  final bool haptics;

  BreathingState copyWith({
    BreathingStage? stage,
    int? minutes,
    int? cycle,
    int? totalCycles,
    BreathingPhase? phase,
    bool? haptics,
  }) {
    return BreathingState(
      stage: stage ?? this.stage,
      minutes: minutes ?? this.minutes,
      cycle: cycle ?? this.cycle,
      totalCycles: totalCycles ?? this.totalCycles,
      phase: phase ?? this.phase,
      haptics: haptics ?? this.haptics,
    );
  }
}
