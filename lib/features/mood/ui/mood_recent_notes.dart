import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';
import 'package:relaxmate/shared/widgets/surface_card.dart';

/// Daftar "Catatan terakhir" (FR-M030): beberapa hari terbaru, tiap hari catatan terakhirnya.
/// Hanya tingkat dan waktu; catatan teks tidak pernah sampai ke aplikasi.
class MoodRecentNotes extends StatelessWidget {
  const MoodRecentNotes({required this.series, super.key});

  final MoodSeries series;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final recent = series.days.reversed
        .take(AppConstants.moodRecentNotes)
        .toList(growable: false);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              AppTexts.moodRecentTitle,
              style: text.h3.copyWith(fontSize: text.body.fontSize),
            ),
          ),
          for (final day in recent) ...<Widget>[
            Divider(color: colors.border, height: space.md * 2),
            Semantics(
              container: true,
              excludeSemantics: true,
              label: '${day.level.label}, '
                  '${AppTexts.moodNoteDateTime(relativeDayLabel(day.date, series.to), wibTimeLabel(day.loggedAt))}',
              child: Row(
                children: <Widget>[
                  Image.asset(
                    day.level.asset,
                    width: RbSize.moodNoteBlob,
                    height: RbSize.moodNoteBlob,
                    excludeFromSemantics: true,
                  ),
                  SizedBox(width: space.sm),
                  Expanded(
                    child: Text(
                      day.level.label,
                      style: text.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(width: space.xs),
                  Text(
                    AppTexts.moodNoteDateTime(
                      relativeDayLabel(day.date, series.to),
                      wibTimeLabel(day.loggedAt),
                    ),
                    style: text.small.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
