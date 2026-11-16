import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/checkin/ui/mood_blob_row.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// Isi mood hari ini langsung dari halaman Mood Tracker, memakai `MoodBlobRow` dan
/// `CheckinController` yang sama dengan Beranda. Hanya dipasang oleh `MoodScreen` selama mood
/// hari ini belum tercatat; setelah tersimpan kartu ini hilang dan semua bagian halaman
/// menyegarkan diri.
class MoodQuickLog extends ConsumerWidget {
  const MoodQuickLog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final state = ref.watch(checkinControllerProvider);
    final controller = ref.read(checkinControllerProvider.notifier);

    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(AppTexts.moodLogTitle, style: text.h3),
          ),
          SizedBox(height: space.xxs),
          Text(
            AppTexts.moodLogHint,
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
        ],
      ),
    );
  }
}
