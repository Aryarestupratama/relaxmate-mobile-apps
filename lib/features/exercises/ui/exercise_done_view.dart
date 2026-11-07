import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/exercises/ui/exercise_disclaimer.dart';
import 'package:relaxmate/features/exercises/ui/leave_exercise.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// Layar penutup latihan napas dan grounding: sapaan hangat, "Selesai" (keluar), "Ulangi", dan
/// catatan bukan layanan medis dengan jalan ke kontak bantuan (RULE-M046).
class ExerciseDoneView extends StatelessWidget {
  const ExerciseDoneView({
    required this.title,
    required this.body,
    required this.onRepeat,
    super.key,
  });

  final String title;
  final String body;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Center(child: MateAvatar(size: MateAvatarSize.large)),
            SizedBox(height: space.md),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: text.h2,
              ),
            ),
            SizedBox(height: space.xs),
            Text(body, textAlign: TextAlign.center, style: text.body),
            SizedBox(height: space.sm),
            Text(
              AppTexts.exerciseClosing,
              textAlign: TextAlign.center,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.lg),
            FilledButton(
              onPressed: () => leaveExercise(context),
              child: const Text(AppTexts.exerciseDone),
            ),
            SizedBox(height: space.xs),
            OutlinedButton(
              onPressed: onRepeat,
              child: const Text(AppTexts.exerciseAgain),
            ),
            SizedBox(height: space.lg),
            const ExerciseDisclaimer(),
          ],
        ),
      ),
    );
  }
}
