import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/journal/ui/journal_line_height.dart';
import 'package:relaxmate/features/journal/ui/journal_rules_painter.dart';

/// Kolom menulis berlatar garis buku (SCR-M24). Tinggi tumbuh mengikuti isi, minimal
/// [AppConstants.journalMinLines] baris; halaman yang menggulir, bukan kolomnya. Panjang dibatasi
/// [AppConstants.moodNoteMaxChars] (kemudahan saja; server tetap memvalidasi, RULE-M023).
/// Pembelajaran keyboard dimatikan karena isinya pribadi (RULE-M074). Isi hanya di
/// [controller] di memori.
class JournalLinedField extends StatelessWidget {
  const JournalLinedField({
    required this.controller,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final lineHeight = journalLineHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: JournalRulesPainter(
                    lineHeight: lineHeight,
                    color: colors.border,
                  ),
                ),
              ),
            ),
            TextField(
              controller: controller,
              enabled: enabled,
              minLines: AppConstants.journalMinLines,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              enableIMEPersonalizedLearning: false,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(
                  AppConstants.moodNoteMaxChars,
                ),
              ],
              style: text.journal,
              strutStyle: journalStrut,
              cursorColor: colors.primary,
              decoration: InputDecoration.collapsed(
                hintText: AppTexts.journalHint,
                hintStyle: text.journal.copyWith(color: colors.textMuted),
              ),
            ),
          ],
        ),
        SizedBox(height: space.xs),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => Align(
            alignment: Alignment.centerRight,
            child: Text(
              AppTexts.journalCounter(
                value.text.runes.length,
                AppConstants.moodNoteMaxChars,
              ),
              style: text.caption.copyWith(color: colors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}
