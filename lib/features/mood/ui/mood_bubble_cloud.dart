import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/ui/mood_level_color.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// Gambaran utama halaman Mood Tracker: lima blob mood yang ukurannya sebanding jumlah hari
/// tiap mood pada rentang terpilih, tersusun rapat di tengah (tanpa angka di gambar). Di
/// bawahnya satu kalimat tentang mood yang paling sering dan legenda berisi nama mood dengan
/// jumlah harinya, jadi makna tidak hanya lewat ukuran atau warna. Pembaca layar mendapat satu
/// ringkasan. Blob muncul berurutan dengan efek pop lembut sekali; langsung tampil bila gerak
/// dikurangi. Penyusunan lingkaran murni dan deterministik (`packMoodCloud`).
class MoodBubbleCloud extends StatelessWidget {
  const MoodBubbleCloud({required this.series, super.key});

  final MoodSeries series;

  /// Jumlah hari tiap mood, hanya yang pernah muncul, dari terbanyak (seri: nilai mood
  /// yang lebih rendah dulu).
  static List<MapEntry<MoodLevel, int>> entriesOf(MoodSeries series) {
    final counts = <MoodLevel, int>{};
    for (final day in series.days) {
      counts[day.level] = (counts[day.level] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.value.compareTo(b.key.value);
      });
    return entries;
  }

  static String summaryOf(List<MapEntry<MoodLevel, int>> entries) {
    if (entries.isEmpty) {
      return '';
    }
    final top = entries.where((e) => e.value == entries.first.value).toList();
    return switch (top.length) {
      1 => AppTexts.moodCloudTop1(top[0].key.label),
      2 => AppTexts.moodCloudTop2(top[0].key.label, top[1].key.label),
      _ => AppTexts.moodCloudMixed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final entries = entriesOf(series);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final items = entries
        .map((e) => AppTexts.moodLegendItem(e.key.label, e.value))
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(AppTexts.moodCloudTitle, style: text.h3),
        ),
        SizedBox(height: space.sm),
        Semantics(
          label: AppTexts.moodCloudSemantics(items),
          excludeSemantics: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, RbSize.moodCloudHeight);
              final bubbles = packMoodCloud(entries, size);
              return SizedBox(
                width: size.width,
                height: size.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    for (var i = 0; i < bubbles.length; i++)
                      Positioned(
                        left: bubbles[i].center.dx - bubbles[i].radius,
                        top: bubbles[i].center.dy - bubbles[i].radius,
                        width: bubbles[i].radius * 2,
                        height: bubbles[i].radius * 2,
                        child: _animated(
                          reduceMotion: reduceMotion,
                          index: i,
                          child: _Bubble(bubble: bubbles[i]),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: space.sm),
        Text(
          summaryOf(entries),
          textAlign: TextAlign.center,
          style: text.body.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: space.sm),
        ExcludeSemantics(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: space.xs,
            runSpacing: space.xs,
            children: <Widget>[
              for (final entry in entries)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: space.sm,
                    vertical: space.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      entry.key.colorOf(colors).withValues(alpha: 0.35),
                      colors.card,
                    ),
                    borderRadius: RbRadius.pillBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        entry.key.asset,
                        width: RbSize.moodLegendBlob,
                        height: RbSize.moodLegendBlob,
                        excludeFromSemantics: true,
                      ),
                      SizedBox(width: space.xs),
                      Text(
                        AppTexts.moodLegendItem(entry.key.label, entry.value),
                        style: text.small,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _animated({
    required bool reduceMotion,
    required int index,
    required Widget child,
  }) {
    if (reduceMotion) {
      return child;
    }
    return child
        .animate(delay: RbMotion.stagger * index)
        .scaleXY(
          begin: RbMotion.popFrom,
          end: 1,
          duration: RbMotion.pop,
          curve: RbMotion.curve,
        )
        .fadeIn(duration: RbMotion.pop, curve: RbMotion.curve);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.bubble});

  final MoodBubble bubble;

  /// Blob sedikit lebih kecil dari lingkaran lembut di belakangnya.
  static const double _blobShare = 0.9;
  static const double _haloAlpha = 0.3;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final dimension = bubble.radius * 2;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bubble.level.colorOf(colors).withValues(alpha: _haloAlpha),
          ),
          child: SizedBox.square(dimension: dimension),
        ),
        Image.asset(
          bubble.level.asset,
          width: dimension * _blobShare,
          height: dimension * _blobShare,
          excludeFromSemantics: true,
        ),
      ],
    );
  }
}

/// Satu lingkaran hasil penyusunan: mood, jumlah hari, titik tengah, dan jari-jari.
class MoodBubble {
  const MoodBubble({
    required this.level,
    required this.days,
    required this.center,
    required this.radius,
  });

  final MoodLevel level;
  final int days;
  final Offset center;
  final double radius;
}

/// Menyusun lingkaran di dalam [size]: yang terbesar di tengah, lainnya menempel di sekitar
/// lingkaran yang sudah ada pada titik terdekat dari tengah. Jari-jari = dasar x (0,42 sampai
/// 1) sesuai akar jumlah hari relatif terhadap yang terbanyak, sehingga luas sebanding jumlah
/// hari dan yang paling sedikit tetap terlihat. Bila tidak muat, dasar diperkecil 7% dan
/// diulang. Murni dan deterministik.
List<MoodBubble> packMoodCloud(
  List<MapEntry<MoodLevel, int>> entries,
  Size size,
) {
  if (entries.isEmpty) {
    return const <MoodBubble>[];
  }
  const double minShare = 0.42;
  const double gap = 6;
  const double shrink = 0.93;
  const int maxAttempts = 40;
  final maxCount = entries.first.value;
  var base = math.min(size.height * 0.46, size.width / 3.2);

  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final placed = <MoodBubble>[];
    var fitted = true;
    for (final entry in entries) {
      final ratio = math.sqrt(entry.value / maxCount);
      final radius = base * (minShare + (1 - minShare) * ratio);
      final spot = _findSpot(placed, radius, size, gap);
      if (spot == null) {
        fitted = false;
        break;
      }
      placed.add(
        MoodBubble(
          level: entry.key,
          days: entry.value,
          center: spot,
          radius: radius,
        ),
      );
    }
    if (fitted) {
      return placed;
    }
    base *= shrink;
  }
  return const <MoodBubble>[];
}

Offset? _findSpot(
  List<MoodBubble> placed,
  double radius,
  Size size,
  double gap,
) {
  const int steps = 36;
  final middle = size.center(Offset.zero);

  bool fits(Offset c) {
    if (c.dx - radius < 0 ||
        c.dx + radius > size.width ||
        c.dy - radius < 0 ||
        c.dy + radius > size.height) {
      return false;
    }
    for (final other in placed) {
      if ((other.center - c).distance < other.radius + radius + gap - 0.01) {
        return false;
      }
    }
    return true;
  }

  if (placed.isEmpty) {
    return fits(middle) ? middle : null;
  }
  Offset? best;
  var bestDistance = double.infinity;
  for (final other in placed) {
    final distance = other.radius + radius + gap;
    for (var k = 0; k < steps; k++) {
      final angle = k * 2 * math.pi / steps;
      final c =
          other.center + Offset(math.cos(angle), math.sin(angle)) * distance;
      if (!fits(c)) {
        continue;
      }
      final fromMiddle = (c - middle).distance;
      if (fromMiddle < bestDistance) {
        best = c;
        bestDistance = fromMiddle;
      }
    }
  }
  return best;
}
