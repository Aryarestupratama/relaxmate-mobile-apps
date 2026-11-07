import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/exercises/data/grounding_step.dart';
import 'package:relaxmate/features/exercises/state/grounding_controller.dart';
import 'package:relaxmate/features/exercises/state/grounding_state.dart';
import 'package:relaxmate/features/exercises/ui/exercise_done_view.dart';

/// SCR-M12: grounding 5-4-3-2-1 (FR-M014). Satu langkah per layar dengan tombol "Lanjut":
/// lihat 5, sentuh 4, dengar 3, cium 2, cicipi 1. Berjalan lokal, tanpa AI, kuota, atau
/// internet. Hanya perlu masuk; tidak dibungkus `ConsentGate`.
class GroundingScreen extends ConsumerWidget {
  const GroundingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groundingControllerProvider);
    final controller = ref.read(groundingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.groundingTitle)),
      body: SafeArea(
        child: state.finished
            ? ExerciseDoneView(
                title: AppTexts.groundingDoneTitle,
                body: AppTexts.groundingDoneBody,
                onRepeat: controller.restart,
              )
            : _GroundingStepView(state: state, onNext: controller.next),
      ),
    );
  }
}

class _GroundingStepView extends StatelessWidget {
  const _GroundingStepView({required this.state, required this.onNext});

  final GroundingState state;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              AppTexts.groundingProgress(state.position, state.total),
              textAlign: TextAlign.center,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.md),
            // Hanya isi langkah yang berganti; tombol "Lanjut" tetap di tempatnya.
            AnimatedSwitcher(
              duration: reduceMotion ? Duration.zero : RbMotion.screen,
              child: _StepContent(
                key: ValueKey<int>(state.index),
                step: state.step,
              ),
            ),
            SizedBox(height: space.lg),
            FilledButton(
              onPressed: onNext,
              child: const Text(AppTexts.groundingNext),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, super.key});

  final GroundingStep step;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Angka besar hanya hiasan; kalimat di bawahnya sudah menyebut jumlahnya.
        ExcludeSemantics(
          child: Center(
            child: Container(
              width: RbSize.groundingBadge,
              height: RbSize.groundingBadge,
              padding: EdgeInsets.all(space.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.softLavender,
                shape: BoxShape.circle,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${step.count}',
                  style: text.h1.copyWith(fontSize: RbSize.groundingNumber),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: space.md),
        // Pembaca layar membacakan tiap langkah baru.
        Semantics(
          liveRegion: true,
          child: Text(
            step.instruction,
            textAlign: TextAlign.center,
            style: text.h2,
          ),
        ),
        SizedBox(height: space.xs),
        Text(
          AppTexts.groundingHint,
          textAlign: TextAlign.center,
          style: text.small.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
