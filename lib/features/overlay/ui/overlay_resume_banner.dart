import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/overlay/data/overlay_platform.dart';
import 'package:relaxmate/features/overlay/data/overlay_snooze_repository.dart';
import 'package:relaxmate/features/overlay/state/overlay_home_provider.dart';
import 'package:relaxmate/features/settings/state/settings_controller.dart';

/// Tawaran di atas chat untuk menyalakan maskot lagi setelah waktu istirahatnya lewat
/// (FR-M023). Tidak tampil bila tidak ada yang ditawarkan. Dimulai dari ketukan pengguna saat
/// aplikasi terbuka, jadi sah untuk memulai layanan di Android 15.
class OverlayResumeBanner extends ConsumerWidget {
  const OverlayResumeBanner({super.key});

  Future<void> _resume(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await ref.read(overlaySnoozeRepositoryProvider).clear();
    final started = await ref.read(overlayPlatformProvider).start();
    if (started) {
      await ref.read(settingsControllerProvider.notifier).setOverlayEnabled(
            true,
          );
    } else {
      messenger?.showSnackBar(
        const SnackBar(content: Text(AppTexts.overlayStartFailed)),
      );
    }
    ref.invalidate(overlayHomeProvider);
  }

  Future<void> _later(WidgetRef ref) async {
    await ref.read(overlaySnoozeRepositoryProvider).clear();
    ref.invalidate(overlayHomeProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(overlayHomeProvider).value ?? false;
    if (!offer) {
      return const SizedBox.shrink();
    }
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Padding(
      padding: EdgeInsets.fromLTRB(space.md, space.sm, space.md, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: RbRadius.cardBorder,
        ),
        child: Padding(
          padding: EdgeInsets.all(space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppTexts.overlayResumeOffer, style: text.body),
              SizedBox(height: space.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => _later(ref),
                    child: const Text(AppTexts.overlayResumeLater),
                  ),
                  FilledButton(
                    onPressed: () => _resume(context, ref),
                    child: const Text(AppTexts.overlayResumeYes),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
