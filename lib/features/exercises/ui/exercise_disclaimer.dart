import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Catatan bahwa latihan bukan layanan medis (RULE-M046). Tampil di daftar latihan dan di
/// akhir tiap latihan. Jalan ke kontak bantuan tidak lagi berupa tombol di sini: semua layar
/// Latihan sudah punya tombol SOS di bilah atas (`RbAppBar`).
class ExerciseDisclaimer extends StatelessWidget {
  const ExerciseDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;

    return Text(
      AppTexts.exercisesDisclaimer,
      textAlign: TextAlign.center,
      style: text.small.copyWith(color: colors.textSecondary),
    );
  }
}
