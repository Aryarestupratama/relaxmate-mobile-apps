import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';

/// CMP-M20: maskot RelaxMate beranimasi (WebP transparan per keadaan). Pergantian keadaan
/// memudar silang dan memulai animasi baru dari awal. Bila pengguna mengurangi gerak
/// (`MediaQuery.disableAnimations`), yang tampil gambar diam.
///
/// [outlined] memakai salinan berbingkai gelap (hanya `idle`, `thinking`, `speaking`) untuk
/// latar terang tempat maskot putih menyatu dengan latar (tampilan maskot chat). [fadeBottom]
/// memudarkan bagian bawah maskot setengah badan supaya potongannya tidak terlihat keras;
/// matikan bila aset badan penuh sudah dipasang (M075).
class MascotView extends StatelessWidget {
  const MascotView({
    required this.state,
    required this.height,
    this.outlined = false,
    this.fadeBottom = false,
    super.key,
  });

  final MascotState state;
  final double height;
  final bool outlined;
  final bool fadeBottom;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final Widget picture = reduceMotion
        ? Image.asset(
            outlined ? AppAssets.mascotStillOutlined : AppAssets.mascotHalf,
            key: const ValueKey<String>('mascot-still'),
            height: height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
          )
        : AnimatedSwitcher(
            duration: RbMotion.screen,
            child: Image.asset(
              outlined ? state.outlinedAsset : state.asset,
              key: ValueKey<MascotState>(state),
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
          );

    final Widget shown = fadeBottom
        ? ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.black, Colors.black, Colors.transparent],
              stops: <double>[0, 1 - RbSize.mascotFadeFraction, 1],
            ).createShader(rect),
            child: picture,
          )
        : picture;

    return Semantics(
      image: true,
      label: state.label,
      child: ExcludeSemantics(child: shown),
    );
  }
}
