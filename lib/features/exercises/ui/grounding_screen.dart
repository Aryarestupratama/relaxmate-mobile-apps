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
import 'package:relaxmate/features/exercises/ui/exercise_scaffold.dart';

/// SCR-M12: grounding 5-4-3-2-1 (FR-M014). Satu langkah per layar: lima titik kemajuan,
/// kata pembuka "Sebutkan", angka besar, lalu isi langkah dan satu petunjuk lembut khusus
/// indra itu, dengan tombol "Lanjut" (langkah terakhir: "Selesai"). Jumlah tidak diulang di
/// teks, dan nomor langkah hanya lewat titik (pembaca layar tetap membaca "Langkah 1 dari
/// 5"), supaya tidak ada dua angka yang bersaing. Berjalan lokal, tanpa AI, kuota, atau
/// internet. Hanya perlu masuk; tidak dibungkus `ConsentGate`.
class GroundingScreen extends ConsumerWidget {
  const GroundingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groundingControllerProvider);
    final controller = ref.read(groundingControllerProvider.notifier);

    return ExerciseScaffold(
      title: AppTexts.groundingTitle,
      body: state.finished
          ? ExerciseDoneView(
              title: AppTexts.groundingDoneTitle,
              body: AppTexts.groundingDoneBody,
              onRepeat: controller.restart,
            )
          : _GroundingStepView(state: state, onNext: controller.next),
    );
  }
}

class _GroundingStepView extends StatelessWidget {
  const _GroundingStepView({required this.state, required this.onNext});

  final GroundingState state;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final last = state.position >= state.total;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _StepDots(position: state.position, total: state.total),
            SizedBox(height: space.xl),
            // Hanya isi langkah yang berganti; titik dan tombol tetap di tempatnya.
            AnimatedSwitcher(
              duration: reduceMotion ? Duration.zero : RbMotion.screen,
              child: _StepContent(
                key: ValueKey<int>(state.index),
                step: state.step,
              ),
            ),
            SizedBox(height: space.xl),
            FilledButton(
              onPressed: onNext,
              child: Text(
                last ? AppTexts.exerciseDone : AppTexts.groundingNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lima titik kemajuan: langkah sekarang memanjang dan berwarna utama, yang sudah lewat
/// berwarna utama pudar, yang belum hanya bergaris. Hiasan; pembaca layar membaca
/// "Langkah x dari y".
class _StepDots extends StatelessWidget {
  const _StepDots({required this.position, required this.total});

  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: AppTexts.groundingProgress(position, total),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var step = 1; step <= total; step++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: space.xxs),
              child: AnimatedContainer(
                duration: reduceMotion ? Duration.zero : RbMotion.screen,
                curve: RbMotion.curve,
                width: step == position
                    ? RbSize.groundingDotActive
                    : RbSize.groundingDot,
                height: RbSize.groundingDot,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(RbSize.groundingDot),
                  color: step <= position
                      ? colors.primary.withValues(
                          alpha: step == position ? 1 : 0.35,
                        )
                      : colors.border,
                ),
              ),
            ),
        ],
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
        // Pembaca layar membacakan kalimat utuh sekali per langkah; tampilannya terbagi
        // tiga (kata pembuka, angka, isi) dan dibaca sebagai satu kalimat.
        Semantics(
          liveRegion: true,
          label: AppTexts.groundingStepLabel(step.count, step.instruction),
          excludeSemantics: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                AppTexts.groundingLead,
                textAlign: TextAlign.center,
                style: text.body.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: space.sm),
              Center(
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
              SizedBox(height: space.md),
              Text(
                step.instruction,
                textAlign: TextAlign.center,
                style: text.h2,
              ),
            ],
          ),
        ),
        SizedBox(height: space.xs),
        Text(
          step.hint,
          textAlign: TextAlign.center,
          style: text.small.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
