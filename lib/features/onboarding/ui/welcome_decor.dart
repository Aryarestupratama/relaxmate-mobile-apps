import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Hiasan garis di sekeliling maskot pada layar sambutan (SCR-M02): segitiga, cincin,
/// bergelombang, kilau, tanda tambah, dan busur. Murni dekoratif (tidak ikut pembaca layar)
/// dan hanya memakai warna mood dari token. Posisi sebagai bagian dari lebar dan tinggi area.
class WelcomeDecor extends StatelessWidget {
  const WelcomeDecor({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DecorPainter(colors),
      ),
    );
  }
}

class _DecorPainter extends CustomPainter {
  const _DecorPainter(this.colors);

  final RbColors colors;

  // Posisi pusat bentuk (pecahan lebar, pecahan tinggi).
  static const Offset _triangleAt = Offset(0.16, 0.2);
  static const Offset _ringAt = Offset(0.07, 0.52);
  static const Offset _waveAt = Offset(0.7, 0.1);
  static const Offset _sparkleAt = Offset(0.92, 0.42);
  static const Offset _plusAt = Offset(0.84, 0.86);
  static const Offset _arcAt = Offset(0.14, 0.86);

  static const int _waveCrests = 3;
  static const double _waveWidthFactor = 3;
  static const double _waveHeightFactor = 0.3;

  @override
  void paint(Canvas canvas, Size size) {
    Paint line(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = RbSize.decorStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Offset at(Offset fraction) =>
        Offset(size.width * fraction.dx, size.height * fraction.dy);

    _triangle(canvas, at(_triangleAt), RbSize.decorShape, line(colors.mood2));
    canvas.drawCircle(
      at(_ringAt),
      RbSize.decorShapeSmall / 2,
      line(colors.mood1),
    );
    _wave(canvas, at(_waveAt), line(colors.mood4));
    _sparkle(canvas, at(_sparkleAt), RbSize.decorShape, line(colors.mood3));
    _plus(canvas, at(_plusAt), RbSize.decorShapeSmall, line(colors.mood4));
    _arc(canvas, at(_arcAt), RbSize.decorShape, line(colors.mood5));
  }

  void _triangle(Canvas canvas, Offset center, double side, Paint paint) {
    final half = side / 2;
    final path = Path()
      ..moveTo(center.dx, center.dy - half)
      ..lineTo(center.dx + half, center.dy + half)
      ..lineTo(center.dx - half, center.dy + half)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _wave(Canvas canvas, Offset start, Paint paint) {
    final step = RbSize.decorShape * _waveWidthFactor / (_waveCrests * 2);
    final lift = RbSize.decorShape * _waveHeightFactor;
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = 0; i < _waveCrests * 2; i++) {
      final x = start.dx + step * (i + 1);
      final controlY = start.dy + (i.isEven ? -lift : lift);
      path.quadraticBezierTo(x - step / 2, controlY, x, start.dy);
    }
    canvas.drawPath(path, paint);
  }

  /// Bintang empat sudut dengan sisi melengkung ke dalam.
  void _sparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final r = size / 2;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r);
    canvas.drawPath(path, paint);
  }

  void _plus(Canvas canvas, Offset center, double size, Paint paint) {
    final r = size / 2;
    canvas
      ..drawLine(
        Offset(center.dx - r, center.dy),
        Offset(center.dx + r, center.dy),
        paint,
      )
      ..drawLine(
        Offset(center.dx, center.dy - r),
        Offset(center.dx, center.dy + r),
        paint,
      );
  }

  /// Busur setengah lingkaran yang terbuka ke atas.
  void _arc(Canvas canvas, Offset center, double size, Paint paint) {
    final rect = Rect.fromCenter(center: center, width: size, height: size);
    canvas.drawArc(rect, 0, math.pi, false, paint);
  }

  @override
  bool shouldRepaint(_DecorPainter oldDelegate) => oldDelegate.colors != colors;
}
