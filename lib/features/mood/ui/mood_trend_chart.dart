import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/ui/mood_level_color.dart';
import 'package:relaxmate/features/mood/data/mood_day.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// Kurva perasaan 7 hari di halaman Mood Tracker. Garis melengkung halus (tanpa lonjakan di
/// antara dua titik) dengan area tipis di bawahnya, titik berwarna `mood1` sampai `mood5` yang
/// berbingkai tipis, sumbu kiri berupa blob mini lima tingkat (bukan teks), garis rata-rata
/// putus-putus, dan satu label "Terbaik" di hari terbaik. Hari tanpa catatan memutus garis;
/// hari ini yang belum diisi diberi lingkaran putus-putus. Makna tidak hanya lewat warna:
/// posisi vertikal, label, dan ringkasan teks untuk pembaca layar. Gambar "tergambar" dari kiri
/// sekali per deret; langsung utuh bila gerak dikurangi. Untuk 30 hari dipakai `MoodCalendar`.
class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({required this.series, super.key});

  final MoodSeries series;

  static const double _inset = 14;
  static const double _calloutLift = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final total = series.totalDays;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final byDate = <DateTime, MoodDay>{
      for (final day in series.days) day.date: day,
    };
    final bestDate = series.bestDate;
    final labelStyle = text.caption.copyWith(color: colors.textSecondary);

    return Semantics(
      label: _semanticsLabel(byDate),
      container: true,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: RbSize.moodTrendAxisWidth,
            height: RbSize.moodTrendHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                for (final level in MoodLevel.values)
                  Positioned(
                    left: 0,
                    top: _y(level.value.toDouble()) - RbSize.moodAxisBlob / 2,
                    child: Image.asset(
                      level.asset,
                      width: RbSize.moodAxisBlob,
                      height: RbSize.moodAxisBlob,
                      excludeFromSemantics: true,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                double x(int index) => width * (index + 0.5) / total;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: width,
                      height: RbSize.moodTrendHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Positioned.fill(
                            child: TweenAnimationBuilder<double>(
                              key: ObjectKey(series),
                              tween: Tween<double>(
                                begin: reduceMotion ? 1 : 0,
                                end: 1,
                              ),
                              duration: reduceMotion
                                  ? Duration.zero
                                  : RbMotion.chartLine + RbMotion.chartDots,
                              curve: Curves.easeOutCubic,
                              builder: (context, progress, _) => CustomPaint(
                                painter: _TrendPainter(
                                  series: series,
                                  byDate: byDate,
                                  colors: colors,
                                  progress: progress,
                                ),
                              ),
                            ),
                          ),
                          if (bestDate != null && series.filledDays >= 2)
                            _callout(
                              context,
                              width: width,
                              index: bestDate.difference(series.from).inDays,
                              entry: byDate[bestDate],
                              x: x,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width,
                      height: RbSize.moodChartLabelHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          for (var i = 0; i < total; i++)
                            Positioned(
                              left: x(i) - RbSize.moodChartLabelWidth / 2,
                              width: RbSize.moodChartLabelWidth,
                              top: 0,
                              child: Text(
                                AppTexts.weekdaysShort[
                                    series.dateAt(i).weekday - 1],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                softWrap: false,
                                style: i == total - 1
                                    ? labelStyle.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w700,
                                      )
                                    : labelStyle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static double _y(double level) =>
      _inset + (5 - level) / 4 * (RbSize.moodTrendHeight - 2 * _inset);

  Widget _callout(
    BuildContext context, {
    required double width,
    required int index,
    required MoodDay? entry,
    required double Function(int) x,
  }) {
    if (entry == null || index < 0 || index >= series.totalDays) {
      return const SizedBox.shrink();
    }
    final colors = context.rbColors;
    final text = context.rbText;
    final pointY = _y(entry.level.value.toDouble());
    final above = pointY - _calloutLift - RbSize.moodCalloutHeight >= 0;
    final top = above
        ? pointY - _calloutLift - RbSize.moodCalloutHeight
        : pointY + _calloutLift;
    final left = (x(index) - RbSize.moodCalloutWidth / 2)
        .clamp(0.0, width - RbSize.moodCalloutWidth);

    return Positioned(
      left: left,
      top: top,
      width: RbSize.moodCalloutWidth,
      height: RbSize.moodCalloutHeight,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: RbRadius.pillBorder,
            border: Border.all(color: entry.level.colorOf(colors), width: 2),
            boxShadow: RbShadow.card(colors),
          ),
          child: Center(
            child: Text(
              AppTexts.moodBest,
              style: text.caption.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticsLabel(Map<DateTime, MoodDay> byDate) {
    final buffer = StringBuffer(
      AppTexts.moodChartSemantics(series.totalDays, series.filledDays),
    );
    for (var i = 0; i < series.totalDays; i++) {
      final date = series.dateAt(i);
      buffer
        ..write(' ')
        ..write(
          AppTexts.moodChartDaySemantics(
            relativeDayLabel(date, series.to),
            byDate[date]?.level.label ?? AppTexts.moodNoEntry,
          ),
        );
    }
    return buffer.toString();
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.series,
    required this.byDate,
    required this.colors,
    required this.progress,
  });

  final MoodSeries series;
  final Map<DateTime, MoodDay> byDate;
  final RbColors colors;

  /// 0 sampai 1 sepanjang gerak gambar dari kiri ke kanan; 1 = gambar utuh.
  final double progress;

  static const double _dotRadius = 7;
  static const double _todayExtra = 3;
  static const double _lineStroke = 2.5;
  static const double _ringStroke = 1.5;
  static const double _haloExtra = 3;
  static const double _areaAlpha = 0.16;
  static const double _dotGrowSpan = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final total = series.totalDays;
    double x(int index) => size.width * (index + 0.5) / total;
    double y(double level) => MoodTrendChart._y(level);

    final grid = Paint()
      ..color = colors.border.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var level = 1; level <= 5; level++) {
      final dy = y(level.toDouble());
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), grid);
    }

    final average = series.average;
    if (average != null) {
      _dashed(
        canvas,
        Path()
          ..moveTo(0, y(average))
          ..lineTo(size.width, y(average)),
        Paint()
          ..color = colors.textSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final points = <int, Offset>{};
    for (var i = 0; i < total; i++) {
      final entry = byDate[series.dateAt(i)];
      if (entry != null) {
        points[i] = Offset(x(i), y(entry.level.value.toDouble()));
      }
    }

    // Segmen = deret hari berurutan yang terisi; hari kosong memutus garis.
    final segments = <List<Offset>>[];
    var current = <Offset>[];
    for (var i = 0; i < total; i++) {
      final point = points[i];
      if (point == null) {
        if (current.length >= 2) {
          segments.add(current);
        }
        current = <Offset>[];
      } else {
        current.add(point);
      }
    }
    if (current.length >= 2) {
      segments.add(current);
    }

    final reveal = size.width * progress;
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, -40, reveal, size.height + 80));
    for (final segment in segments) {
      final curve = _smooth(segment);
      final area = Path.from(curve)
        ..lineTo(segment.last.dx, size.height)
        ..lineTo(segment.first.dx, size.height)
        ..close();
      canvas
        ..drawPath(
          area,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset.zero,
              Offset(0, size.height),
              <Color>[
                colors.primary.withValues(alpha: _areaAlpha),
                colors.primary.withValues(alpha: 0),
              ],
            ),
        )
        ..drawPath(
          curve,
          Paint()
            ..color = colors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = _lineStroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
    }
    canvas.restore();

    for (final entry in points.entries) {
      final index = entry.key;
      final center = entry.value;
      final level = byDate[series.dateAt(index)]?.level;
      if (level == null) {
        continue;
      }
      final grow = Curves.easeOutBack.transform(
        ((reveal - center.dx) / _dotGrowSpan + 1).clamp(0.0, 1.0),
      );
      if (grow <= 0) {
        continue;
      }
      final isToday = index == total - 1;
      final r = (isToday ? _dotRadius + _todayExtra : _dotRadius) * grow;
      canvas
        ..drawCircle(center, r + _haloExtra, Paint()..color = colors.card)
        ..drawCircle(center, r, Paint()..color = level.colorOf(colors))
        ..drawCircle(
          center,
          r,
          Paint()
            ..color = colors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = _ringStroke,
        );
    }

    if (!points.containsKey(total - 1)) {
      _dashed(
        canvas,
        Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(x(total - 1), y(3)),
              radius: _dotRadius,
            ),
          ),
        Paint()
          ..color = colors.textSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  /// Kurva kubik dengan garis singgung mendatar di tiap titik, jadi tidak pernah melampaui
  /// tinggi titik-titiknya.
  Path _smooth(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final mid = (a.dx + b.dx) / 2;
      path.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
    }
    return path;
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
  bool shouldRepaint(_TrendPainter old) =>
      old.series != series || old.colors != colors || old.progress != progress;
}
