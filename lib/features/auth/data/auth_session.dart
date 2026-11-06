import 'package:relaxmate/features/auth/data/user_summary.dart';

/// Hasil register atau login (API-M001, API-M002): token dan ringkasan pengguna.
/// Token hanya disimpan lewat `TokenStorage` dan tidak pernah dicatat (RULE-M040).
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final UserSummary user;

  /// Sengaja tanpa token dan email: aman bila ikut tercatat di log.
  @override
  String toString() => 'AuthSession(verified: ${user.emailVerified})';
}
