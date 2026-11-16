import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
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

/// SCR-M22, kartu ringkasan mingguan (TASK-M074, dirapikan 2026-11-16). Dua baris:
/// 1. kepala: judul "Perasaanmu seminggu ini" dan pil status mood rata-rata (titik warna +
///    label, mis. "Biasa") sejajar dalam satu baris;
/// 2. isi: blob mood di kiri, di kanan "5 dari 7 hari terisi" dan tombol "Lihat detail".
/// Mood rata-rata dihitung server (`averageLevel`, RULE-M033). Kalimat penjelas dihapus karena
/// pil status sudah menyampaikan nadanya. Tanpa angka yang menilai atau menagih (RULE-M046).
/// Belum dua hari terisi: kartu lavender tanpa pil, berisi ajakan singkat. Memuat atau gagal:
/// tidak tampil (kartu grafik di bawahnya yang menampilkan galat).
class HomeWeekCard extends ConsumerWidget {
  const HomeWeekCard({super.key});

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
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({
    required this.level,
    required this.filled,
    required this.total,
  });

  final MoodLevel? level;
  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final current = level;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final summary = current == null
        ? AppTexts.homeWeekEmpty
        : AppTexts.homeWeekFilled(filled, total);

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
      label: '${AppTexts.homeWeekTitle}. '
          '${current == null ? '' : '${current.label}. '}'
          '$summary. ${AppTexts.homeWeekAction}',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(AppTexts.homeWeekTitle, style: text.h3),
                      ),
                      if (current != null) ...<Widget>[
                        SizedBox(width: space.xs),
                        _StatusPill(level: current),
                      ],
                    ],
                  ),
                  SizedBox(height: space.sm),
                  Row(
                    children: <Widget>[
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
                      SizedBox(width: space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              summary,
                              style: text.small
                                  .copyWith(color: colors.textSecondary),
                            ),
                            SizedBox(height: space.xs),
                            OutlinedButton(
                              onPressed: () => context.go(AppRoutes.mood),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: colors.card,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: RbRadius.pillBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Flexible(
                                    child: Text(AppTexts.homeWeekAction),
                                  ),
                                  SizedBox(width: space.xxs),
                                  const Icon(
                                    LucideIcons.chevronRight,
                                    size: RbSize.weekActionIcon,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

/// Pil putih berisi titik warna mood dan label (mis. "Biasa"). Warna tidak menjadi satu-satunya
/// pembawa makna: labelnya selalu tertulis (RULE-M052).
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.level});

  final MoodLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: RbRadius.pillBorder,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: space.sm,
          vertical: space.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: level.colorOf(colors),
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: RbSize.weekDot),
            ),
            SizedBox(width: space.xs),
            Text(
              level.label,
              style: text.small.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
