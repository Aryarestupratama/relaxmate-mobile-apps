import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/ui/password_field.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M19: Hapus akun (FR-M003). Meminta kata sandi, lalu satu konfirmasi terakhir sebelum
/// memanggil API-M017. Berhasil: sesi berakhir dan router membawa pengguna ke layar Masuk.
/// Terbuka juga bagi akun yang belum terverifikasi.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final TextEditingController _password = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  String? _passwordError;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<bool> _confirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.deleteConfirmTitle),
        content: const Text(AppTexts.deleteConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppTexts.deleteCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.rbColors.danger,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppTexts.deleteConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _submit() async {
    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = AppTexts.fieldPasswordRequired;
        _error = null;
      });
      _passwordFocus.requestFocus();
      return;
    }
    if (!await _confirm() || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
      _passwordError = null;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .deleteAccount(_password.text);
      // Berhasil: sesi berakhir dan router meninggalkan layar ini.
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final passwordError = error.fieldErrors['password'];
      setState(() {
        _busy = false;
        _passwordError = passwordError;
        _error = passwordError == null
            ? error.fieldErrors['account'] ?? error.message
            : null;
      });
      if (passwordError != null) {
        _passwordFocus.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.settingsDeleteAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(AppTexts.deleteBody, style: text.body),
              SizedBox(height: space.lg),
              PasswordField(
                controller: _password,
                focusNode: _passwordFocus,
                errorText: _passwordError,
                readOnly: _busy,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
                onSubmitted: (_) => _submit(),
              ),
              if (error != null) ...<Widget>[
                SizedBox(height: space.md),
                ErrorAlert(message: error),
              ],
              SizedBox(height: space.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.danger,
                  foregroundColor: colors.onPrimary,
                ),
                onPressed: _busy ? null : _submit,
                child: Text(
                  _busy ? AppTexts.processing : AppTexts.deleteButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
