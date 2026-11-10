import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/overlay/data/overlay_permissions.dart';
import 'package:relaxmate/features/overlay/data/overlay_platform.dart';
import 'package:relaxmate/features/overlay/state/overlay_home_provider.dart';
import 'package:relaxmate/features/overlay/state/overlay_permissions_controller.dart';
import 'package:relaxmate/features/settings/state/settings_controller.dart';

/// SCR-M18: Maskot mengambang (FR-M022, Architecture-M 6.4). Penjelasan sebelum izin, saklar
/// (bawaan mati), status dua izin, dan tombol ke pengaturan sistem. Menyalakan saklar memulai
/// `OverlayService` (gelembung, TASK-M033); mematikannya menghentikan layanan.
///
/// Alur menyalakan: (1) bila izin "tampil di atas aplikasi lain" belum ada, dialog penjelasan
/// lalu halaman izin sistem; hasilnya tidak dikembalikan, jadi status dibaca ulang saat
/// aplikasi kembali ke depan dan alur dilanjutkan; (2) izin notifikasi diminta (Android 13+),
/// tetapi penolakan tidak menghentikan alur; (3) layanan dimulai dan pilihan disimpan. Penolakan dihormati dan
/// tidak ada desakan (kebijakan Play untuk izin khusus).
class OverlaySettingsScreen extends ConsumerStatefulWidget {
  const OverlaySettingsScreen({super.key});

  @override
  ConsumerState<OverlaySettingsScreen> createState() =>
      _OverlaySettingsScreenState();
}

class _OverlaySettingsScreenState extends ConsumerState<OverlaySettingsScreen>
    with WidgetsBindingObserver {
  /// Pengguna sedang di halaman izin sistem demi menyalakan maskot; lanjutkan saat kembali.
  bool _resumeEnableFlow = false;
  bool _busy = false;

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
    if (state == AppLifecycleState.resumed) {
      _onResumed();
    }
  }

  Future<void> _onResumed() async {
    // Layanan native dapat mengubah pilihan sendiri (Nonaktifkan, Istirahat sampai besok).
    await ref.read(settingsControllerProvider.notifier).reload();
    ref.invalidate(overlayRestProvider);
    if (!mounted) {
      return;
    }
    final permissions =
        await ref.read(overlayPermissionsControllerProvider.notifier).refresh();
    if (!mounted) {
      return;
    }
    if (_resumeEnableFlow) {
      _resumeEnableFlow = false;
      if (permissions.canDrawOverlays) {
        await _finishEnable();
      }
    } else if (ref.read(settingsControllerProvider).overlayEnabled &&
        (!permissions.canDrawOverlays || !permissions.running)) {
      // Izin dicabut, atau layanan berhenti tanpa sepengetahuan layar (mis. ponsel dimulai
      // ulang atau sistem mematikannya): pilihan ikut dimatikan agar tidak menyesatkan.
      await ref.read(settingsControllerProvider.notifier).setOverlayEnabled(
            false,
          );
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _toggle(bool enable) async {
    if (_busy) {
      return;
    }
    if (!enable) {
      await ref.read(settingsControllerProvider.notifier).setOverlayEnabled(
            false,
          );
      await ref.read(overlayPlatformProvider).stop();
      if (mounted) {
        await ref.read(overlayPermissionsControllerProvider.notifier).refresh();
      }
      return;
    }

    setState(() => _busy = true);
    try {
      final permissions = await ref
          .read(overlayPermissionsControllerProvider.notifier)
          .refresh();
      if (!mounted) {
        return;
      }
      if (permissions.canDrawOverlays) {
        await _finishEnable();
        return;
      }
      final confirmed = await _explainOverlayPermission();
      if (!confirmed || !mounted) {
        return;
      }
      _resumeEnableFlow = true;
      final opened =
          await ref.read(overlayPlatformProvider).openOverlaySettings();
      if (!opened) {
        _resumeEnableFlow = false;
        if (mounted) {
          _snack(AppTexts.overlaySettingsFailed);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<bool> _explainOverlayPermission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.overlayExplainTitle),
        content: const Text(AppTexts.overlayExplainBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppTexts.overlayExplainLater),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppTexts.overlayExplainConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Langkah terakhir menyalakan: minta izin notifikasi (penolakan tidak menghentikan), lalu
  /// simpan pilihan.
  Future<void> _finishEnable() async {
    final platform = ref.read(overlayPlatformProvider);
    final permissions = ref.read(overlayPermissionsControllerProvider).value;
    if (permissions != null && !permissions.notificationsGranted) {
      await platform.requestNotifications();
      if (mounted) {
        await ref.read(overlayPermissionsControllerProvider.notifier).refresh();
      }
    }
    if (!mounted) {
      return;
    }
    // Layanan dimulai dari sini, saat aplikasi terbuka (syarat Android 15).
    final started = await platform.start();
    if (!mounted) {
      return;
    }
    await ref.read(settingsControllerProvider.notifier).setOverlayEnabled(
          started,
        );
    if (!started) {
      _snack(AppTexts.overlayStartFailed);
    }
  }

  Future<void> _requestNotifications() async {
    final platform = ref.read(overlayPlatformProvider);
    final granted = await platform.requestNotifications();
    if (!granted) {
      // Dialog sistem tidak muncul lagi setelah ditolak berulang: arahkan ke pengaturan.
      final opened = await platform.openNotificationSettings();
      if (!opened && mounted) {
        _snack(AppTexts.overlaySettingsFailed);
      }
    }
    if (mounted) {
      await ref.read(overlayPermissionsControllerProvider.notifier).refresh();
    }
  }

  /// "sampai besok" bila masih jauh (istirahat sampai besok), jam bila dekat (1 jam).
  String _restLabel(DateTime until) {
    if (until.difference(DateTime.now()) > const Duration(hours: 2)) {
      return AppTexts.overlayRestingTomorrow;
    }
    final hour = until.hour.toString().padLeft(2, '0');
    final minute = until.minute.toString().padLeft(2, '0');
    return AppTexts.overlayRestingUntil('$hour.$minute');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final settings = ref.watch(settingsControllerProvider);
    final permissions = ref.watch(overlayPermissionsControllerProvider).value ??
        OverlayPermissions.unsupported;
    final effectiveOn = settings.overlayEnabled && permissions.canDrawOverlays;
    final restUntil = ref.watch(overlayRestProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.overlayTitle)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(space.lg),
          children: <Widget>[
            Text(AppTexts.overlayIntro, style: text.body),
            SizedBox(height: space.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: effectiveOn,
              onChanged: _busy ? null : _toggle,
              title: Text(AppTexts.overlayToggle, style: text.body),
            ),
            if (restUntil != null) ...<Widget>[
              Text(
                _restLabel(restUntil),
                style: text.small.copyWith(color: colors.textSecondary),
              ),
            ],
            SizedBox(height: space.md),
            _PermissionRow(
              label: AppTexts.overlayPermissionOverlay,
              granted: permissions.canDrawOverlays,
            ),
            if (!permissions.canDrawOverlays)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _busy
                      ? null
                      : () => ref
                          .read(overlayPlatformProvider)
                          .openOverlaySettings(),
                  child: const Text(AppTexts.overlayOpenSettings),
                ),
              ),
            SizedBox(height: space.sm),
            _PermissionRow(
              label: AppTexts.overlayPermissionNotifications,
              granted: permissions.notificationsGranted,
            ),
            if (!permissions.notificationsGranted) ...<Widget>[
              Text(
                AppTexts.overlayNotificationsHint,
                style: text.small.copyWith(color: colors.textSecondary),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _busy ? null : _requestNotifications,
                  child: const Text(AppTexts.overlayAllowNotifications),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.label, required this.granted});

  final String label;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final status =
        granted ? AppTexts.overlayGranted : AppTexts.overlayNotGranted;

    return Semantics(
      container: true,
      label: '$label: $status',
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: text.body)),
            Text(
              status,
              style: text.body.copyWith(
                color: granted ? colors.success : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
