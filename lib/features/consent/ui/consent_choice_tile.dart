import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M20: kartu pilihan tunggal (setara tombol radio). Terpilih ditandai ikon, tebal
/// garis, dan latar, bukan warna saja (RULE-M052). Tinggi minimal 48dp (RULE-M055).
class ConsentChoiceTile extends StatelessWidget {
  const ConsentChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;

  /// `null` menonaktifkan kartu (mis. saat menyimpan).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      container: true,
      excludeSemantics: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: onTap != null,
      onTap: onTap,
      label: label,
      child: Material(
        color: selected ? colors.surfaceAlt : colors.card,
        borderRadius: RbRadius.cardBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: RbRadius.cardBorder,
          child: Container(
            constraints: const BoxConstraints(minHeight: RbSize.minTouch),
            padding: EdgeInsets.symmetric(
              horizontal: space.md,
              vertical: space.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: RbRadius.cardBorder,
              border: Border.all(
                color: selected ? colors.primary : colors.inputBorder,
                width: selected ? RbSize.borderSelected : RbSize.borderThin,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: colors.primary,
                  size: RbSize.icon,
                ),
                SizedBox(width: space.sm),
                Expanded(child: Text(label, style: text.body)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
