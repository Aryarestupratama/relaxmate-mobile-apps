import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/settings/ui/settings_icon_chip.dart';

/// CMP-M67: baris Pengaturan dengan sakelar: kotak ikon, judul, keterangan, dan `Switch` yang
/// warnanya dari token (navy bila nyala, `surfaceAlt` berbingkai bila mati; keadaannya juga
/// terbaca dari posisi bulatan, bukan warna saja, RULE-M052). Seluruh baris bisa disentuh;
/// tinggi minimal 56dp. Pembaca layar menerima satu elemen berstatus nyala atau mati.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      container: true,
      toggled: value,
      label: title,
      hint: subtitle,
      onTap: () => onChanged(!value),
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onChanged(!value),
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
                        Text(title, style: text.body),
                        Text(
                          subtitle,
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: space.sm),
                  ExcludeSemantics(
                    child: SwitchTheme(
                      data: SwitchThemeData(
                        thumbColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => states.contains(WidgetState.selected)
                              ? colors.onPrimary
                              : colors.inputBorder,
                        ),
                        trackColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => states.contains(WidgetState.selected)
                              ? colors.primary
                              : colors.surfaceAlt,
                        ),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>(
                          (states) => states.contains(WidgetState.selected)
                              ? colors.primary
                              : colors.inputBorder,
                        ),
                      ),
                      child: Switch(value: value, onChanged: onChanged),
                    ),
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
