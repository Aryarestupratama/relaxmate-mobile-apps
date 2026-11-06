import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';

/// Kolom kata sandi dengan tombol tampil/sembunyikan (target sentuh 48dp, berlabel
/// untuk TalkBack lewat `tooltip`). Galat ditampilkan di bawah kolom lewat [errorText].
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.readOnly = false,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const <String>[AutofillHints.password],
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final bool readOnly;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      obscureText: _obscured,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: AppTexts.fieldPassword,
        errorText: widget.errorText,
        suffixIcon: IconButton(
          tooltip: _obscured ? AppTexts.showPassword : AppTexts.hidePassword,
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}
