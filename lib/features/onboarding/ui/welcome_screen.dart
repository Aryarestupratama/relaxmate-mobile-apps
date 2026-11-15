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
import 'package:relaxmate/shared/widgets/auth_switch_row.dart';
import 'package:relaxmate/shared/widgets/crisis_help_button.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// SCR-M02: Sambutan (onboarding). Tampil sekali untuk tamu pada pembukaan pertama: judul,
/// satu kalimat, ilustrasi RelaxMate, tombol "Mulai" (ke Daftar) dan "Sudah punya akun?
/// Masuk". Memilih salah satunya menandai sambutan sudah dilihat, jadi pembukaan berikutnya
/// langsung ke Masuk. Tombol "Bantuan" di pojok kanan atas selalu ada (Design-M prinsip 4).
/// Lokal: tanpa jaringan dan tanpa AI. Bisa digulir agar utuh pada teks 200% dan layar
/// pendek (RULE-M055).
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
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(space.lg, space.xs, space.lg, 0),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: CrisisHelpButton(),
                ),
              ),
              Expanded(
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
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
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
                                  SizedBox(height: space.md),
                                  Semantics(
                                    image: true,
                                    label: AppTexts.welcomeHeroLabel,
                                    child: ExcludeSemantics(
                                      child: Image.asset(
                                        AppAssets.welcomeHero,
                                        width: heroSize,
                                        height: heroSize,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: space.md),
                                  FilledButton(
                                    onPressed: () =>
                                        _open(context, ref, AppRoutes.register),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
            ],
          ),
        ),
      ),
    );
  }
}
