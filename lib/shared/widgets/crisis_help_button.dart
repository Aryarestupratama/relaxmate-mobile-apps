import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M35: tombol "Bantuan" kecil berbentuk pil untuk pojok kanan atas layar tamu dan
/// sesi (Sambutan, Masuk, Daftar, Lupa sandi, Cek email, consent). Membuka Kontak bantuan
/// (SCR-M16), yang bekerja tanpa internet. Jalur ke bantuan tetap selalu ada (Design-M
/// prinsip 4) tanpa memakan satu baris sendiri. Target sentuh >= 48dp; pembaca layar
/// membaca "Kontak bantuan".
class CrisisHelpButton extends StatelessWidget {
  const CrisisHelpButton({super.key});

  /// Seberapa pekat latar pil (turunan token `card`) di atas gradien.
  static const double _surfaceAlpha = 0.7;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return Tooltip(
      message: AppTexts.crisisMenuTooltip,
      child: TextButton.icon(
        onPressed: () => context.push<void>(AppRoutes.crisisContacts),
        icon: const Icon(LucideIcons.phone, size: RbSize.crisisHelpIcon),
        label: const Text(AppTexts.crisisHelpShort),
        style: TextButton.styleFrom(
          backgroundColor: colors.card.withValues(alpha: _surfaceAlpha),
          shape: StadiumBorder(side: BorderSide(color: colors.border)),
        ),
      ),
    );
  }
}
