import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// Satu pilihan latihan di daftar Latihan (SCR-M10): kartu putih melayang (`FloatingCard`)
/// berisi lingkaran ikon pastel, judul, keterangan satu baris, dan panah. Tinggi minimal 48dp
/// (RULE-M055). Satu warna pastel tipis per ubin ([tint]), tanpa gerak sendiri.
class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;

  /// Seberapa kuat [tint] dicampurkan ke putih pada lingkaran ikon.
  static const double _chipTintStrength = 0.55;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      button: true,
      label: AppTexts.exerciseTileLabel(title, subtitle),
      onTap: onTap,
      excludeSemantics: true,
      child: FloatingCard(
        padding: EdgeInsets.zero,
        clip: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: RbSize.minTouch),
              child: Padding(
                padding: EdgeInsets.all(space.md),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: RbSize.exerciseIconChip,
                      height: RbSize.exerciseIconChip,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.alphaBlend(
                          tint.withValues(alpha: _chipTintStrength),
                          colors.card,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: RbSize.icon,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(width: space.md),
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
