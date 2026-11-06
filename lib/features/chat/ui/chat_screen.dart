import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// SCR-M08 (sementara): layar sambutan agar fondasi bisa dicoba.
/// TODO(TASK-M024): ganti dengan aliran chat harian.
/// TODO(TASK-M031): pindahkan tombol Keluar dan info akun ke Pengaturan.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final auth = ref.watch(authControllerProvider);
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const MateAvatar(size: MateAvatarSize.large),
                SizedBox(height: space.md),
                Semantics(
                  header: true,
                  child: Text(AppTexts.appName, style: text.h1),
                ),
                SizedBox(height: space.xs),
                Text(
                  AppTexts.welcome,
                  textAlign: TextAlign.center,
                  style: text.body.copyWith(color: colors.textSecondary),
                ),
                if (auth is AuthAuthenticated) ...<Widget>[
                  SizedBox(height: space.lg),
                  Text(
                    AppTexts.signedInAs(auth.user.email),
                    textAlign: TextAlign.center,
                    style: text.small.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: space.xs),
                  TextButton(
                    onPressed: ref.read(authControllerProvider.notifier).logout,
                    child: const Text(AppTexts.logout),
                  ),
                ],
                if (!config.flavor.isProd) ...<Widget>[
                  SizedBox(height: space.lg),
                  Text(
                    AppTexts.devBadge,
                    style: text.caption.copyWith(color: colors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
