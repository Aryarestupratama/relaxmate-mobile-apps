import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';

/// CMP-M20: maskot RelaxMate beranimasi (WebP transparan per keadaan). Pergantian keadaan
/// memudar silang dan memulai animasi baru dari awal. Bila pengguna mengurangi gerak
/// (`MediaQuery.disableAnimations`), yang tampil gambar diam.
class MascotView extends StatelessWidget {
  const MascotView({
    required this.state,
    required this.height,
    super.key,
  });

  final MascotState state;
  final double height;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final Widget picture = reduceMotion
        ? Image.asset(
            AppAssets.mascotHalf,
            key: const ValueKey<String>('mascot-still'),
            height: height,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          )
        : AnimatedSwitcher(
            duration: RbMotion.screen,
            child: Image.asset(
              state.asset,
              key: ValueKey<MascotState>(state),
              height: height,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
          );

    return Semantics(
      image: true,
      label: state.label,
      child: ExcludeSemantics(child: picture),
    );
  }
}
