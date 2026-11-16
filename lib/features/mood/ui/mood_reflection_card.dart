import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/mood/data/mood_insight.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';

/// Kartu "Catatan kecil untukmu": satu kalimat netral tentang pola mood (`MoodInsight`, dihitung
/// di perangkat tanpa AI) dan tombol pil gelap "Ceritakan ke RelaxMate" yang membuka chat.
/// Latar gradien lavender lembut dari token yang sudah ada. Avatar RelaxMate di kanan, disembunyikan
/// pada teks sangat besar. Tidak pernah menyimpulkan kondisi atau diagnosis.
class MoodReflectionCard extends StatelessWidget {
  const MoodReflectionCard({required this.series, super.key});

  final MoodSeries series;

  static const double _gradientAlpha = 0.55;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final message = switch (MoodInsight.of(series)) {
      MoodInsight.notEnough => AppTexts.moodInsightNotEnough,
      MoodInsight.lighter => AppTexts.moodInsightLighter,
      MoodInsight.heavier => AppTexts.moodInsightHeavier,
      MoodInsight.steady => AppTexts.moodInsightSteady,
    };
    final showAvatar =
        MediaQuery.textScalerOf(context).scale(1) <= RbSize.homeRowMaxTextScale;

    return FloatingCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          colors.softLavender,
          colors.gradientMid.withValues(alpha: _gradientAlpha),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(AppTexts.moodReflectionTitle, style: text.h3),
                ),
                SizedBox(height: space.xs),
                Text(message, style: text.body),
                SizedBox(height: space.md),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.chat),
                  icon: const Icon(
                    LucideIcons.messageCircle,
                    size: RbSize.icon,
                  ),
                  label: const Text(AppTexts.moodReflectionAction),
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: RbRadius.pillBorder,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showAvatar) ...<Widget>[
            SizedBox(width: space.sm),
            const ExcludeSemantics(child: MateAvatar()),
          ],
        ],
      ),
    );
  }
}
