import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M32: kartu putih berbingkai `border` di atas latar `surfaceAlt` (Beranda dan Mood).
/// [color] mengganti latar bila kartu perlu warna lain (mis. ajakan lavender).
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({required this.child, this.color, super.key});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(space.md),
      decoration: BoxDecoration(
        color: color ?? colors.card,
        borderRadius: RbRadius.cardBorder,
        border: color == null ? Border.all(color: colors.border) : null,
      ),
      child: child,
    );
  }
}
