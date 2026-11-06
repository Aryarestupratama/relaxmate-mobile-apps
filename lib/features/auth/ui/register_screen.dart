import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/launch/web_launcher.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/ui/auth_scaffold.dart';
import 'package:relaxmate/features/auth/ui/auth_validators.dart';
import 'package:relaxmate/features/auth/ui/password_field.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M03: Daftar. Aturan sama dengan web (FR-M001); akunnya akun RelaxBoss yang sama.
/// Berhasil: pengguna sudah masuk dan router memindahkannya ke Cek email (SCR-M06).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const Set<String> _fieldKeys = <String>{
    'name',
    'email',
    'password',
    'terms',
  };

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  Map<String, String> _errors = const <String, String>{};
  String? _formError;
  bool _termsAccepted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _nameFocus.dispose();
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
    if (errors.containsKey('name')) {
      _nameFocus.requestFocus();
    } else if (errors.containsKey('email')) {
      _emailFocus.requestFocus();
    } else if (errors.containsKey('password')) {
      _passwordFocus.requestFocus();
    }
  }

  Future<void> _openWeb(String path) async {
    final uri = ref.read(appConfigProvider).webUri(path);
    final opened = await ref.read(webLauncherProvider).open(uri);
    if (!opened && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(AppTexts.webOpenFailed)),
      );
    }
  }

  Future<void> _submit() async {
    final errors = <String, String>{};
    final nameError = AuthValidators.name(_name.text);
    if (nameError != null) {
      errors['name'] = nameError;
    }
    final emailError = AuthValidators.email(_email.text);
    if (emailError != null) {
      errors['email'] = emailError;
    }
    final passwordError = AuthValidators.password(_password.text);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }
    if (!_termsAccepted) {
      errors['terms'] = AppTexts.termsRequired;
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
      await ref.read(authControllerProvider.notifier).register(
            name: _name.text.trim(),
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
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final formError = _formError;
    final termsError = _errors['terms'];

    return AuthScaffold(
      title: AppTexts.registerTitle,
      subtitle: AppTexts.registerSubtitle,
      children: <Widget>[
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _name,
                focusNode: _nameFocus,
                readOnly: _submitting,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.name],
                onChanged: (_) => _clearError('name'),
                onSubmitted: (_) => _emailFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: AppTexts.fieldName,
                  errorText: _errors['name'],
                ),
              ),
              SizedBox(height: space.md),
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
                autofillHints: const <String>[AutofillHints.newPassword],
                onChanged: (_) => _clearError('password'),
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ],
          ),
        ),
        SizedBox(height: space.sm),
        CheckboxListTile(
          value: _termsAccepted,
          onChanged: _submitting
              ? null
              : (value) => setState(() {
                    _termsAccepted = value ?? false;
                    _errors = Map<String, String>.of(_errors)..remove('terms');
                  }),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(AppTexts.termsAccept, style: text.small),
        ),
        if (termsError != null)
          Padding(
            padding: EdgeInsets.only(bottom: space.xs),
            child: Semantics(
              liveRegion: true,
              child: Text(
                termsError,
                style: text.caption.copyWith(color: colors.danger),
              ),
            ),
          ),
        Wrap(
          spacing: space.xs,
          children: <Widget>[
            TextButton(
              onPressed: () => _openWeb(AppConstants.termsPath),
              child: const Text(AppTexts.termsLink),
            ),
            TextButton(
              onPressed: () => _openWeb(AppConstants.privacyPath),
              child: const Text(AppTexts.privacyLink),
            ),
          ],
        ),
        if (formError != null) ...<Widget>[
          SizedBox(height: space.md),
          ErrorAlert(message: formError),
        ],
        SizedBox(height: space.lg),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(
            _submitting ? AppTexts.processing : AppTexts.registerAction,
          ),
        ),
        SizedBox(height: space.xs),
        TextButton(
          onPressed: _submitting ? null : () => context.go(AppRoutes.login),
          child: const Text(AppTexts.registerToLogin),
        ),
      ],
    );
  }
}
