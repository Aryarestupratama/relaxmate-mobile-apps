import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';
import 'package:relaxmate/features/mascot/ui/breathing_halo.dart';
import 'package:relaxmate/features/mascot/ui/mascot_view.dart';
import 'package:relaxmate/shared/widgets/rb_app_bar.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';

/// SCR-M13: Temani saja (FR-M015). Di atas gradien tenang: satu kalimat, satu petunjuk,
/// dan "Selesai"; di bawahnya maskot setengah badan yang menempel di tepi layar dengan
/// cincin napas pelan di belakang kepalanya (TASK-M073 bagian 9). Lokal: tanpa AI, tanpa
/// kuota, tanpa internet. Hanya perlu masuk; tidak dibungkus `ConsentGate`. Bilah atas
/// memakai `RbAppBar.pushed` (kembali, nama layar, SOS) yang transparan supaya layar tetap
/// sunyi dan jalan ke bantuan tetap ada. Gerak: masuk berurutan sekali, napas maskot dan
/// cincin; keduanya diam bila gerak dikurangi.
class CompanionScreen extends StatelessWidget {
  const CompanionScreen({super.key});

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final size = MediaQuery.sizeOf(context);
    final mascotHeight = (size.height * RbSize.companionMascotHeightFactor)
        .clamp(RbSize.companionMascotMin, RbSize.companionMascotMax)
        .toDouble();
    final haloDiameter = math.min(
      mascotHeight * RbSize.companionHaloFactor,
      size.width,
    );
    final headBottom = mascotHeight * RbSize.companionHeadFromBottom;
    final sceneHeight = headBottom + haloDiameter / 2;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const RbAppBar.pushed(title: AppTexts.companionTitle),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colors.gradientTop,
              colors.gradientMid,
              colors.gradientBottom,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: space.lg,
                      vertical: space.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RbEntrance(
                          child: Semantics(
                            header: true,
                            child: Text(
                              AppTexts.companionBody,
                              textAlign: TextAlign.center,
                              style: text.h1,
                            ),
                          ),
                        ),
                        SizedBox(height: space.sm),
                        RbEntrance(
                          index: 1,
                          child: Text(
                            AppTexts.companionHint,
                            textAlign: TextAlign.center,
                            style: text.body.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: space.lg),
                        RbEntrance(
                          index: 2,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(
                                RbSize.companionButtonWidth,
                                RbSize.minTouch,
                              ),
                            ),
                            onPressed: () => _leave(context),
                            child: const Text(AppTexts.companionDone),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              RbEntrance(
                index: 3,
                child: SizedBox(
                  width: double.infinity,
                  height: sceneHeight,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Positioned(
                        bottom: headBottom - haloDiameter / 2,
                        child: BreathingHalo(diameter: haloDiameter),
                      ),
                      MascotView(
                        state: MascotState.idle,
                        height: mascotHeight,
                        outlined: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
