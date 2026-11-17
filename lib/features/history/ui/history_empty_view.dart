import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/ui/mascot_aura.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';

/// CMP-M61: keadaan kosong Riwayat (RULE-M053): maskot di atas cahaya lembut, judul, satu
/// kalimat, dan ajakan "Mulai ngobrol" yang membuka Ngobrol. Gambar maskot diam (gerak
/// ditiadakan di layar yang kosong) dan hanya dekorasi.
class HistoryEmptyView extends StatelessWidget {
  const HistoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(space.lg),
        child: RbEntrance(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const MascotAura(diameter: RbSize.historyEmptyAura),
                  ExcludeSemantics(
                    child: Image.asset(
                      AppAssets.mascotStillOutlined,
                      height: RbSize.historyEmptyMascot,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: space.md),
              Semantics(
                header: true,
                child: Text(
                  AppTexts.historyEmptyTitle,
                  textAlign: TextAlign.center,
                  style: text.h2,
                ),
              ),
              SizedBox(height: space.xs),
              Text(
                AppTexts.historyEmpty,
                textAlign: TextAlign.center,
                style: text.body.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: space.lg),
              FilledButton(
                onPressed: () => context.go(AppRoutes.chat),
                child: const Text(AppTexts.historyEmptyAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
