import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';
import 'package:relaxmate/features/mascot/ui/mascot_view.dart';

/// SCR-M13: Temani saja (FR-M015). Maskot bernapas pelan di atas latar gradien tenang, satu
/// kalimat, dan "Selesai". Lokal: tanpa AI, tanpa kuota, tanpa internet. Hanya perlu masuk;
/// tidak dibungkus `ConsentGate`. Tanpa AppBar agar layar tetap sunyi; kembali lewat
/// "Selesai" atau tombol kembali sistem.
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

    return Scaffold(
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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(space.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const MascotView(
                    state: MascotState.idle,
                    height: RbSize.mascotCompanionHeight,
                  ),
                  SizedBox(height: space.lg),
                  Semantics(
                    header: true,
                    child: Text(
                      AppTexts.companionBody,
                      textAlign: TextAlign.center,
                      style: text.h2,
                    ),
                  ),
                  SizedBox(height: space.xl),
                  FilledButton(
                    onPressed: () => _leave(context),
                    child: const Text(AppTexts.companionDone),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
