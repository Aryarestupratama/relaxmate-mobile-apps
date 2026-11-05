import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// CMP-M01: lingkaran berisi avatar RelaxMate di atas `softLavender`.
class MateAvatar extends StatelessWidget {
  const MateAvatar({super.key, this.size = MateAvatarSize.medium});

  final MateAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final dimension = size.dimension;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: context.rbColors.softLavender,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          AppAssets.mascotAvatar,
          fit: BoxFit.cover,
          semanticLabel: AppTexts.mascotLabel,
        ),
      ),
    );
  }
}
