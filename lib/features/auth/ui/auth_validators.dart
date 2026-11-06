import 'package:relaxmate/core/texts/app_texts.dart';

/// Validasi klien hanya untuk kemudahan (RULE-M023): kolom wajib terisi dan bentuk
/// email. Aturan sebenarnya (panjang sandi, email unik, dan lain-lain) dinilai server;
/// pesannya ditampilkan di bawah kolom yang bersangkutan.
abstract final class AuthValidators {
  static final RegExp _emailShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String value) {
    return value.trim().isEmpty ? AppTexts.fieldNameRequired : null;
  }

  static String? email(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return AppTexts.fieldEmailRequired;
    }
    return _emailShape.hasMatch(text) ? null : AppTexts.fieldEmailInvalid;
  }

  /// Sandi tidak dipangkas: spasi di ujung dianggap bagian dari sandi.
  static String? password(String value) {
    return value.isEmpty ? AppTexts.fieldPasswordRequired : null;
  }
}
