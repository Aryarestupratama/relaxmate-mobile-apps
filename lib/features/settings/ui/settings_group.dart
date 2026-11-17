import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// CMP-M64: satu kartu melayang berisi beberapa baris Pengaturan (`SettingsLinkRow`,
/// `SettingsSwitchRow`) yang dipisah garis tipis. Garis dimulai di sejajar teks, bukan di
/// tepi kartu, supaya kotak ikon tetap menjadi kolom sendiri. Isi dipotong mengikuti sudut
/// kartu agar riak sentuhan tidak keluar.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;

    return FloatingCard(
      padding: EdgeInsets.zero,
      clip: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0)
              Divider(
                height: RbSize.borderThin,
                thickness: RbSize.borderThin,
                indent: space.md + RbSize.settingsRowChip + space.sm,
                color: colors.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
