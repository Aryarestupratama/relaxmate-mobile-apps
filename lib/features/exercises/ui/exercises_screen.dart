import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/exercises/ui/exercise_disclaimer.dart';
import 'package:relaxmate/features/exercises/ui/exercise_tile.dart';

/// Daftar latihan lokal (menu "Latihan" di chat): latihan napas (SCR-M11) dan grounding
/// (SCR-M12). Hanya perlu masuk; tidak dibungkus `ConsentGate` karena tanpa AI (RULE-M034,
/// ADR-M14). Isinya statis, jadi tidak ada status memuat atau galat.
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.exercisesTitle)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(space.lg),
          children: <Widget>[
            Text(
              AppTexts.exercisesIntro,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.md),
            ExerciseTile(
              icon: LucideIcons.wind,
              title: AppTexts.breathingTitle,
              subtitle: AppTexts.breathingSubtitle,
              onTap: () => context.push<void>(AppRoutes.breathing),
            ),
            ExerciseTile(
              icon: LucideIcons.eye,
              title: AppTexts.groundingTitle,
              subtitle: AppTexts.groundingSubtitle,
              onTap: () => context.push<void>(AppRoutes.grounding),
            ),
            SizedBox(height: space.lg),
            const ExerciseDisclaimer(),
          ],
        ),
      ),
    );
  }
}
