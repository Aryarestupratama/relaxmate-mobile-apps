import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// Ringkasan tiga angka (rata-rata, hari terbaik, jumlah hari terisi) sebagai satu baris
/// bersekat tipis di dalam kartu grafik, bukan tiga kartu terpisah. Pada teks sangat besar
/// disusun menurun. Hanya kata dan hitungan hari, tanpa skor (RULE-M046).
class MoodSummaryRow extends StatelessWidget {
  const MoodSummaryRow({required this.series, super.key});

  final MoodSeries series;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final best = series.bestDate;
    final stats = <Widget>[
      _Stat(
        label: AppTexts.moodAverage,
        value: series.averageLevel?.label ?? '-',
      ),
      _Stat(
        label: AppTexts.moodBest,
        value: best == null ? '-' : relativeDayLabel(best, series.to),
      ),
      _Stat(
        label: AppTexts.moodFilled,
        value: AppTexts.moodFilledValue(series.filledDays, series.totalDays),
      ),
    ];

    final stacked =
        MediaQuery.textScalerOf(context).scale(1) > RbSize.homeRowMaxTextScale;
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: stats,
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < stats.length; i++) ...<Widget>[
            if (i > 0) VerticalDivider(width: 1, color: colors.border),
            Expanded(child: stats[i]),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '$label: $value',
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: space.xs,
          vertical: space.xxs,
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              textAlign: TextAlign.center,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.xxs),
            Text(
              value,
              textAlign: TextAlign.center,
              style: text.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
