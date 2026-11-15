import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M48: tombol bulat "Tenangkan diri" di kiri kolom ketik pada tampilan maskot chat.
/// Membuka lembar bawah berisi dua latihan lokal (napas, grounding) yang langsung membuka
/// layar latihannya. Selalu ada, tidak bergantung pada saran AI, jadi pengguna bisa menenangkan
/// diri kapan pun tanpa menunggu balasan. Latihan berjalan di perangkat (tanpa kuota).
class CalmActionsButton extends StatelessWidget {
  const CalmActionsButton({super.key});

  Future<void> _open(BuildContext context) {
    final colors = context.rbColors;
    final router = GoRouter.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RbRadius.sheet),
        ),
      ),
      builder: (sheetContext) => _CalmSheet(
        onPick: (route) {
          Navigator.of(sheetContext).pop();
          router.push<void>(route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return Tooltip(
      message: AppTexts.calmTooltip,
      child: Semantics(
        button: true,
        label: AppTexts.calmTooltip,
        excludeSemantics: true,
        onTap: () => _open(context),
        child: Material(
          color: colors.card,
          shape: CircleBorder(side: BorderSide(color: colors.inputBorder)),
          shadowColor: colors.primary.withValues(alpha: 0.2),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _open(context),
            child: SizedBox.square(
              dimension: RbSize.minTouch,
              child: Icon(LucideIcons.wind, color: colors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalmSheet extends StatelessWidget {
  const _CalmSheet({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    Widget tile({
      required IconData icon,
      required String title,
      required String hint,
      required String route,
    }) {
      return Padding(
        padding: EdgeInsets.only(bottom: space.xs),
        child: Material(
          color: colors.surfaceAlt,
          borderRadius: RbRadius.cardBorder,
          child: InkWell(
            borderRadius: RbRadius.cardBorder,
            onTap: () => onPick(route),
            child: Padding(
              padding: EdgeInsets.all(space.sm),
              child: Row(
                children: <Widget>[
                  Container(
                    width: RbSize.avatarSmall,
                    height: RbSize.avatarSmall,
                    decoration: BoxDecoration(
                      color: colors.softLavender,
                      shape: BoxShape.circle,
                      boxShadow: RbShadow.card(colors),
                    ),
                    child: Icon(icon, color: colors.primary),
                  ),
                  SizedBox(width: space.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: text.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          hint,
                          style: text.small.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(space.md, 0, space.md, space.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(AppTexts.calmSheetTitle, style: text.h3),
            ),
            SizedBox(height: space.xxs),
            Text(
              AppTexts.calmSheetBody,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.sm),
            tile(
              icon: LucideIcons.wind,
              title: AppTexts.breathingTitle,
              hint: AppTexts.calmBreathingHint,
              route: AppRoutes.breathing,
            ),
            tile(
              icon: LucideIcons.eye,
              title: AppTexts.groundingTitle,
              hint: AppTexts.calmGroundingHint,
              route: AppRoutes.grounding,
            ),
          ],
        ),
      ),
    );
  }
}
