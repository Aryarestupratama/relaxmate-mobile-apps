import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Judul satu kelompok di Pengaturan (CMP-M63): teks tebal sejajar dengan tepi dalam kartu di
/// bawahnya, bertanda `header` untuk pembaca layar.
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;

    return Padding(
      padding: EdgeInsets.only(left: space.xs, bottom: space.xs),
      child: Semantics(
        header: true,
        child: Text(title, style: context.rbText.h3),
      ),
    );
  }
}
