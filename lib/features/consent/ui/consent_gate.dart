import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/consent/state/consent_controller.dart';
import 'package:relaxmate/features/consent/state/consent_gate_state.dart';
import 'package:relaxmate/features/consent/ui/consent_error_screen.dart';
import 'package:relaxmate/features/consent/ui/consent_screen.dart';
import 'package:relaxmate/features/startup/ui/splash_view.dart';

/// Gerbang consent (FR-M002): [child] hanya tampil setelah consent AI dan pilihan pelatihan
/// lengkap. Membungkus setiap layar yang memakai fitur AI (sekarang `ChatScreen`; riwayat
/// dan Cek Rasa menyusul). Latihan dan kontak bantuan tidak dibungkus gerbang ini.
class ConsentGate extends ConsumerWidget {
  const ConsentGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(consentControllerProvider)) {
      ConsentChecking() => const SplashView(),
      ConsentRequired(:final prompt) => ConsentScreen(prompt: prompt),
      ConsentCheckFailed(:final error) => ConsentErrorScreen(error: error),
      ConsentComplete() => child,
    };
  }
}
