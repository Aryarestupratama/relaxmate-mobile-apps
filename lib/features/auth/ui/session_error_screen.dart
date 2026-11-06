import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/auth/ui/auth_scaffold.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// Tampil bila token tersimpan tetapi sesi belum bisa diperiksa (offline, timeout,
/// galat server). Token tidak dihapus: pengguna bisa mencoba lagi, atau keluar di
/// perangkat ini saja.
class SessionErrorScreen extends ConsumerWidget {
  const SessionErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.rbSpace;
    final auth = ref.watch(authControllerProvider);
    final message = auth is AuthSessionCheckFailed
        ? auth.error.message
        : AppTexts.errorGeneric;
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScaffold(
      title: AppTexts.sessionCheckTitle,
      subtitle: AppTexts.sessionCheckBody,
      children: <Widget>[
        ErrorAlert(message: message, onRetry: controller.retry),
        SizedBox(height: space.md),
        TextButton(
          onPressed: controller.signOutLocally,
          child: const Text(AppTexts.logout),
        ),
      ],
    );
  }
}
