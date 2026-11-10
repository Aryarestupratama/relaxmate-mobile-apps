import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/auth/ui/auth_scaffold.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

enum _Busy { none, checking, resending, signingOut }

/// SCR-M06: Cek email. Tampil selama email belum terverifikasi. Pengguna bisa memeriksa
/// ulang, kirim ulang email (maks. 3 per jam, dibatasi server), atau keluar. Saat
/// aplikasi kembali ke depan layar, status diperiksa diam-diam; bila sudah terverifikasi
/// router memindahkan layar ini ke layar utama.
class CheckEmailScreen extends ConsumerStatefulWidget {
  const CheckEmailScreen({super.key});

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen>
    with WidgetsBindingObserver {
  _Busy _busy = _Busy.none;
  String? _error;

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
    if (state == AppLifecycleState.resumed && _busy == _Busy.none) {
      unawaited(_checkSilently());
    }
  }

  /// Pengguna biasanya baru kembali dari aplikasi email atau peramban: periksa tanpa
  /// menampilkan apa pun bila gagal.
  Future<void> _checkSilently() async {
    try {
      await ref.read(authControllerProvider.notifier).refreshUser();
    } on ApiException {
      return;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _check() async {
    setState(() {
      _busy = _Busy.checking;
      _error = null;
    });

    try {
      final verified =
          await ref.read(authControllerProvider.notifier).refreshUser();
      if (!mounted) {
        return;
      }
      setState(() => _busy = _Busy.none);
      if (!verified) {
        _showSnack(AppTexts.checkEmailNotYet);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = _Busy.none;
        _error = error.message;
      });
    }
  }

  Future<void> _resend() async {
    setState(() {
      _busy = _Busy.resending;
      _error = null;
    });

    try {
      final result =
          await ref.read(authControllerProvider.notifier).resendVerification();
      if (!mounted) {
        return;
      }
      setState(() => _busy = _Busy.none);
      if (!result.emailVerified) {
        _showSnack(
          result.emailSent ? AppTexts.checkEmailResent : AppTexts.errorGeneric,
        );
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = _Busy.none;
        _error = error.message;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _busy = _Busy.signingOut;
      _error = null;
    });
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      setState(() => _busy = _Busy.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final auth = ref.watch(authControllerProvider);
    final email = auth is AuthAuthenticated ? auth.user.email : '';
    final error = _error;
    final idle = _busy == _Busy.none;

    return AuthScaffold(
      title: AppTexts.checkEmailTitle,
      subtitle: AppTexts.checkEmailBody(email),
      children: <Widget>[
        if (error != null) ...<Widget>[
          ErrorAlert(message: error),
          SizedBox(height: space.md),
        ],
        FilledButton(
          onPressed: idle ? _check : null,
          child: Text(
            _busy == _Busy.checking
                ? AppTexts.processing
                : AppTexts.checkEmailDone,
          ),
        ),
        SizedBox(height: space.sm),
        OutlinedButton(
          onPressed: idle ? _resend : null,
          child: Text(
            _busy == _Busy.resending
                ? AppTexts.processing
                : AppTexts.checkEmailResend,
          ),
        ),
        SizedBox(height: space.xs),
        TextButton(
          onPressed: idle ? _logout : null,
          child: Text(
            _busy == _Busy.signingOut ? AppTexts.processing : AppTexts.logout,
          ),
        ),
        // API-M017 tidak meminta email terverifikasi: yang salah mengetik email tetap bisa
        // menghapus datanya.
        TextButton(
          onPressed:
              idle ? () => context.push<void>(AppRoutes.deleteAccount) : null,
          child: const Text(AppTexts.settingsDeleteAccount),
        ),
      ],
    );
  }
}
