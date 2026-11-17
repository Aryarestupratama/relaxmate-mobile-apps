import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M65: kotak ikon di kiri baris Pengaturan. Latarnya pastel dari token [tint] yang
/// dicampur ke putih; ikon navy (RULE-M052). Hanya dekorasi, tanpa semantik (arti baris ada di
/// tulisannya).
class SettingsIconChip extends StatelessWidget {
  const SettingsIconChip({required this.icon, required this.tint, super.key});

  final IconData icon;
  final Color tint;

  /// Seberapa kuat [tint] dicampurkan ke putih.
  static const double _tintStrength = 0.55;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return ExcludeSemantics(
      child: Container(
        width: RbSize.settingsRowChip,
        height: RbSize.settingsRowChip,
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            tint.withValues(alpha: _tintStrength),
            colors.card,
          ),
          borderRadius: BorderRadius.circular(RbSize.settingsRowChipRadius),
        ),
        child: Icon(
          icon,
          size: RbSize.settingsRowIcon,
          color: colors.primary,
        ),
      ),
    );
  }
}
