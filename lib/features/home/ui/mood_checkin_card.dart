import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/checkin/ui/mood_blob_row.dart';
import 'package:relaxmate/features/home/ui/mood_done_card.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// SCR-M22, kartu mood di Beranda (FR-M013, FR-M029). Tiga keadaan:
/// - belum ada mood hari ini (atau "Ubah" ditekan): lima blob, satu ketukan mencatat;
/// - sudah tercatat: `MoodDoneCard` (blob besar berhalo, label, kalimat hangat sesuai mood,
///   jam WIB, "N dari 7 hari tercatat", tombol "Ubah");
/// - deret sedang dimuat: penanda memuat, supaya pilihan tidak berkedip lalu hilang bagi
///   yang sudah mengisi.
/// Blob memakai `MoodBlobRow` yang sudah ada; tidak memanggil AI. Kartu melayang (TASK-M074):
/// pilihan di atas putih, konfirmasi berwarna pastel sesuai mood.
class MoodCheckinCard extends ConsumerWidget {
  const MoodCheckinCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final state = ref.watch(checkinControllerProvider);
    final controller = ref.read(checkinControllerProvider.notifier);
    final today = ref.watch(todayMoodProvider);
    final series = ref.watch(
      moodSeriesControllerProvider(AppConstants.moodRangeShortDays),
    );

    if (today == null && series is MoodSeriesLoading && !state.submitting) {
      return const FloatingCard(
        child: SizedBox(
          height: RbSize.moodBlob,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (today != null && !state.editing) {
      return MoodDoneCard(
        entry: today,
        filledDays: series is MoodSeriesReady ? series.series.filledDays : null,
        totalDays: AppConstants.moodRangeShortDays,
        onChange: controller.startEditing,
      );
    }

    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(AppTexts.homeMoodTitle, style: text.h3),
          ),
          SizedBox(height: space.sm),
          MoodBlobRow(
            selected: state.submittingLevel,
            enabled: !state.submitting,
            onSelected: controller.submit,
          ),
          if (state.submitting)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: EdgeInsets.only(top: space.xs),
                child: Text(
                  AppTexts.homeMoodSaving,
                  textAlign: TextAlign.center,
                  style: text.small.copyWith(color: colors.textSecondary),
                ),
              ),
            ),
          if (state.error case final String message) ...<Widget>[
            SizedBox(height: space.sm),
            ErrorAlert(message: message),
          ],
          if (state.editing && !state.submitting)
            TextButton(
              onPressed: controller.cancelEditing,
              child: const Text(AppTexts.homeMoodCancel),
            ),
        ],
      ),
    );
  }
}
