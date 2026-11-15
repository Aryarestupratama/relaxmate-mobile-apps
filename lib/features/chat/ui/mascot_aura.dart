import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M49: cahaya lembut berbentuk lingkaran di belakang maskot (tampilan maskot chat).
/// Gradien radial dari `brandSoft` ke `mood2` yang memudar ke transparan, jadi maskot putih
/// berbingkai gelap punya latar yang memberinya kedalaman tanpa menambah warna baru. Hanya
/// dekorasi: tidak menerima sentuhan dan tanpa semantik. Statis.
class MascotAura extends StatelessWidget {
  const MascotAura({required this.diameter, super.key});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox.square(
          dimension: diameter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  colors.brandSoft.withValues(alpha: 0.55),
                  colors.mood2.withValues(alpha: 0.2),
                  colors.mood2.withValues(alpha: 0),
                ],
                stops: const <double>[0, 0.55, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
