import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Catatan bahwa latihan bukan layanan medis, disertai jalan ke kontak bantuan (RULE-M046).
/// Tampil di daftar latihan dan di akhir tiap latihan.
class ExerciseDisclaimer extends StatelessWidget {
  const ExerciseDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          AppTexts.exercisesDisclaimer,
          textAlign: TextAlign.center,
          style: text.small.copyWith(color: colors.textSecondary),
        ),
        TextButton(
          onPressed: () => context.push<void>(AppRoutes.crisisContacts),
          child: const Text(AppTexts.crisisSeeAll),
        ),
      ],
    );
  }
}
