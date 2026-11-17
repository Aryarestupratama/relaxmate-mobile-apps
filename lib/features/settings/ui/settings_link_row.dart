import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/settings/ui/settings_icon_chip.dart';

/// CMP-M66: baris Pengaturan yang membuka layar atau tautan: kotak ikon, judul, keterangan
/// opsional, dan panah. Seluruh baris bisa disentuh; tinggi minimal 56dp (RULE-M055).
class SettingsLinkRow extends StatelessWidget {
  const SettingsLinkRow({
    required this.icon,
    required this.tint,
    required this.label,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final hint = subtitle;

    return Semantics(
      button: true,
      label: label,
      hint: hint,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: RbSize.settingsRowMinHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: space.md,
                vertical: space.sm,
              ),
              child: Row(
                children: <Widget>[
                  SettingsIconChip(icon: icon, tint: tint),
                  SizedBox(width: space.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(label, style: text.body),
                        if (hint != null)
                          Text(
                            hint,
                            style: text.caption.copyWith(
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
    );
  }
}
