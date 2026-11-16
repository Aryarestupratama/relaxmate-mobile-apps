import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/crisis/ui/sos_button.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// Kerangka semua layar Latihan (daftar, napas, grounding): latar gradien lembut yang sama
/// dengan Beranda (`SoftGradientBackground`, CMP-M33) di belakang bilah atas yang
/// transparan, judul, dan tombol SOS di kanan atas. Isi ([body]) sudah berada di dalam
/// `SafeArea`. [bottomNavigationBar] diisi hanya oleh tab Latihan.
class ExerciseScaffold extends StatelessWidget {
  const ExerciseScaffold({
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    super.key,
  });

  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;

    return Scaffold(
      backgroundColor: colors.pageBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: const <Widget>[SosAppBarAction()],
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SoftGradientBackground(child: SafeArea(child: body)),
    );
  }
}
