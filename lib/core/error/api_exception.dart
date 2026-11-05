import 'package:relaxmate/core/error/api_error_kind.dart';

/// Galat API yang sudah dipetakan. `message` selalu aman ditampilkan: berasal dari
/// amplop galat server (`error.message`, Bahasa Indonesia) atau teks bawaan klien.
/// Tidak pernah memuat jejak tumpukan atau isi respons mentah (RULE-M035).
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.code,
    this.statusCode,
    this.retryAfterSeconds,
    this.fieldErrors = const <String, String>{},
  });

  final ApiErrorKind kind;
  final String message;

  /// Kode dari server, mis. `daily_limit`, `busy`, `consent_required`.
  final String? code;
  final int? statusCode;
  final int? retryAfterSeconds;

  /// Galat validasi per kolom (422), kunci = nama kolom.
  final Map<String, String> fieldErrors;

  bool hasCode(String value) => code == value;

  /// Sengaja tanpa `message`: aman bila ikut tercatat di log (RULE-M040).
  @override
  String toString() =>
      'ApiException(${kind.name}, code: $code, status: $statusCode)';
}
