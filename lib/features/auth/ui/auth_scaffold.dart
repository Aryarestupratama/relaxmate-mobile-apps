import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// Kerangka layar tamu dan sesi (Masuk, Daftar, Lupa sandi, Cek email, sesi belum bisa
/// diperiksa, consent): latar gradien lembut di atas, judul, keterangan, lalu isi. Bisa
/// digulir agar muat saat papan ketik terbuka dan saat teks 200% (RULE-M055).
///
/// Dua tata letak. [alignStart] `true` (Masuk, Daftar, Lupa sandi): tombol kembali bila ada
/// layar sebelumnya, avatar kecil, judul rata kiri, isi mulai dari atas. Bawaan `false`
/// (layar status): avatar dan judul di tengah, isi di tengah layar.
///
/// Tautan Kontak bantuan selalu ada di bawah isi (Design-M prinsip 4, TASK-M025).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    this.alignStart = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: RbSize.authMaxContentWidth),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: space.lg,
          vertical: alignStart ? space.md : space.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(
              title: title,
              subtitle: subtitle,
              alignStart: alignStart,
            ),
            SizedBox(height: space.lg),
            ...children,
            SizedBox(height: space.md),
            TextButton(
              onPressed: () => context.push<void>(AppRoutes.crisisContacts),
              child: const Text(
                AppTexts.crisisNeedHelp,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SoftGradientBackground(
        child: SafeArea(
          child: alignStart
              ? SingleChildScrollView(child: Center(child: content))
              : Center(child: SingleChildScrollView(child: content)),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.alignStart,
  });

  final String title;
  final String? subtitle;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final description = subtitle;
    final align = alignStart ? TextAlign.start : TextAlign.center;

    return Column(
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: <Widget>[
        if (alignStart)
          Row(
            children: <Widget>[
              if (context.canPop()) ...<Widget>[
                IconButton.outlined(
                  onPressed: () => context.pop(),
                  tooltip: AppTexts.authBack,
                  icon: const Icon(LucideIcons.arrowLeft),
                  style: IconButton.styleFrom(
                    side: BorderSide(color: colors.border),
                    backgroundColor: colors.card,
                    minimumSize: const Size.square(RbSize.minTouch),
                  ),
                ),
                const Spacer(),
              ],
              const MateAvatar(size: MateAvatarSize.small),
            ],
          )
        else
          const MateAvatar(),
        SizedBox(height: space.md),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: align,
            style: alignStart ? text.h1 : text.h2,
          ),
        ),
        if (description != null) ...<Widget>[
          SizedBox(height: space.xs),
          Text(
            description,
            textAlign: align,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}
