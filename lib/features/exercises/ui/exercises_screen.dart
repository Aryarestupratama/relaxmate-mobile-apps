import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/exercises/ui/exercise_disclaimer.dart';
import 'package:relaxmate/features/exercises/ui/exercise_scaffold.dart';
import 'package:relaxmate/features/exercises/ui/exercise_tile.dart';
import 'package:relaxmate/shared/widgets/app_bottom_nav.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';
import 'package:relaxmate/shared/widgets/tab_back_scope.dart';

/// Daftar latihan lokal (tab Latihan di navigasi bawah): latihan napas (SCR-M11) dan grounding
/// (SCR-M12). Latar gradien lembut seperti Beranda, sapaan pendek, dua kartu pilihan, lalu
/// catatan bukan layanan medis. Hanya perlu masuk; tidak dibungkus `ConsentGate` karena tanpa
/// AI (RULE-M034, ADR-M14). Isinya statis, jadi tidak ada status memuat atau galat. Gerak
/// hanya masuk berurutan sekali (`RbEntrance`).
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return TabBackScope(
      child: ExerciseScaffold(
        title: AppTexts.exercisesTitle,
        bottomNavigationBar: const AppBottomNav(current: AppTab.exercises),
        body: ListView(
          padding: EdgeInsets.fromLTRB(space.lg, space.md, space.lg, space.lg),
          children: <Widget>[
            RbEntrance(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(AppTexts.exercisesHeading, style: text.h1),
                  ),
                  SizedBox(height: space.xs),
                  Text(
                    AppTexts.exercisesIntro,
                    style: text.body.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(height: space.lg),
            RbEntrance(
              index: 1,
              child: ExerciseTile(
                icon: LucideIcons.wind,
                title: AppTexts.breathingTitle,
                subtitle: AppTexts.breathingSubtitle,
                tint: colors.mood2,
                onTap: () => context.push<void>(AppRoutes.breathing),
              ),
            ),
            SizedBox(height: space.sm),
            RbEntrance(
              index: 2,
              child: ExerciseTile(
                icon: LucideIcons.eye,
                title: AppTexts.groundingTitle,
                subtitle: AppTexts.groundingSubtitle,
                tint: colors.softLavender,
                onTap: () => context.push<void>(AppRoutes.grounding),
              ),
            ),
            SizedBox(height: space.lg),
            const RbEntrance(index: 3, child: ExerciseDisclaimer()),
          ],
        ),
      ),
    );
  }
}
