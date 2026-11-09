import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M03: penanda RelaxMate sedang menulis balasan, tiga titik yang naik turun bergantian.
/// Teks "RelaxMate sedang menulis" hanya untuk pembaca layar. Bila pengguna mengurangi gerak,
/// titik diam.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  static const int _dotCount = 3;
  static const Duration _cycle = Duration(milliseconds: 1200);

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _cycle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Naik 0..1..0 pada sepertiga siklus milik titik [index]; sisanya diam di bawah.
  double _lift(int index) {
    final start = index / (_dotCount + 1);
    final end = start + 2 / (_dotCount + 1);
    final t = ((_controller.value - start) / (end - start))
        .clamp(0.0, 1.0)
        .toDouble();
    return RbMotion.breathCurve.transform(t < 0.5 ? t * 2 : (1 - t) * 2);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.xxs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          container: true,
          liveRegion: true,
          label: AppTexts.chatTyping,
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: space.md,
                vertical: space.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: RbRadius.bubbleBorder,
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (var i = 0; i < _dotCount; i++) ...<Widget>[
                      if (i > 0) SizedBox(width: space.xxs),
                      Transform.translate(
                        offset: Offset(0, -RbSize.typingDotLift * _lift(i)),
                        child: Container(
                          width: RbSize.typingDot,
                          height: RbSize.typingDot,
                          decoration: BoxDecoration(
                            color: colors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
