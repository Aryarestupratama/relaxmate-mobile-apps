import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/checkin/ui/mood_blob_row.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/surface_card.dart';

/// SCR-M22, kartu mood di Beranda (FR-M013, FR-M029). Tiga keadaan:
/// - belum ada mood hari ini (atau "Ubah" ditekan): lima blob, satu ketukan mencatat;
/// - sudah tercatat: konfirmasi (label, jam WIB, "Ubah");
/// - deret sedang dimuat: penanda memuat, supaya pilihan tidak berkedip lalu hilang bagi
///   yang sudah mengisi.
/// Blob memakai `MoodBlobRow` yang sudah ada; tidak memanggil AI.
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
      return const SurfaceCard(
        child: SizedBox(
          height: RbSize.moodBlob,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (today != null && !state.editing) {
      return SurfaceCard(
        child: Row(
          children: <Widget>[
            Image.asset(
              today.level.asset,
              width: RbSize.moodBlob,
              height: RbSize.moodBlob,
              excludeFromSemantics: true,
            ),
            SizedBox(width: space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      AppTexts.homeMoodDone(today.level.label),
                      style: text.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    AppTexts.homeMoodRecordedAt(wibTimeLabel(today.loggedAt)),
                    style: text.small.copyWith(color: colors.textSecondary),
                  ),
                  TextButton(
                    onPressed: controller.startEditing,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      AppTexts.homeMoodChange,
                      style: text.button.copyWith(
                        color: colors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(AppTexts.homeMoodTitle, style: text.h3),
          ),
          Text(
            AppTexts.homeMoodHint,
            style: text.small.copyWith(color: colors.textSecondary),
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
