import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/router/app_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/features/overlay/data/overlay_platform.dart';

/// Menerima perintah dari maskot mengambang: "Ngobrol" membuka aplikasi lalu mengantar ke chat
/// walau aplikasi sedang di layar lain. Sisi Kotlin menitipkan perintahnya di intent; di sini
/// diambil saat aplikasi dibuka atau kembali ke depan. "Bicara" menyusul bersama mode suara.
class OverlayLaunchListener extends ConsumerStatefulWidget {
  const OverlayLaunchListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OverlayLaunchListener> createState() =>
      _OverlayLaunchListenerState();
}

class _OverlayLaunchListenerState extends ConsumerState<OverlayLaunchListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  Future<void> _check() async {
    final action = await ref.read(overlayPlatformProvider).takeLaunchAction();
    if (action == 'chat' && mounted) {
      ref.read(routerProvider).go(AppRoutes.chat);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
