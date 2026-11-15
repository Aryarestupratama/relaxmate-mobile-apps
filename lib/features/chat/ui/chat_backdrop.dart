import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M39: latar layar obrolan (TASK-M073 bagian 7). Gradien putih ke lavender sangat tipis dengan
/// belasan bulatan warna-warni transparan (token `mood1` sampai `mood5`, `brandSoft`) supaya
/// obrolan tidak polos. Statis (tanpa gerak berulang), digambar sekali lewat `CustomPainter`
/// di dalam `RepaintBoundary`, jadi gulir daftar pesan tidak menggambar ulang latar. Hanya
/// dekorasi: tidak menerima sentuhan dan tanpa semantik. Alpha dijaga rendah agar teks navy
/// tetap terbaca (RULE-M052); teks pesan selalu berada di atas gelembung, bukan di atas
/// bulatan. Memudar masuk sekali; bila gerak dikurangi langsung tampil.
class ChatBackdrop extends StatelessWidget {
  const ChatBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final Widget paint = RepaintBoundary(
      child: CustomPaint(
        painter: _BackdropPainter(colors),
        size: Size.infinite,
      ),
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: MediaQuery.disableAnimationsOf(context)
            ? paint
            : paint
                .animate()
                .fadeIn(duration: RbMotion.ripple, curve: RbMotion.curve),
      ),
    );
  }
}

class _Dot {
  const _Dot(this.x, this.y, this.radius, this.pick, this.alpha);

  /// Pusat sebagai bagian dari lebar dan tinggi layar.
  final double x;
  final double y;

  /// Jari-jari sebagai bagian dari sisi terpendek layar.
  final double radius;
  final Color Function(RbColors) pick;
  final double alpha;
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter(this.colors);

  final RbColors colors;

  /// Seberapa kuat lavender dicampur ke dasar gradien di bagian bawah.
  static const double _washStrength = 0.35;

  static final List<_Dot> _dots = <_Dot>[
    _Dot(0.90, 0.06, 0.22, (c) => c.mood1, 0.16),
    _Dot(0.04, 0.20, 0.12, (c) => c.mood2, 0.22),
    _Dot(0.30, 0.09, 0.030, (c) => c.mood5, 0.40),
    _Dot(0.93, 0.36, 0.060, (c) => c.mood3, 0.28),
    _Dot(0.10, 0.50, 0.20, (c) => c.mood4, 0.14),
    _Dot(0.56, 0.30, 0.035, (c) => c.brandSoft, 0.40),
    _Dot(0.82, 0.62, 0.13, (c) => c.mood5, 0.20),
    _Dot(0.22, 0.78, 0.07, (c) => c.mood1, 0.20),
    _Dot(0.92, 0.90, 0.24, (c) => c.mood2, 0.18),
    _Dot(0.46, 0.94, 0.050, (c) => c.mood3, 0.30),
    _Dot(0.62, 0.70, 0.028, (c) => c.mood4, 0.38),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            colors.pageBg,
            Color.alphaBlend(
              colors.softLavender.withValues(alpha: _washStrength),
              colors.pageBg,
            ),
          ],
        ).createShader(rect),
    );
    final base = size.shortestSide;
    for (final dot in _dots) {
      canvas.drawCircle(
        Offset(dot.x * size.width, dot.y * size.height),
        dot.radius * base,
        Paint()..color = dot.pick(colors).withValues(alpha: dot.alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) =>
      !identical(oldDelegate.colors, colors);
}
