import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/exercises/data/breathing_phase.dart';

/// CMP-M11: lingkaran panduan napas. Cakram sangat tipis dan cincin tipis tetap di ukuran
/// penuh (menandai sejauh mana lingkaran akan membesar); lingkaran lavender di dalamnya
/// membesar selama tarik napas, bertahan saat menahan, lalu mengecil selama embusan. Hanya
/// satu gerak, lembut, tanpa kilau atau denyut tambahan. Murni hiasan: panduan untuk
/// pembaca layar ada pada teks instruksi di layar latihan. [size] mengubah garis tengah
/// (pratinjau di layar pilih durasi memakai ukuran lebih kecil).
///
/// Bila pengguna mengurangi gerak (`MediaQuery.disableAnimations`), lingkaran diam di ukuran
/// tengah dan panduan hanya lewat teks (Design-M aksesibilitas, RULE-M055).
class BreathingGuide extends StatelessWidget {
  const BreathingGuide({
    required this.phase,
    this.size = RbSize.breathingGuide,
    super.key,
  });

  final BreathingPhase phase;
  final double size;

  /// Seberapa tipis cakram latar di ukuran penuh.
  static const double _discAlpha = 0.35;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    const fullScale = 1.0;
    const minScale = RbSize.breathingMinScale;
    final phaseScale = switch (phase) {
      BreathingPhase.inhale || BreathingPhase.hold => fullScale,
      BreathingPhase.exhale => minScale,
    };
    final targetScale = reduceMotion ? (fullScale + minScale) / 2 : phaseScale;

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.softLavender.withValues(alpha: _discAlpha),
                border: Border.all(
                  color: colors.border,
                  width: RbSize.borderThin,
                ),
              ),
            ),
            // `begin` hanya dipakai saat pertama dibangun: latihan selalu dimulai dari napas
            // habis, lalu membesar. Sesudahnya lingkaran bergerak dari ukurannya sekarang.
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: minScale, end: targetScale),
              duration: reduceMotion ? Duration.zero : phase.duration,
              curve: RbMotion.breathCurve,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colors.softLavender,
                      colors.brandSoft.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
