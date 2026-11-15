import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M36: kartu melayang Beranda (TASK-M074). Putih tanpa garis tepi dengan bayangan lembut
/// supaya terlihat mengambang di atas latar gradien, radius besar bergaya ubin. [tint] (token
/// warna) dicampur ke putih menjadi pastel; [gradient] menggantikan warna polos. Teks di
/// atasnya tetap token navy (RULE-M052). [clip] dipakai kartu yang isinya sengaja menjorok
/// keluar sudut (maskot mengintip).
class FloatingCard extends StatelessWidget {
  const FloatingCard({
    required this.child,
    this.tint,
    this.gradient,
    this.padding,
    this.clip = Clip.none,
    super.key,
  });

  final Widget child;
  final Color? tint;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final Clip clip;

  /// Seberapa kuat [tint] dicampurkan ke putih.
  static const double _tintStrength = 0.45;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;
    final accent = tint;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(space.md),
      clipBehavior: clip,
      decoration: BoxDecoration(
        color: accent == null
            ? colors.card
            : Color.alphaBlend(
                accent.withValues(alpha: _tintStrength),
                colors.card,
              ),
        gradient: gradient,
        borderRadius: RbRadius.sheetBorder,
        boxShadow: RbShadow.card(colors),
      ),
      child: child,
    );
  }
}
