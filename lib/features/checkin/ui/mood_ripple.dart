import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';

/// CMP-M37: cincin riak sekali jalan berwarna mood (TASK-M074). Membesar sampai
/// [RbMotion.rippleEnd] kali ukuran blob sambil memudar selama [RbMotion.ripple]. Dipasang di
/// belakang blob yang baru dipilih dan di blob konfirmasi. Murni hiasan: tanpa semantik dan
/// tidak menerima sentuhan; hilang bila pengguna mengurangi gerak.
class MoodRipple extends StatelessWidget {
  const MoodRipple({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: ExcludeSemantics(
        child: SizedBox(
          width: RbSize.moodBlob,
          height: RbSize.moodBlob,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: RbRadius.cardBorder,
              border: Border.all(color: color, width: RbSize.borderSelected),
            ),
          )
              .animate()
              .scaleXY(
                begin: 1,
                end: RbMotion.rippleEnd,
                duration: RbMotion.ripple,
                curve: RbMotion.curve,
              )
              .fadeOut(duration: RbMotion.ripple, curve: RbMotion.curve),
        ),
      ),
    );
  }
}
