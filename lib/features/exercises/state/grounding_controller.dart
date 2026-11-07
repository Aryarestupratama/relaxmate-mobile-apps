import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/exercises/state/grounding_state.dart';

/// Pemilik alur grounding 5-4-3-2-1 (FR-M014): satu langkah per layar, "Lanjut" sampai lima
/// langkah selesai. Lokal sepenuhnya; tanpa jaringan, tanpa AI, tanpa kuota.
class GroundingController extends Notifier<GroundingState> {
  @override
  GroundingState build() => const GroundingState();

  /// Pindah ke langkah berikutnya; setelah langkah terakhir latihan dinyatakan selesai.
  void next() {
    if (state.finished) {
      return;
    }
    if (state.position >= state.total) {
      state = state.copyWith(finished: true);
      return;
    }
    state = state.copyWith(index: state.index + 1);
  }

  /// Mulai lagi dari langkah pertama (dipakai tombol "Ulangi").
  void restart() {
    state = const GroundingState();
  }
}

final NotifierProvider<GroundingController, GroundingState>
    groundingControllerProvider =
    NotifierProvider.autoDispose<GroundingController, GroundingState>(
  GroundingController.new,
);
