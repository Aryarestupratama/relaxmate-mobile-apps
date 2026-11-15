import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';

/// Gerak masuk bertahap (TASK-M074): memudar dan naik sedikit ([RbSize.motionShift]) selama
/// [RbMotion.enter], tertunda [RbMotion.stagger] kali [index] supaya kartu muncul berurutan.
/// Satu kali per kemunculan, tidak berulang. Bila pengguna mengurangi gerak
/// (`MediaQuery.disableAnimations`, RULE-M055) [child] tampil langsung.
class RbEntrance extends StatelessWidget {
  const RbEntrance({required this.child, this.index = 0, super.key});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    return child
        .animate(delay: RbMotion.stagger * index)
        .fadeIn(duration: RbMotion.enter, curve: RbMotion.curve)
        .moveY(
          begin: RbSize.motionShift,
          end: 0,
          duration: RbMotion.enter,
          curve: RbMotion.curve,
        );
  }
}
