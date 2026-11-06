import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/ui/auth_scaffold.dart';
import 'package:relaxmate/features/auth/ui/auth_validators.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M05: Lupa kata sandi. Server membalas sama baik email terdaftar maupun tidak,
/// jadi layar ini menampilkan pesan server apa adanya. Penggantian sandi diselesaikan
/// di peramban lewat halaman web `/reset-sandi/{token}` (Architecture-M bagian 7).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  String? _emailError;
  String? _formError;
  String? _sentMessage;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = AuthValidators.email(_email.text);
    if (emailError != null) {
      setState(() {
        _emailError = emailError;
        _formError = null;
      });
      _emailFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _formError = null;
      _submitting = true;
    });

    try {
      final message = await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(_email.text.trim());
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _sentMessage = message;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final fieldError = error.fieldErrors['email'];
      setState(() {
        _submitting = false;
        _emailError = fieldError;
        _formError = fieldError == null ? error.message : null;
      });
      if (fieldError != null) {
        _emailFocus.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final sent = _sentMessage;
    final formError = _formError;

    if (sent != null) {
      return AuthScaffold(
        title: AppTexts.forgotTitle,
        children: <Widget>[
          _SentNote(message: sent),
          SizedBox(height: space.lg),
          FilledButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text(AppTexts.forgotBack),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: AppTexts.forgotTitle,
      subtitle: AppTexts.forgotSubtitle,
      children: <Widget>[
        TextField(
          controller: _email,
          focusNode: _emailFocus,
          readOnly: _submitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.email],
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: AppTexts.fieldEmail,
            errorText: _emailError,
          ),
        ),
        if (formError != null) ...<Widget>[
          SizedBox(height: space.md),
          ErrorAlert(message: formError),
        ],
        SizedBox(height: space.lg),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(
            _submitting ? AppTexts.processing : AppTexts.forgotAction,
          ),
        ),
        SizedBox(height: space.xs),
        TextButton(
          onPressed: _submitting ? null : () => context.go(AppRoutes.login),
          child: const Text(AppTexts.forgotBack),
        ),
      ],
    );
  }
}

/// Catatan sukses: ikon dan teks (warna bukan satu-satunya pembawa makna, RULE-M052).
class _SentNote extends StatelessWidget {
  const _SentNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(space.md),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: RbRadius.cardBorder,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(
                Icons.mark_email_read_outlined,
                color: colors.success,
                size: RbSize.icon,
              ),
            ),
            SizedBox(width: space.sm),
            Expanded(child: Text(message, style: text.small)),
          ],
        ),
      ),
    );
  }
}
