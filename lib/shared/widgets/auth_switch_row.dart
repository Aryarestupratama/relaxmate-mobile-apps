import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M34: baris pindah antara Masuk dan Daftar: kalimat pendek lalu tautan tebal, mis.
/// "Belum punya akun? Daftar". Satu `Semantics` menggabungkan keduanya; tautannya tetap
/// target sentuh 48dp (tema `TextButton`).
class AuthSwitchRow extends StatelessWidget {
  const AuthSwitchRow({
    required this.prompt,
    required this.action,
    required this.onPressed,
    super.key,
  });

  final String prompt;
  final String action;

  /// Null menonaktifkan tautan (mis. selagi mengirim).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: space.xxs,
      children: <Widget>[
        Text(prompt, style: text.small.copyWith(color: colors.textSecondary)),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}
