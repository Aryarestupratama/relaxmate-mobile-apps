import 'package:relaxmate/features/exercises/data/grounding_step.dart';

/// Keadaan grounding 5-4-3-2-1 (SCR-M12). Hanya di memori; hilang saat layar ditutup.
class GroundingState {
  const GroundingState({this.index = 0, this.finished = false});

  /// Indeks langkah yang tampil di `GroundingStep.values` (0 sampai 4).
  final int index;

  /// Kelima langkah sudah dilalui.
  final bool finished;

  GroundingStep get step => GroundingStep.values[index];

  /// Nomor langkah untuk ditampilkan, mulai dari 1.
  int get position => index + 1;

  int get total => GroundingStep.values.length;

  GroundingState copyWith({int? index, bool? finished}) {
    return GroundingState(
      index: index ?? this.index,
      finished: finished ?? this.finished,
    );
  }
}
