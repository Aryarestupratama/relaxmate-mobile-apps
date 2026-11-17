import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M62: tiga cincin bening di belakang maskot Temani saja yang mengembang dan mengempis
/// pelan seperti napas ([RbMotion.haloBreath]). Cincin dalam bergerak lebih sedikit daripada
/// yang luar sehingga ada kesan kedalaman. Warna dari token (`card` dan `brandSoft` yang
/// dibuat transparan). Hanya dekorasi: tanpa semantik dan tanpa sentuhan. Bila gerak
/// dikurangi (`MediaQuery.disableAnimations`, RULE-M055) cincin diam pada ukuran penuh.
class BreathingHalo extends StatefulWidget {
  const BreathingHalo({required this.diameter, super.key});

  /// Garis tengah cincin terluar pada ukuran penuh.
  final double diameter;

  @override
  State<BreathingHalo> createState() => _BreathingHaloState();
}

class _BreathingHaloState extends State<BreathingHalo>
    with SingleTickerProviderStateMixin {
  /// Ukuran tiap cincin sebagai bagian dari garis tengah terluar, dari luar ke dalam.
  static const List<double> _sizes = <double>[1, 0.74, 0.5];

  /// Tambahan skala terkecil tiap cincin (makin ke dalam makin sedikit bergerak).
  static const List<double> _minScaleLift = <double>[0, 0.06, 0.12];

  /// Kepekatan isi cincin dari luar ke dalam.
  static const List<double> _fillAlpha = <double>[0.16, 0.22, 0.3];

  static const double _borderAlpha = 0.55;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RbMotion.haloBreath,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox.square(
          dimension: widget.diameter,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = RbMotion.breathCurve.transform(_controller.value);
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  for (var i = 0; i < _sizes.length; i++)
                    Transform.scale(
                      scale: _scaleAt(i, t),
                      child: Container(
                        width: widget.diameter * _sizes[i],
                        height: widget.diameter * _sizes[i],
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.alphaBlend(
                            colors.brandSoft.withValues(alpha: _fillAlpha[i]),
                            colors.card.withValues(alpha: _fillAlpha[i]),
                          ),
                          border: Border.all(
                            color: colors.card.withValues(alpha: _borderAlpha),
                            width: RbSize.companionRingStroke,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _scaleAt(int ring, double t) {
    final minScale = RbSize.companionHaloMinScale + _minScaleLift[ring];
    return minScale + (1 - minScale) * t;
  }
}
