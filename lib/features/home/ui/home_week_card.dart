import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/ui/mood_level_color.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// SCR-M22, kartu ringkasan mingguan (TASK-M074). Pengganti skor persen: blob besar yang
/// warnanya mengikuti mood rata-rata minggu ini (`averageLevel`, dihitung server; RULE-M033)
/// dengan satu kalimat lembut dan "5 dari 7 hari terisi". Tanpa angka yang menilai atau
/// menagih (RULE-M046). Belum dua hari terisi: kartu lavender dengan ajakan mengisi. Memuat
/// atau gagal: tidak tampil (kartu grafik di bawahnya yang menampilkan galat).
class HomeWeekCard extends ConsumerWidget {
  const HomeWeekCard({super.key});

  String _tone(MoodLevel level) => switch (level) {
        MoodLevel.verySad => AppTexts.homeWeekTone1,
        MoodLevel.sad => AppTexts.homeWeekTone2,
        MoodLevel.neutral => AppTexts.homeWeekTone3,
        MoodLevel.happy => AppTexts.homeWeekTone4,
        MoodLevel.great => AppTexts.homeWeekTone5,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      moodSeriesControllerProvider(AppConstants.moodRangeShortDays),
    );
    if (state is! MoodSeriesReady) {
      return const SizedBox.shrink();
    }
    final MoodSeries series = state.series;
    final level = series.filledDays < 2 ? null : series.averageLevel;
    return _WeekTile(
      level: level,
      filled: series.filledDays,
      total: series.totalDays,
      tone: level == null ? AppTexts.homeWeekEmpty : _tone(level),
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({
    required this.level,
    required this.filled,
    required this.total,
    required this.tone,
  });

  final MoodLevel? level;
  final int filled;
  final int total;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final current = level;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final Widget picture = current == null
        ? const MateAvatar(size: MateAvatarSize.large)
        : Image.asset(
            current.asset,
            width: RbSize.weekBlob,
            height: RbSize.weekBlob,
            excludeFromSemantics: true,
          );

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${AppTexts.homeWeekTitle}. $tone '
          '${AppTexts.homeWeekFilled(filled, total)}. '
          '${AppTexts.homeWeekAction}',
      onTap: () => context.go(AppRoutes.mood),
      child: FloatingCard(
        tint: current == null ? colors.softLavender : current.colorOf(colors),
        padding: EdgeInsets.zero,
        clip: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => context.go(AppRoutes.mood),
            child: Padding(
              padding: EdgeInsets.all(space.md),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppTexts.homeWeekTitle, style: text.h3),
                        SizedBox(height: space.xxs),
                        Text(
                          tone,
                          style:
                              text.body.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (current != null) ...<Widget>[
                          SizedBox(height: space.xxs),
                          Text(
                            AppTexts.homeWeekFilled(filled, total),
                            style: text.small
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                        SizedBox(height: space.sm),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.card,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(
                            dimension: RbSize.minTouch,
                            child: Icon(
                              LucideIcons.chevronRight,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: space.sm),
                  reduceMotion
                      ? picture
                      : picture
                          .animate(delay: RbMotion.enter)
                          .scaleXY(
                            begin: RbMotion.popFrom,
                            end: 1,
                            duration: RbMotion.pop,
                            curve: RbMotion.curve,
                          )
                          .fadeIn(
                            duration: RbMotion.pop,
                            curve: RbMotion.curve,
                          ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
