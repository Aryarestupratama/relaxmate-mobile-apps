import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';
import 'package:relaxmate/shared/widgets/surface_card.dart';

/// Tiga angka ringkasan (FR-M030): rata-rata, hari terbaik, jumlah hari diisi. Semua dihitung
/// server; klien hanya memberi label. Pada teks sangat besar disusun menurun.
class MoodSummaryRow extends StatelessWidget {
  const MoodSummaryRow({required this.series, super.key});

  final MoodSeries series;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final best = series.bestDate;
    final cards = <Widget>[
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
        children: <Widget>[
          for (final card in cards) ...<Widget>[
            card,
            SizedBox(height: space.xs),
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < cards.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: space.xs),
            Expanded(child: cards[i]),
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

    return SurfaceCard(
      child: Semantics(
        container: true,
        label: '$label: $value',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
            Text(
              value,
              style: text.body.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
