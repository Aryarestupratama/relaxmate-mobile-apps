import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/ui/auth_scaffold.dart';
import 'package:relaxmate/features/consent/state/consent_controller.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// Tampil bila status consent belum bisa diperiksa (offline, timeout, galat server).
/// Pengguna bisa mencoba lagi atau keluar; fitur AI tetap tertahan.
class ConsentErrorScreen extends ConsumerWidget {
  const ConsentErrorScreen({required this.error, super.key});

  final ApiException error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.rbSpace;

    return AuthScaffold(
      title: AppTexts.consentCheckTitle,
      subtitle: AppTexts.consentCheckBody,
      children: <Widget>[
        ErrorAlert(
          message: error.message,
          onRetry: ref.read(consentControllerProvider.notifier).load,
        ),
        SizedBox(height: space.md),
        TextButton(
          onPressed: ref.read(authControllerProvider.notifier).logout,
          child: const Text(AppTexts.logout),
        ),
      ],
    );
  }
}
