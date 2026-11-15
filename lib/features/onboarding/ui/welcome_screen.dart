import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/onboarding/state/onboarding_controller.dart';
import 'package:relaxmate/features/onboarding/ui/welcome_decor.dart';
import 'package:relaxmate/shared/widgets/auth_switch_row.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// SCR-M02: Sambutan (onboarding). Tampil sekali untuk tamu pada pembukaan pertama: judul,
/// satu kalimat, ilustrasi RelaxMate di antara hiasan, tombol "Mulai" (ke Daftar) dan "Sudah punya akun?
/// Masuk". Memilih salah satunya menandai sambutan sudah dilihat, jadi pembukaan berikutnya
/// langsung ke Masuk. Tautan Kontak bantuan selalu ada (Design-M prinsip 4). Lokal: tanpa
/// jaringan dan tanpa AI. Bisa digulir agar utuh pada teks 200% dan layar pendek (RULE-M055).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, String route) {
    unawaited(ref.read(onboardingControllerProvider.notifier).markSeen());
    unawaited(context.push<void>(route));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Scaffold(
      body: SoftGradientBackground(
        style: SoftGradientStyle.full,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final heroSize =
                  (constraints.maxHeight * RbSize.onboardingHeroFactor)
                      .clamp(
                        RbSize.onboardingHeroMin,
                        RbSize.onboardingHeroMax,
                      )
                      .toDouble();

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: RbSize.authMaxContentWidth,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(space.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Semantics(
                              header: true,
                              child: Text(
                                AppTexts.welcomeTitle,
                                textAlign: TextAlign.center,
                                style: text.h1,
                              ),
                            ),
                            SizedBox(height: space.sm),
                            Text(
                              AppTexts.welcomeBody,
                              textAlign: TextAlign.center,
                              style: text.body.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: space.lg),
                            _HeroStage(size: heroSize),
                            SizedBox(height: space.lg),
                            FilledButton(
                              onPressed: () =>
                                  _open(context, ref, AppRoutes.register),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text(AppTexts.welcomeStart),
                                  SizedBox(width: space.xs),
                                  const Icon(
                                    LucideIcons.arrowRight,
                                    size: RbSize.icon,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: space.xs),
                            AuthSwitchRow(
                              prompt: AppTexts.welcomeHaveAccount,
                              action: AppTexts.loginAction,
                              onPressed: () =>
                                  _open(context, ref, AppRoutes.login),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push<void>(AppRoutes.crisisContacts),
                              child: const Text(
                                AppTexts.crisisNeedHelp,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Ilustrasi sambutan (RelaxMate memegang lima blob mood) di atas lingkaran lembut,
/// dikelilingi hiasan. Gambar diam, jadi tidak perlu cabang gerak dikurangi. Tinggi area
/// sedikit lebih besar dari ilustrasi agar hiasan punya ruang.
class _HeroStage extends StatelessWidget {
  const _HeroStage({required this.size});

  final double size;

  /// Seberapa pekat lingkaran lembut di belakang ilustrasi (turunan token `card`).
  static const double _backdropAlpha = 0.6;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final backdrop = size * RbSize.onboardingBackdropFactor;

    return SizedBox(
      height: backdrop,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const Positioned.fill(child: WelcomeDecor()),
          Container(
            width: backdrop,
            height: backdrop,
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: _backdropAlpha),
              shape: BoxShape.circle,
            ),
          ),
          Semantics(
            image: true,
            label: AppTexts.welcomeHeroLabel,
            child: ExcludeSemantics(
              child: Image.asset(
                AppAssets.welcomeHero,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
