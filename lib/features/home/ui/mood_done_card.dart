import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/ui/mood_level_color.dart';
import 'package:relaxmate/features/checkin/ui/mood_ripple.dart';
import 'package:relaxmate/features/mood/data/mood_today.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// SCR-M22, kartu mood tercatat (TASK-M074, revisi 2026-11-16). Kartu pertama Beranda sekarang
/// membawa semua ringkasan hari ini supaya tidak terlihat kosong: blob besar berhalo di
/// kanan, "Hari ini kamu merasa" dengan label besar, satu kalimat hangat sesuai mood,
/// keterangan jam tercatat dan "N dari 7 hari tercatat" (menggantikan kartu mingguan yang
/// dihapus), dan tombol "Ubah". Tanpa skor atau tagihan (RULE-M046). Halo statis; satu-satunya
/// gerak adalah blob yang muncul lembut dan satu cincin riak, dan keduanya hormati
/// `MediaQuery.disableAnimations` (RULE-M055). Teks besar (di atas [RbSize.homeRowMaxTextScale])
/// menumpuk blob di atas teks.
class MoodDoneCard extends StatelessWidget {
  const MoodDoneCard({
    required this.entry,
    required this.filledDays,
    required this.totalDays,
    required this.onChange,
    super.key,
  });

  final MoodToday entry;

  /// Jumlah hari terisi pada deret 7 hari; `null` bila deret belum siap (pil disembunyikan).
  final int? filledDays;
  final int totalDays;
  final VoidCallback onChange;

  String _note(MoodLevel level) => switch (level) {
        MoodLevel.verySad => AppTexts.homeMoodNote1,
        MoodLevel.sad => AppTexts.homeMoodNote2,
        MoodLevel.neutral => AppTexts.homeMoodNote3,
        MoodLevel.happy => AppTexts.homeMoodNote4,
        MoodLevel.great => AppTexts.homeMoodNote5,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final level = entry.level;
    final tint = level.colorOf(colors);
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) > RbSize.homeRowMaxTextScale;
    final filled = filledDays;

    final Widget hero = _Hero(level: level, tint: tint);

    final Widget words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppTexts.homeMoodTodayLead,
          style: text.small.copyWith(color: colors.textSecondary),
        ),
        Semantics(
          header: true,
          child: Text(
            level.label,
            style: text.h2.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: space.xs),
        Text(_note(level), style: text.body),
      ],
    );

    final Widget footer = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Wrap(
            spacing: space.xs,
            runSpacing: space.xs,
            children: <Widget>[
              _InfoPill(
                label: AppTexts.homeMoodRecordedAt(
                  wibTimeLabel(entry.loggedAt),
                ),
              ),
              if (filled != null && filled > 0)
                _InfoPill(
                  label: AppTexts.homeMoodWeekFilled(filled, totalDays),
                ),
            ],
          ),
        ),
        SizedBox(width: space.xs),
        OutlinedButton(
          onPressed: onChange,
          style: OutlinedButton.styleFrom(
            backgroundColor: colors.card,
            shape: const RoundedRectangleBorder(
              borderRadius: RbRadius.pillBorder,
            ),
          ),
          child: const Text(AppTexts.homeMoodChange),
        ),
      ],
    );

    return FloatingCard(
      tint: tint,
      clip: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (stacked) ...<Widget>[
            Center(child: hero),
            SizedBox(height: space.sm),
            words,
          ] else
            Row(
              children: <Widget>[
                Expanded(child: words),
                SizedBox(width: space.xs),
                hero,
              ],
            ),
          SizedBox(height: space.md),
          footer,
        ],
      ),
    );
  }
}

/// Blob besar dengan dua lingkaran halo statis di belakangnya dan satu cincin riak.
class _Hero extends StatelessWidget {
  const _Hero({required this.level, required this.tint});

  final MoodLevel level;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Widget blob = Image.asset(
      level.asset,
      width: RbSize.moodHeroBlob,
      height: RbSize.moodHeroBlob,
      excludeFromSemantics: true,
    );

    return ExcludeSemantics(
      child: SizedBox(
        width: RbSize.moodHeroHalo,
        height: RbSize.moodHeroHalo,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            _Halo(size: RbSize.moodHeroHalo, color: tint, alpha: 0.22),
            _Halo(size: RbSize.moodHeroHalo * 0.8, color: tint, alpha: 0.32),
            MoodRipple(color: tint),
            reduceMotion
                ? blob
                : blob
                    .animate()
                    .scaleXY(
                      begin: RbMotion.popFrom,
                      end: 1,
                      duration: RbMotion.pop,
                      curve: RbMotion.curve,
                    )
                    .fadeIn(duration: RbMotion.pop, curve: RbMotion.curve),
          ],
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.size, required this.color, required this.alpha});

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }
}

/// Keterangan kecil berbentuk pil putih tembus pandang.
class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: 0.7),
        borderRadius: RbRadius.pillBorder,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: space.sm,
          vertical: space.xxs,
        ),
        child: Text(
          label,
          style: text.caption.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}
