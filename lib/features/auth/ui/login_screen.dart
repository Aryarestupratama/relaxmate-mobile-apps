import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/ui/auth_scaffold.dart';
import 'package:relaxmate/features/auth/ui/auth_validators.dart';
import 'package:relaxmate/features/auth/ui/password_field.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M04: Masuk. Berhasil: `AuthController` memperbarui sesi dan router memindahkan
/// layar (Cek email bila belum terverifikasi, selain itu layar utama).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Set<String> _fieldKeys = <String>{'email', 'password'};

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  Map<String, String> _errors = const <String, String>{};
  String? _formError;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _clearError(String key) {
    if (!_errors.containsKey(key)) {
      return;
    }
    final updated = Map<String, String>.of(_errors)..remove(key);
    setState(() => _errors = updated);
  }

  void _focusFirstError(Map<String, String> errors) {
    if (errors.containsKey('email')) {
      _emailFocus.requestFocus();
    } else if (errors.containsKey('password')) {
      _passwordFocus.requestFocus();
    }
  }

  Future<void> _submit() async {
    final errors = <String, String>{};
    final emailError = AuthValidators.email(_email.text);
    if (emailError != null) {
      errors['email'] = emailError;
    }
    final passwordError = AuthValidators.password(_password.text);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    if (errors.isNotEmpty) {
      setState(() {
        _errors = errors;
        _formError = null;
      });
      _focusFirstError(errors);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _errors = const <String, String>{};
      _formError = null;
      _submitting = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _email.text.trim(),
            password: _password.text,
          );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final fields = error.fieldErrors;
      final shownInline = fields.keys.any(_fieldKeys.contains);
      setState(() {
        _submitting = false;
        _errors = fields;
        _formError = shownInline ? null : error.message;
      });
      _focusFirstError(fields);
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final formError = _formError;

    return AuthScaffold(
      title: AppTexts.loginTitle,
      subtitle: AppTexts.loginSubtitle,
      children: <Widget>[
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _email,
                focusNode: _emailFocus,
                readOnly: _submitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => _clearError('email'),
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: AppTexts.fieldEmail,
                  errorText: _errors['email'],
                ),
              ),
              SizedBox(height: space.md),
              PasswordField(
                controller: _password,
                focusNode: _passwordFocus,
                readOnly: _submitting,
                errorText: _errors['password'],
                onChanged: (_) => _clearError('password'),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        if (formError != null) ...<Widget>[
          SizedBox(height: space.md),
          ErrorAlert(message: formError),
        ],
        SizedBox(height: space.lg),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_submitting ? AppTexts.processing : AppTexts.loginAction),
        ),
        SizedBox(height: space.xs),
        TextButton(
          onPressed: _submitting
              ? null
              : () => context.push<void>(AppRoutes.forgotPassword),
          child: const Text(AppTexts.loginToForgot),
        ),
        TextButton(
          onPressed:
              _submitting ? null : () => context.push<void>(AppRoutes.register),
          child: const Text(AppTexts.loginToRegister),
        ),
      ],
    );
  }
}
