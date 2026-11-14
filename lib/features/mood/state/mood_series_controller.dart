import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/mood/data/mood_series_repository.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';

/// Pemilik deret mood untuk satu rentang hari (FR-M030). Satu instance per rentang; dibuang
/// saat tidak ada layar yang memakainya sehingga data tidak tertinggal antar akun (autoDispose).
/// Tanpa percobaan ulang otomatis (RULE-M044): gagal memuat menampilkan "Coba lagi".
class MoodSeriesController extends Notifier<MoodSeriesState> {
  MoodSeriesController(this.days);

  final int days;

  @override
  MoodSeriesState build() {
    // Dijalankan setelah `build` selesai agar `state` sudah terpasang.
    unawaited(Future<void>.microtask(load));
    return const MoodSeriesLoading();
  }

  /// Memuat dari awal (tampil memuat). Juga dipakai tombol "Coba lagi".
  Future<void> load() async {
    state = const MoodSeriesLoading();
    await _fetch(keepOnError: false);
  }

  /// Menyegarkan tanpa mengosongkan tampilan, mis. setelah mood baru dicatat. Bila gagal, data
  /// lama tetap tampil.
  Future<void> refresh() => _fetch(keepOnError: state is MoodSeriesReady);

  Future<void> _fetch({required bool keepOnError}) async {
    try {
      final series = await ref.read(moodSeriesRepositoryProvider).fetch(days);
      if (!ref.mounted) {
        return;
      }
      state = MoodSeriesReady(series);
    } on ApiException catch (error) {
      if (!ref.mounted || keepOnError) {
        return;
      }
      state = MoodSeriesFailed(error);
    }
  }
}

final moodSeriesControllerProvider = NotifierProvider.autoDispose
    .family<MoodSeriesController, MoodSeriesState, int>(
  MoodSeriesController.new,
);
