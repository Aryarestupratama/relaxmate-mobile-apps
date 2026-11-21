import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/checkin/data/mood_arousal.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/data/mood_repository.dart';
import 'package:relaxmate/features/checkin/state/checkin_state.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';

/// Pemilik alur mencatat mood (FR-M013, FR-M032). Memilih blob membuka halaman menulis
/// (SCR-M24); halaman itu memanggil [submit] untuk menyimpan mood, tenaga, dan catatan
/// opsional lewat API-M018. Tidak mengirim pesan chat dan tidak memanggil AI; "Cerita ke
/// RelaxMate" hanya menawarkan chip pembuka di chat (OQ-MP5).
///
/// Isi catatan hanya lewat parameter: tidak disimpan di state dan tidak dicatat (RULE-M074).
/// Gagal tidak diulang otomatis (RULE-M044); pengguna menekan simpan lagi.
class CheckinController extends Notifier<CheckinState> {
  @override
  CheckinState build() => const CheckinState();

  void startEditing() {
    state = state.copyWith(editing: true, clearError: true);
  }

  void cancelEditing() {
    state = state.copyWith(editing: false, clearError: true);
  }

  /// Dipanggil halaman menulis saat dibuka, supaya galat sebelumnya tidak ikut tampil.
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// `true` bila tersimpan. Gagal mengisi [CheckinState.error] dan mengembalikan `false`.
  Future<bool> submit(
    MoodLevel level, {
    String? note,
    MoodArousal? arousal,
  }) async {
    if (state.submitting) {
      return false;
    }
    state = state.copyWith(submittingLevel: level, clearError: true);
    try {
      final recorded = await ref
          .read(moodRepositoryProvider)
          .record(level, note: note, arousal: arousal);
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(
        recorded: recorded,
        editing: false,
        clearSubmitting: true,
      );
      // Grafik 7 hari disegarkan di latar tanpa mengosongkan tampilan.
      unawaited(
        ref
            .read(
              moodSeriesControllerProvider(AppConstants.moodRangeShortDays)
                  .notifier,
            )
            .refresh(),
      );
      return true;
    } on ApiException catch (error) {
      if (!ref.mounted) {
        return false;
      }
      state = state.copyWith(
        clearSubmitting: true,
        error: error.hasCode('mood_limit_reached') ||
                error.hasCode('validation_failed')
            ? error.message
            : AppTexts.moodNotSaved,
      );
      return false;
    }
  }
}

final NotifierProvider<CheckinController, CheckinState>
    checkinControllerProvider =
    NotifierProvider.autoDispose<CheckinController, CheckinState>(
  CheckinController.new,
);
