import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/rb_app_bar.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// Kerangka semua layar Latihan (daftar, napas, grounding): latar gradien lembut yang sama
/// dengan Beranda (`SoftGradientBackground`, CMP-M33) di belakang `RbAppBar`. Daftar Latihan
/// adalah layar tab ([root] `true`: logo, nama fitur, SOS, dan navigasi bawah lewat
/// [bottomNavigationBar]); napas dan grounding adalah layar lanjutan (tombol kembali, nama
/// layar, SOS). Isi ([body]) sudah berada di dalam `SafeArea`.
class ExerciseScaffold extends StatelessWidget {
  const ExerciseScaffold({
    required this.title,
    required this.body,
    this.root = false,
    this.bottomNavigationBar,
    super.key,
  });

  final String title;
  final Widget body;
  final bool root;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return Scaffold(
      backgroundColor: colors.pageBg,
      extendBodyBehindAppBar: true,
      appBar:
          root ? RbAppBar.root(title: title) : RbAppBar.pushed(title: title),
      bottomNavigationBar: bottomNavigationBar,
      body: SoftGradientBackground(child: SafeArea(child: body)),
    );
  }
}
