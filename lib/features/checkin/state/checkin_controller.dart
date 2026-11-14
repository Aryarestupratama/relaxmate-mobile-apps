import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/data/mood_repository.dart';
import 'package:relaxmate/features/checkin/state/checkin_state.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';

/// Pemilik alur mencatat mood di Beranda (FR-M013, OQ-M3): satu ketukan pada blob mencatat
/// Mood Entry lewat API-M018. Tidak mengirim pesan chat dan tidak memanggil AI; "Cerita ke
/// RelaxMate" hanya menawarkan chip pembuka di chat (OQ-MP5).
///
/// Gagal tidak diulang otomatis (RULE-M044); pengguna menekan blob lagi.
class CheckinController extends Notifier<CheckinState> {
  @override
  CheckinState build() => const CheckinState();

  void startEditing() {
    state = state.copyWith(editing: true, clearError: true);
  }

  void cancelEditing() {
    state = state.copyWith(editing: false, clearError: true);
  }

  Future<void> submit(MoodLevel level) async {
    if (state.submitting) {
      return;
    }
    state = state.copyWith(submittingLevel: level, clearError: true);
    try {
      final recorded = await ref.read(moodRepositoryProvider).record(level);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        recorded: recorded,
        editing: false,
        clearSubmitting: true,
      );
      // Grafik 7 hari disegarkan tanpa mengosongkan tampilan.
      await ref
          .read(
            moodSeriesControllerProvider(AppConstants.moodRangeShortDays)
                .notifier,
          )
          .refresh();
    } on ApiException catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        clearSubmitting: true,
        error: error.hasCode('mood_limit_reached')
            ? error.message
            : AppTexts.moodNotSaved,
      );
    }
  }
}

final NotifierProvider<CheckinController, CheckinState>
    checkinControllerProvider =
    NotifierProvider.autoDispose<CheckinController, CheckinState>(
  CheckinController.new,
);
