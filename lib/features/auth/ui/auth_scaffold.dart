import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/crisis_help_button.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// Kerangka layar tamu dan sesi (Masuk, Daftar, Lupa sandi, Cek email, sesi belum bisa
/// diperiksa, consent): latar gradien lembut, bilah atas (tombol kembali bila ada, tombol
/// "Bantuan" di kanan), judul, keterangan, lalu isi.
///
/// Dua tata letak. [alignStart] `true` (Masuk, Daftar, Lupa sandi): judul rata kiri dan isi
/// memenuhi tinggi layar tanpa gulir; sisa ruang diserap `Spacer` yang ditaruh layar di
/// dalam [children] (biasanya di atas tombol utama, sehingga tombol menempel ke bawah).
/// Gulir hanya muncul bila isi memang lebih tinggi dari layar: papan ketik terbuka, teks
/// 200%, atau layar pendek (RULE-M055). Bawaan `false` (layar status): avatar dan judul di
/// tengah, isi di tengah layar, bisa digulir.
///
/// Jalur ke Kontak bantuan selalu ada lewat [CrisisHelpButton] di bilah atas (Design-M
/// prinsip 4, TASK-M025), tanpa memakan baris sendiri.
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
    return Scaffold(
      body: SoftGradientBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _TopBar(showBack: alignStart && context.canPop()),
              Expanded(
                child: alignStart
                    ? _FillBody(
                        title: title,
                        subtitle: subtitle,
                        children: children,
                      )
                    : _CenteredBody(
                        title: title,
                        subtitle: subtitle,
                        children: children,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lebar sisi kiri dan kanan agar isi tetap selebar [RbSize.authMaxContentWidth] di layar
/// lebar, dengan batas dalam sebesar jarak `lg`.
double _sidePadding(BuildContext context, double width) {
  final inner = context.rbSpace.lg;
  return math.max(inner, (width - RbSize.authMaxContentWidth) / 2 + inner);
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showBack});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _sidePadding(context, constraints.maxWidth);
        return Padding(
          padding: EdgeInsets.fromLTRB(side, space.xs, side, 0),
          child: Row(
            children: <Widget>[
              if (showBack)
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
              const CrisisHelpButton(),
            ],
          ),
        );
      },
    );
  }
}

/// Masuk, Daftar, Lupa sandi: isi memenuhi tinggi yang tersedia; menggulir hanya bila
/// isi lebih tinggi (`SliverFillRemaining` tanpa badan gulir).
class _FillBody extends StatelessWidget {
  const _FillBody({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _sidePadding(context, constraints.maxWidth);
        return CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, space.xs, side, space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _Header(title: title, subtitle: subtitle, alignStart: true),
                    SizedBox(height: space.md),
                    ...children,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Layar status (Cek email, sesi, consent): avatar dan judul di tengah, isi di tengah.
class _CenteredBody extends StatelessWidget {
  const _CenteredBody({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: RbSize.authMaxContentWidth),
          child: Padding(
            padding: EdgeInsets.all(space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Header(title: title, subtitle: subtitle, alignStart: false),
                SizedBox(height: space.lg),
                ...children,
              ],
            ),
          ),
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
        if (!alignStart) ...<Widget>[
          const MateAvatar(),
          SizedBox(height: space.md),
        ],
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
