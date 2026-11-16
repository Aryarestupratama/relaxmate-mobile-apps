import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/exercises/data/breathing_phase.dart';
import 'package:relaxmate/features/exercises/state/breathing_controller.dart';
import 'package:relaxmate/features/exercises/state/breathing_state.dart';
import 'package:relaxmate/features/exercises/ui/breathing_guide.dart';
import 'package:relaxmate/features/exercises/ui/exercise_done_view.dart';
import 'package:relaxmate/features/exercises/ui/exercise_scaffold.dart';
import 'package:relaxmate/features/exercises/ui/leave_exercise.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// SCR-M11: latihan napas (FR-M014). Pilih durasi (1, 3, atau 5 menit) dan getar halus
/// opsional di satu kartu (dengan pratinjau lingkaran diam di atasnya), lalu ikuti lingkaran
/// sampai selesai; latar gradien lembut seperti Beranda. Berjalan lokal, tanpa AI, kuota, atau
/// internet. Hanya perlu masuk; tidak dibungkus `ConsentGate`.
class BreathingScreen extends ConsumerWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(breathingControllerProvider);
    final controller = ref.read(breathingControllerProvider.notifier);

    return ExerciseScaffold(
      title: AppTexts.breathingTitle,
      body: switch (state.stage) {
        BreathingStage.choosing => _BreathingChoice(
            state: state,
            onSelectMinutes: controller.selectMinutes,
            onHaptics: controller.setHaptics,
            onStart: controller.start,
          ),
        BreathingStage.running => _BreathingRun(state: state),
        BreathingStage.finished => ExerciseDoneView(
            title: AppTexts.breathingDoneTitle,
            body: AppTexts.breathingDoneBody(state.totalCycles),
            onRepeat: controller.reset,
          ),
      },
    );
  }
}

class _BreathingChoice extends StatelessWidget {
  const _BreathingChoice({
    required this.state,
    required this.onSelectMinutes,
    required this.onHaptics,
    required this.onStart,
  });

  final BreathingState state;
  final ValueChanged<int> onSelectMinutes;
  final ValueChanged<bool> onHaptics;
  final VoidCallback onStart;

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
            // Pratinjau diam: lingkaran napas sedang menguncup, belum bergerak.
            const Center(
              child: BreathingGuide(
                phase: BreathingPhase.exhale,
                size: RbSize.breathingPreview,
              ),
            ),
            SizedBox(height: space.md),
            Text(
              AppTexts.breathingIntro,
              textAlign: TextAlign.center,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.lg),
            FloatingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      AppTexts.breathingDurationLabel,
                      style: text.h3,
                    ),
                  ),
                  SizedBox(height: space.xs),
                  Wrap(
                    spacing: space.xs,
                    runSpacing: space.xs,
                    children: <Widget>[
                      for (final minutes in AppConstants.breathingMinuteChoices)
                        ChoiceChip(
                          label: Text(AppTexts.breathingMinutes(minutes)),
                          selected: minutes == state.minutes,
                          onSelected: (_) => onSelectMinutes(minutes),
                        ),
                    ],
                  ),
                  SizedBox(height: space.xs),
                  // Material transparan supaya riak sentuh tampil di atas kartu.
                  Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: state.haptics,
                      onChanged: onHaptics,
                      title: Text(AppTexts.breathingHaptics, style: text.body),
                      subtitle: Text(
                        AppTexts.breathingHapticsHint,
                        style: text.small.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: space.lg),
            FilledButton(
              onPressed: onStart,
              child: const Text(AppTexts.breathingStart),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathingRun extends StatelessWidget {
  const _BreathingRun({required this.state});

  final BreathingState state;

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
            Center(child: BreathingGuide(phase: state.phase)),
            SizedBox(height: space.lg),
            // Pembaca layar membacakan tiap pergantian tahap.
            Semantics(
              liveRegion: true,
              child: Text(
                state.phase.instruction,
                textAlign: TextAlign.center,
                style: text.h2,
              ),
            ),
            SizedBox(height: space.xs),
            Text(
              AppTexts.breathingCycle(state.cycle, state.totalCycles),
              textAlign: TextAlign.center,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.lg),
            OutlinedButton(
              onPressed: () => leaveExercise(context),
              child: const Text(AppTexts.breathingStop),
            ),
          ],
        ),
      ),
    );
  }
}
