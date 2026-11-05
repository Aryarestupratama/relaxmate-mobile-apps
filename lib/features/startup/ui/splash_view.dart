import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// Tampilan singkat saat pemeriksaan awal berjalan (SCR-M01, status memuat).
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const MateAvatar(size: MateAvatarSize.large),
              SizedBox(height: space.lg),
              CircularProgressIndicator(semanticsLabel: AppTexts.loading),
            ],
          ),
        ),
      ),
    );
  }
}
