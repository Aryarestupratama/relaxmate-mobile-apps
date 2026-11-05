import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/startup/state/version_gate_provider.dart';
import 'package:relaxmate/features/startup/state/version_gate_status.dart';
import 'package:relaxmate/features/startup/ui/splash_view.dart';
import 'package:relaxmate/features/startup/ui/update_required_screen.dart';

/// Membungkus seluruh aplikasi: menahan [child] sampai pemeriksaan versi selesai,
/// dan menggantinya dengan layar "Perbarui aplikasi" bila versi terlalu lama.
class StartupGate extends ConsumerWidget {
  const StartupGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(versionGateProvider);

    return gate.when(
      data: (status) => status == VersionGateStatus.updateRequired
          ? const UpdateRequiredScreen()
          : child,
      loading: () => const SplashView(),
      error: (error, stackTrace) => child,
    );
  }
}
