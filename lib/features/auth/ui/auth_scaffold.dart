import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';

/// Kerangka layar tamu dan sesi (Daftar, Masuk, Lupa sandi, Cek email, sesi belum
/// bisa diperiksa): avatar, judul, keterangan, lalu isi. Bisa digulir agar muat saat
/// keyboard terbuka dan saat teks 200% (RULE-M055).
///
/// Tautan Kontak bantuan selalu ada di bawah isi (Design-M prinsip 4, TASK-M025).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final description = subtitle;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Center(child: MateAvatar()),
                SizedBox(height: space.md),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: text.h2,
                  ),
                ),
                if (description != null) ...<Widget>[
                  SizedBox(height: space.xs),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: text.body.copyWith(color: colors.textSecondary),
                  ),
                ],
                SizedBox(height: space.lg),
                ...children,
                SizedBox(height: space.md),
                TextButton(
                  onPressed: () => context.push(AppRoutes.crisisContacts),
                  child: const Text(AppTexts.crisisNeedHelp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
