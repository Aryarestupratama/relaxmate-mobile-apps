import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/mood/data/mood_day.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// CMP-M31: grafik garis suasana hati, satu titik per hari berwarna `mood1` sampai `mood5`
/// (FR-M030). Makna tidak hanya lewat warna: posisi vertikal, label sumbu y pada tampilan
/// penuh, dan ringkasan teks untuk pembaca layar.
///
/// - [compact]: Beranda, 7 hari, tanpa label sumbu y, hari ini berlabel "Hari ini".
/// - Penuh: Mood, 7 atau 30 hari, dengan label sumbu y dan garis rata-rata putus-putus.
///
/// Hari tanpa catatan tidak digambar dan memutus garis; hari ini yang belum diisi diberi
/// lingkaran putus-putus.
class MoodChart extends StatelessWidget {
  const MoodChart({required this.series, this.compact = false, super.key});

  final MoodSeries series;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final showAxis = !compact && scale <= RbSize.moodChartMaxLabelScale;
    final height =
        compact ? RbSize.moodChartCompactHeight : RbSize.moodChartHeight;
    final total = series.totalDays;
    final labelStyle = text.caption.copyWith(color: colors.textSecondary);
    final boldStyle = text.caption.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
    );

    final plot = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: _MoodChartPainter(
                  series: series,
                  colors: colors,
                  compact: compact,
                ),
              ),
            ),
            SizedBox(
              width: width,
              height: RbSize.moodChartLabelHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  for (var i = 0; i < total; i++)
                    if (_labelAt(i) case final String label)
                      Positioned(
                        left: width * (i + 0.5) / total -
                            RbSize.moodChartLabelWidth / 2,
                        width: RbSize.moodChartLabelWidth,
                        top: 0,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: i == total - 1 ? boldStyle : labelStyle,
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );

    return Semantics(
      label: _semanticsLabel(),
      container: true,
      excludeSemantics: true,
      child: showAxis
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: RbSize.moodChartAxisWidth,
                  height: height,
                  child: _AxisLabels(
                    height: height,
                    style: labelStyle,
                  ),
                ),
                Expanded(child: plot),
              ],
            )
          : plot,
    );
  }

  /// Label sumbu x, atau `null` bila hari ke-[index] tidak berlabel.
  String? _labelAt(int index) {
    final total = series.totalDays;
    final isToday = index == total - 1;
    final date = series.dateAt(index);
    if (compact) {
      return isToday
          ? AppTexts.today
          : AppTexts.weekdaysShort[date.weekday - 1];
    }
    if (total <= AppConstants.moodRangeShortDays) {
      return AppTexts.weekdaysShort[date.weekday - 1];
    }
    final fromToday = total - 1 - index;
    return fromToday % AppConstants.moodLongLabelStepDays == 0
        ? shortDateLabel(date)
        : null;
  }

  String _semanticsLabel() {
    final buffer = StringBuffer(
      AppTexts.moodChartSemantics(series.totalDays, series.filledDays),
    );
    if (series.totalDays <= AppConstants.moodRangeShortDays) {
      final byDate = <DateTime, MoodDay>{
        for (final day in series.days) day.date: day,
      };
      for (var i = 0; i < series.totalDays; i++) {
        final date = series.dateAt(i);
        final entry = byDate[date];
        buffer
          ..write(' ')
          ..write(
            AppTexts.moodChartDaySemantics(
              relativeDayLabel(date, series.to),
              entry?.level.label ?? AppTexts.moodNoEntry,
            ),
          );
      }
    } else {
      final average = series.averageLevel;
      if (average != null) {
        buffer
          ..write(' ')
          ..write(AppTexts.moodAverage)
          ..write(': ')
          ..write(average.label)
          ..write('.');
      }
    }
    return buffer.toString();
  }
}

/// Posisi tengah garis tingkat [level] (1 sampai 5) di area gambar setinggi [height].
double _levelY(double level, double height, double inset) =>
    inset + (5 - level) / 4 * (height - 2 * inset);

class _AxisLabels extends StatelessWidget {
  const _AxisLabels({required this.height, required this.style});

  final double height;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final inset = RbSize.moodChartPointRadius + RbSize.moodChartTodayExtra;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        for (final level in MoodLevel.values.reversed)
          Positioned(
            left: 0,
            right: 0,
            top: _levelY(level.value.toDouble(), height, inset) -
                RbSize.moodChartLabelHeight / 2,
            height: RbSize.moodChartLabelHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                level.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ),
      ],
    );
  }
}

class _MoodChartPainter extends CustomPainter {
  _MoodChartPainter({
    required this.series,
    required this.colors,
    required this.compact,
  });

  final MoodSeries series;
  final RbColors colors;
  final bool compact;

  Color _moodColor(MoodLevel level) => switch (level) {
        MoodLevel.verySad => colors.mood1,
        MoodLevel.sad => colors.mood2,
        MoodLevel.neutral => colors.mood3,
        MoodLevel.happy => colors.mood4,
        MoodLevel.great => colors.mood5,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final total = series.totalDays;
    final dense = total > AppConstants.moodRangeShortDays;
    final radius =
        dense ? RbSize.moodChartPointRadiusSmall : RbSize.moodChartPointRadius;
    final inset = RbSize.moodChartPointRadius + RbSize.moodChartTodayExtra;

    double x(int index) => size.width * (index + 0.5) / total;
    double y(double level) => _levelY(level, size.height, inset);

    final grid = Paint()
      ..color = colors.border
      ..strokeWidth = RbSize.moodChartGridStroke;
    for (var level = 1; level <= 5; level++) {
      final dy = y(level.toDouble());
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), grid);
    }

    final average = series.average;
    if (!compact && average != null) {
      final path = Path()
        ..moveTo(0, y(average))
        ..lineTo(size.width, y(average));
      _dashed(
        canvas,
        path,
        Paint()
          ..color = colors.textSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = RbSize.moodChartGridStroke,
      );
    }

    final byDate = <DateTime, MoodDay>{
      for (final day in series.days) day.date: day,
    };
    final points = <int, Offset>{};
    for (var i = 0; i < total; i++) {
      final entry = byDate[series.dateAt(i)];
      if (entry != null) {
        points[i] = Offset(x(i), y(entry.level.value.toDouble()));
      }
    }

    final line = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = RbSize.moodChartLineStroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < total - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a != null && b != null) {
        canvas.drawLine(a, b, line);
      }
    }

    for (final item in points.entries) {
      final isToday = item.key == total - 1;
      final level = byDate[series.dateAt(item.key)]?.level;
      if (level == null) {
        continue;
      }
      final r = isToday ? radius + RbSize.moodChartTodayExtra : radius;
      canvas
        ..drawCircle(item.value, r, Paint()..color = _moodColor(level))
        ..drawCircle(
          item.value,
          r,
          Paint()
            ..color = colors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = isToday
                ? RbSize.moodChartLineStroke + RbSize.moodChartGridStroke
                : RbSize.moodChartLineStroke,
        );
    }

    // Hari ini belum diisi: lingkaran putus-putus di garis tengah (mockup).
    if (!points.containsKey(total - 1)) {
      final center = Offset(x(total - 1), y(3));
      final ring = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));
      _dashed(
        canvas,
        ring,
        Paint()
          ..color = colors.textSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = RbSize.moodChartGridStroke,
      );
    }
  }

  void _dashed(Canvas canvas, Path path, Paint paint) {
    for (final ui.PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + RbSize.moodChartDash;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + RbSize.moodChartDashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_MoodChartPainter old) =>
      old.series != series || old.colors != colors || old.compact != compact;
}
