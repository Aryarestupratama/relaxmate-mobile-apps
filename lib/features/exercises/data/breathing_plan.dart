import 'package:relaxmate/features/exercises/data/breathing_phase.dart';

/// Rencana satu sesi latihan napas untuk durasi pilihan pengguna: berapa putaran penuh yang
/// paling mendekati durasi itu. Putaran tidak dipotong di tengah.
class BreathingPlan {
  const BreathingPlan(this.minutes);

  final int minutes;

  /// Lama satu putaran penuh dalam detik (jumlah semua tahap).
  static int get cycleSeconds => BreathingPhase.values
      .fold<int>(0, (total, phase) => total + phase.seconds);

  /// Banyak putaran, minimal satu.
  int get cycles {
    final rounded = (minutes * 60 / cycleSeconds).round();
    return rounded < 1 ? 1 : rounded;
  }
}
