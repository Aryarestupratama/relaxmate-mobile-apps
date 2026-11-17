import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// CMP-M68: kartu akun di puncak Pengaturan: lingkaran navy berisi huruf pertama nama, nama,
/// dan email, di atas latar lavender yang memudar ke putih. Hanya baca. Bila nama kosong,
/// lingkaran diganti avatar RelaxMate. Satu elemen untuk pembaca layar.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    required this.name,
    required this.email,
    super.key,
  });

  final String name;
  final String email;

  /// Seberapa kuat `softLavender` dicampurkan di ujung kiri atas kartu.
  static const double _tintStrength = 0.9;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final trimmed = name.trim();
    final initial =
        trimmed.isEmpty ? '' : String.fromCharCode(trimmed.runes.first);

    return Semantics(
      container: true,
      label: AppTexts.settingsProfileLabel(name, email),
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(space.md),
        decoration: BoxDecoration(
          borderRadius: RbRadius.sheetBorder,
          boxShadow: RbShadow.card(colors),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(
                colors.softLavender.withValues(alpha: _tintStrength),
                colors.card,
              ),
              colors.card,
            ],
          ),
        ),
        child: Row(
          children: <Widget>[
            if (initial.isEmpty)
              const MateAvatar(size: MateAvatarSize.medium)
            else
              Container(
                width: RbSize.settingsAvatar,
                height: RbSize.settingsAvatar,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                ),
                child: Text(
                  initial.toUpperCase(),
                  style: text.h2.copyWith(color: colors.onPrimary),
                ),
              ),
            SizedBox(width: space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    trimmed.isEmpty ? email : trimmed,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.h3,
                  ),
                  if (trimmed.isNotEmpty)
                    Text(
                      email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.small.copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
