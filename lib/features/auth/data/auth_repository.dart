import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/auth/data/auth_session.dart';
import 'package:relaxmate/features/auth/data/resend_result.dart';
import 'package:relaxmate/features/auth/data/user_summary.dart';

/// API-M001 sampai M006: akun dan sesi. Semua panggilan lewat `ApiClient`.
/// Validasi sebenarnya tetap di server (RULE-M023).
class AuthRepository {
  const AuthRepository(this._api);

  final ApiClient _api;

  /// API-M001. `terms: true` dikirim karena pengguna sudah mencentangnya di layar.
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _api.post(
      '/auth/register',
      authenticated: false,
      body: <String, Object?>{
        'name': name,
        'email': email,
        'password': password,
        'terms': true,
      },
    );
    return _parseSession(json);
  }

  /// API-M002.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _api.post(
      '/auth/login',
      authenticated: false,
      body: <String, Object?>{'email': email, 'password': password},
    );
    return _parseSession(json);
  }

  /// API-M003: mencabut token saat ini (balasan 204 tanpa isi).
  Future<void> logout() async {
    await _api.post('/auth/logout');
  }

  /// API-M004. Balasan selalu sama, terdaftar atau tidak. Mengembalikan pesan server.
  Future<String> forgotPassword(String email) async {
    final json = await _api.post(
      '/auth/forgot-password',
      authenticated: false,
      body: <String, Object?>{'email': email},
    );
    final message = json['message'];
    return message is String && message.trim().isNotEmpty
        ? message.trim()
        : AppTexts.forgotSentFallback;
  }

  /// API-M005.
  Future<ResendResult> resendVerification() async {
    final json = await _api.post('/auth/resend-verification');
    return ResendResult(
      emailVerified: json['email_verified'] == true,
      emailSent: json['email_sent'] == true,
    );
  }

  /// API-M006. Saat ini hanya bagian `user` yang dibaca; `consent`, `limits`, dan
  /// `crisis_contacts_version` dibaca pada task fiturnya (M023, M024, M025).
  Future<UserSummary> fetchMe() async {
    final json = await _api.get('/me');
    final user = json['user'];
    if (user is! JsonMap) {
      throw _malformed();
    }
    return UserSummary.fromJson(user);
  }

  AuthSession _parseSession(JsonMap json) {
    final token = json['token'];
    final user = json['user'];
    if (token is! String || token.isEmpty || user is! JsonMap) {
      throw _malformed();
    }
    return AuthSession(token: token, user: UserSummary.fromJson(user));
  }

  /// Bentuk balasan tidak sesuai kontrak: tampilkan galat umum, tanpa detail.
  ApiException _malformed() {
    return const ApiException(
      kind: ApiErrorKind.unknown,
      message: AppTexts.errorGeneric,
    );
  }
}

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
