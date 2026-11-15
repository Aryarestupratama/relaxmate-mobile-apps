import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Gaya latar gradien lembut.
enum SoftGradientStyle {
  /// Seluruh layar: putih keunguan di atas, lavender dan biru lembut di bawah (sambutan).
  full,

  /// Hanya bagian atas layar, memudar ke putih (Masuk, Daftar, dan layar tamu lain).
  header,
}

/// CMP-M33: latar gradien lembut dari token gradien tema (`gradientTop`, `gradientMid`,
/// `gradientBottom`), dilunakkan dengan `pageBg` supaya teks navy tetap terbaca (kontras
/// >= 4,5:1, RULE-M052). Tidak ada nilai warna di sini; hanya campuran token.
class SoftGradientBackground extends StatelessWidget {
  const SoftGradientBackground({
    required this.child,
    this.style = SoftGradientStyle.header,
    super.key,
  });

  final Widget child;
  final SoftGradientStyle style;

  /// Seberapa kuat token gradien dicampurkan ke `pageBg`.
  static const double _midStrength = 0.45;
  static const double _bottomStrength = 0.5;
  static const double _headerStrength = 0.5;

  /// Gradien `header` selesai memudar pada bagian ini dari tinggi layar.
  static const double _headerFadeEnd = 0.45;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    final LinearGradient gradient = switch (style) {
      SoftGradientStyle.full => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            colors.gradientTop,
            Color.alphaBlend(
              colors.gradientMid.withValues(alpha: _midStrength),
              colors.pageBg,
            ),
            Color.alphaBlend(
              colors.gradientBottom.withValues(alpha: _bottomStrength),
              colors.pageBg,
            ),
          ],
        ),
      SoftGradientStyle.header => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.alphaBlend(
              colors.gradientBottom.withValues(alpha: _headerStrength),
              colors.pageBg,
            ),
            colors.pageBg,
          ],
          stops: const <double>[0, _headerFadeEnd],
        ),
    };

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: child,
      ),
    );
  }
}
