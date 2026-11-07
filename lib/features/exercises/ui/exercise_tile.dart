import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Satu pilihan latihan di daftar latihan (SCR-M08 menu "Latihan"): ikon, judul, keterangan
/// satu baris, dan panah. Tinggi minimal 48dp (RULE-M055).
class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.xxs),
      child: Semantics(
        button: true,
        label: AppTexts.exerciseTileLabel(title, subtitle),
        onTap: onTap,
        excludeSemantics: true,
        child: Material(
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: RbRadius.cardBorder,
            side: BorderSide(color: colors.border, width: RbSize.borderThin),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: RbRadius.cardBorder,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: RbSize.minTouch),
              child: Padding(
                padding: EdgeInsets.all(space.md),
                child: Row(
                  children: <Widget>[
                    Icon(icon, size: RbSize.icon, color: colors.primary),
                    SizedBox(width: space.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(title, style: text.h3),
                          Text(
                            subtitle,
                            style: text.small.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: RbSize.icon,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
