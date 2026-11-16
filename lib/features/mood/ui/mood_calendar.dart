import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/ui/mood_level_color.dart';
import 'package:relaxmate/features/mood/data/mood_day.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// Kalender perasaan untuk tampilan 30 hari: grid tujuh kolom (Sen sampai Min), satu lingkaran
/// per hari. Hari terisi berwarna `mood1` sampai `mood5` sesuai mood-nya, hari kosong hanya
/// bergaris, hari ini berbingkai utama. Nomor tanggal ada di tiap lingkaran, jadi makna tidak
/// hanya lewat warna; pembaca layar mendapat satu ringkasan. Lebih tenang daripada garis 30
/// titik yang padat.
class MoodCalendar extends StatelessWidget {
  const MoodCalendar({required this.series, super.key});

  final MoodSeries series;

  static const int _columns = 7;
  static const double _todayStroke = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final total = series.totalDays;
    final offset = series.from.weekday - 1;
    final rows = ((offset + total) / _columns).ceil();
    final byDate = <DateTime, MoodDay>{
      for (final day in series.days) day.date: day,
    };
    const gap = RbSize.moodCalendarGap;

    final label = StringBuffer(
      AppTexts.moodChartSemantics(total, series.filledDays),
    );
    final average = series.averageLevel;
    if (average != null) {
      label
        ..write(' ')
        ..write(AppTexts.moodAverage)
        ..write(': ')
        ..write(average.label)
        ..write('.');
    }

    return Semantics(
      label: label.toString(),
      container: true,
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              for (final name in AppTexts.weekdaysShort)
                Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: text.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: gap),
          for (var row = 0; row < rows; row++)
            Padding(
              padding: EdgeInsets.only(bottom: row == rows - 1 ? 0 : gap),
              child: Row(
                children: <Widget>[
                  for (var col = 0; col < _columns; col++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: gap / 2,
                        ),
                        child: _cell(
                          context,
                          index: row * _columns + col - offset,
                          byDate: byDate,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(
    BuildContext context, {
    required int index,
    required Map<DateTime, MoodDay> byDate,
  }) {
    if (index < 0 || index >= series.totalDays) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }
    final colors = context.rbColors;
    final text = context.rbText;
    final date = series.dateAt(index);
    final entry = byDate[date];
    final isToday = index == series.totalDays - 1;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: entry?.level.colorOf(colors),
          border: Border.all(
            color: isToday ? colors.primary : colors.border,
            width: isToday ? _todayStroke : 1,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: FittedBox(
              child: Text(
                '${date.day}',
                style: text.caption.copyWith(
                  color: entry == null ? colors.textMuted : colors.primary,
                  fontWeight: entry == null ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
