import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/ui/auth_scaffold.dart';
import 'package:relaxmate/features/consent/data/consent_prompt.dart';
import 'package:relaxmate/features/consent/data/training_choice.dart';
import 'package:relaxmate/features/consent/state/consent_controller.dart';
import 'package:relaxmate/features/consent/ui/consent_choice_tile.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M07: Consent AI dan persetujuan pelatihan (FR-M002). Teks dari server (API-M008).
/// Hanya bagian yang masih kurang yang ditampilkan, karena versi consent AI dan pelatihan
/// dinaikkan terpisah. Pilihan pelatihan tidak punya nilai awal. Menolak berarti keluar:
/// tanpa consent, fitur AI tidak bisa dipakai (OQ-MA12).
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({required this.prompt, super.key});

  final ConsentPrompt prompt;

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  TrainingChoice? _choice;
  String? _choiceError;
  String? _error;
  bool _submitting = false;

  void _select(TrainingChoice choice) {
    setState(() {
      _choice = choice;
      _choiceError = null;
    });
  }

  Future<void> _submit() async {
    final needsTraining = !widget.prompt.state.trainingAnswered;
    final choice = _choice;
    if (needsTraining && choice == null) {
      setState(() {
        _choiceError = AppTexts.consentChoiceRequired;
        _error = null;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _choiceError = null;
      _error = null;
    });

    try {
      await ref.read(consentControllerProvider.notifier).submit(
            training: needsTraining ? choice : null,
          );
      if (mounted) {
        setState(() => _submitting = false);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final fieldError = error.fieldErrors['choice'];
      setState(() {
        _submitting = false;
        _choiceError = fieldError;
        _error = fieldError == null ? error.message : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final prompt = widget.prompt;
    final needsAi = !prompt.state.aiGranted;
    final needsTraining = !prompt.state.trainingAnswered;
    final choiceError = _choiceError;
    final error = _error;
    final enabled = !_submitting;

    return AuthScaffold(
      title: needsAi ? prompt.aiTitle : AppTexts.consentTrainingTitle,
      children: <Widget>[
        if (needsAi) Text(prompt.aiText, style: text.body),
        if (needsAi && needsTraining) SizedBox(height: space.lg),
        if (needsTraining) ...<Widget>[
          Semantics(
            header: true,
            child: Text(prompt.trainingQuestion, style: text.h3),
          ),
          SizedBox(height: space.xs),
          Text(
            prompt.trainingText,
            style: text.small.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: space.md),
          ConsentChoiceTile(
            label: AppTexts.consentTrainingYes,
            selected: _choice == TrainingChoice.granted,
            onTap: enabled ? () => _select(TrainingChoice.granted) : null,
          ),
          SizedBox(height: space.xs),
          ConsentChoiceTile(
            label: AppTexts.consentTrainingNo,
            selected: _choice == TrainingChoice.denied,
            onTap: enabled ? () => _select(TrainingChoice.denied) : null,
          ),
          if (choiceError != null) ...<Widget>[
            SizedBox(height: space.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                choiceError,
                style: text.caption.copyWith(color: colors.danger),
              ),
            ),
          ],
        ],
        if (error != null) ...<Widget>[
          SizedBox(height: space.md),
          ErrorAlert(message: error),
        ],
        SizedBox(height: space.lg),
        FilledButton(
          onPressed: enabled ? _submit : null,
          child: Text(
            _submitting
                ? AppTexts.processing
                : needsAi
                    ? AppTexts.consentAgree
                    : AppTexts.consentSaveChoice,
          ),
        ),
        SizedBox(height: space.xs),
        TextButton(
          onPressed:
              enabled ? ref.read(authControllerProvider.notifier).logout : null,
          child: const Text(AppTexts.logout),
        ),
        // Jalan keluar bagi yang belum atau tidak menyetujui (OQ-MA12): latihan lokal dan
        // Pengaturan (hapus akun). Kontak bantuan sudah ada di kerangka layar.
        TextButton(
          onPressed: enabled ? () => context.go(AppRoutes.home) : null,
          child: const Text(AppTexts.consentHomeLink),
        ),
        TextButton(
          onPressed:
              enabled ? () => context.push<void>(AppRoutes.exercises) : null,
          child: const Text(AppTexts.consentExercisesLink),
        ),
        TextButton(
          onPressed:
              enabled ? () => context.push<void>(AppRoutes.settings) : null,
          child: const Text(AppTexts.consentSettingsLink),
        ),
      ],
    );
  }
}
