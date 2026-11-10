import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/settings/state/settings_controller.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// Lapisan privasi (NFR-M01 `[Assumption]`, TASK-M031): selama aplikasi tidak di depan layar
/// (berpindah aplikasi, daftar aplikasi terbaru), isi layar ditutup gambar polos berisi avatar
/// supaya percakapan tidak terlihat di pratinjau. Dapat dimatikan di Pengaturan. Membungkus
/// seluruh aplikasi, jadi juga memuat pengaturan lokal saat aplikasi dibuka.
///
/// Upaya terbaik di sisi Flutter: Android mengambil pratinjau saat jendela kehilangan fokus,
/// dan penutup dipasang pada saat yang sama. Bila di perangkat tertentu pratinjau tetap
/// terlihat, langkah berikutnya adalah `FLAG_SECURE` di sisi native.
class PrivacyCover extends ConsumerStatefulWidget {
  const PrivacyCover({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PrivacyCover> createState() => _PrivacyCoverState();
}

class _PrivacyCoverState extends ConsumerState<PrivacyCover>
    with WidgetsBindingObserver {
  bool _away = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final away = state != AppLifecycleState.resumed;
    if (away != _away) {
      setState(() => _away = away);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(
      settingsControllerProvider.select((settings) => settings.privacyCover),
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (enabled && _away)
          ColoredBox(
            color: context.rbColors.pageBg,
            child: const Center(
              child: ExcludeSemantics(
                child: MateAvatar(size: MateAvatarSize.large),
              ),
            ),
          ),
      ],
    );
  }
}
