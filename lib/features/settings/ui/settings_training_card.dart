import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/consent/data/consent_prompt.dart';
import 'package:relaxmate/features/consent/data/training_choice.dart';
import 'package:relaxmate/features/consent/ui/consent_choice_tile.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// CMP-M69: kartu persetujuan pelatihan di Pengaturan: pertanyaan dan penjelasan dari server
/// (`GET /consent`), lalu dua pilihan tunggal (`ConsentChoiceTile`). Pilihan dapat diubah
/// kapan saja; saat [saving] kedua pilihan dinonaktifkan.
class SettingsTrainingCard extends StatelessWidget {
  const SettingsTrainingCard({
    required this.prompt,
    required this.saving,
    required this.onChoose,
    super.key,
  });

  final ConsentPrompt prompt;
  final bool saving;
  final ValueChanged<TrainingChoice> onChoose;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final current = prompt.state.trainingChoice;

    return FloatingCard(
      padding: EdgeInsets.all(space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(prompt.trainingQuestion, style: text.body),
          SizedBox(height: space.xxs),
          Text(
            prompt.trainingText,
            style: text.small.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: space.sm),
          ConsentChoiceTile(
            label: AppTexts.consentTrainingYes,
            selected: current == TrainingChoice.granted,
            onTap: saving ? null : () => onChoose(TrainingChoice.granted),
          ),
          SizedBox(height: space.xs),
          ConsentChoiceTile(
            label: AppTexts.consentTrainingNo,
            selected: current == TrainingChoice.denied,
            onTap: saving ? null : () => onChoose(TrainingChoice.denied),
          ),
        ],
      ),
    );
  }
}
