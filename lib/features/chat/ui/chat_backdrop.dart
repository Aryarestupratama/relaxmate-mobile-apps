import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M39: latar layar obrolan, dipakai di tampilan obrolan dan tampilan maskot. Gradien
/// putih (`pageBg`) ke lavender sangat tipis (`softLavender`, 35%) dari atas ke bawah, polos
/// tanpa bulatan atau pola (bulatan warna-warni dari TASK-M073 bagian 7 dihapus 2026-11-15
/// karena terbaca seperti polkadot). Statis (tanpa gerak berulang) di dalam
/// `RepaintBoundary`, jadi gulir daftar pesan tidak menggambar ulang latar. Hanya dekorasi:
/// tidak menerima sentuhan dan tanpa semantik. Memudar masuk sekali; bila gerak dikurangi
/// langsung tampil.
class ChatBackdrop extends StatelessWidget {
  const ChatBackdrop({super.key});

  /// Seberapa kuat lavender dicampur ke dasar gradien di bagian bawah.
  static const double _washStrength = 0.35;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final Widget gradient = RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colors.pageBg,
              Color.alphaBlend(
                colors.softLavender.withValues(alpha: _washStrength),
                colors.pageBg,
              ),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: MediaQuery.disableAnimationsOf(context)
            ? gradient
            : gradient
                .animate()
                .fadeIn(duration: RbMotion.ripple, curve: RbMotion.curve),
      ),
    );
  }
}
