import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M03 (versi teks): penanda RelaxMate sedang menulis balasan. Animasi titik menyusul
/// bersama animasi maskot (TASK-M030).
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.xxs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: space.md,
              vertical: space.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: RbRadius.bubbleBorder,
            ),
            child: Text(
              AppTexts.chatTyping,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
