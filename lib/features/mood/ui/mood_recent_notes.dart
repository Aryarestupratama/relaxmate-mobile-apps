import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/ui/mood_level_color.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// Riwayat terakhir: beberapa hari terbaru (terbaru di atas), masing-masing satu baris
/// membulat dengan blob mood di lingkaran pastel, nama mood, dan penanda hari serta jam
/// (WIB). Latar baris berwarna lembut sesuai mood. Pembaca layar mendapat satu kalimat per
/// baris.
class MoodRecentNotes extends StatelessWidget {
  const MoodRecentNotes({required this.series, super.key});

  final MoodSeries series;

  static const double _rowRadius = 20;
  static const double _tintStrength = 0.22;
  static const double _chipTintStrength = 0.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final recent = series.days.reversed
        .take(AppConstants.moodRecentNotes)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(AppTexts.moodHistoryTitle, style: text.h3),
        ),
        SizedBox(height: space.sm),
        for (final day in recent)
          Padding(
            padding: EdgeInsets.only(bottom: space.xs),
            child: Semantics(
              container: true,
              excludeSemantics: true,
              label: '${day.level.label}, '
                  '${AppTexts.moodNoteDateTime(relativeDayLabel(day.date, series.to), wibTimeLabel(day.loggedAt))}',
              child: Container(
                padding: EdgeInsets.all(space.xs),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    day.level.colorOf(colors).withValues(alpha: _tintStrength),
                    colors.card,
                  ),
                  borderRadius: BorderRadius.circular(_rowRadius),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: RbSize.moodNoteBlob + space.xs,
                      height: RbSize.moodNoteBlob + space.xs,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.alphaBlend(
                          day.level
                              .colorOf(colors)
                              .withValues(alpha: _chipTintStrength),
                          colors.card,
                        ),
                      ),
                      child: Image.asset(
                        day.level.asset,
                        width: RbSize.moodNoteBlob,
                        height: RbSize.moodNoteBlob,
                        excludeFromSemantics: true,
                      ),
                    ),
                    SizedBox(width: space.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            day.level.label,
                            style: text.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            AppTexts.moodNoteDateTime(
                              relativeDayLabel(day.date, series.to),
                              wibTimeLabel(day.loggedAt),
                            ),
                            style: text.small.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
