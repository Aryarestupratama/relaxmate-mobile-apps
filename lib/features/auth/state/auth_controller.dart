import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/api/session_expired_signal.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/auth/data/auth_repository.dart';
import 'package:relaxmate/features/auth/data/auth_session.dart';
import 'package:relaxmate/features/auth/data/resend_result.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';

/// Pemilik keadaan sesi: memulihkan token saat aplikasi dibuka, masuk, daftar, keluar,
/// dan memperbarui status verifikasi email. Metode yang gagal melempar `ApiException`
/// (pesannya aman ditampilkan); layar yang memanggil menampilkannya.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // 401 dari permintaan mana pun mengakhiri sesi (RULE-M035).
    final signal = ref.watch(sessionExpiredSignalProvider);
    signal.addListener(_onSessionExpired);
    ref.onDispose(() => signal.removeListener(_onSessionExpired));

    // Dijalankan setelah `build` selesai agar `state` sudah terpasang.
    unawaited(Future<void>.microtask(restore));
    return const AuthRestoring();
  }

  /// Membaca token tersimpan lalu memeriksanya ke server (`GET /me`).
  Future<void> restore() async {
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) {
      state = const AuthUnauthenticated();
      return;
    }
    await _loadUser();
  }

  /// Mengulang pemeriksaan sesi dari layar "belum bisa memeriksa sesi".
  Future<void> retry() => _loadUser();

  Future<void> _loadUser() async {
    state = const AuthRestoring();
    try {
      final user = await ref.read(authRepositoryProvider).fetchMe();
      state = AuthAuthenticated(user);
    } on ApiException catch (error) {
      // 401: `ApiClient` sudah menghapus token dan memberi sinyal; hasilnya sama.
      state = error.kind == ApiErrorKind.unauthorized
          ? const AuthUnauthenticated()
          : AuthSessionCheckFailed(error);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await _startSession(session);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .register(name: name, email: email, password: password);
    await _startSession(session);
  }

  /// Mengembalikan pesan server (balasan selalu sama, terdaftar atau tidak).
  Future<String> forgotPassword(String email) {
    return ref.read(authRepositoryProvider).forgotPassword(email);
  }

  /// Memeriksa ulang status email ke server. Mengembalikan true bila sudah
  /// terverifikasi; router lalu memindahkan pengguna ke layar utama.
  Future<bool> refreshUser() async {
    final user = await ref.read(authRepositoryProvider).fetchMe();
    state = AuthAuthenticated(user);
    return user.emailVerified;
  }

  /// Kirim ulang email verifikasi. Bila ternyata sudah terverifikasi, sesi diperbarui.
  Future<ResendResult> resendVerification() async {
    final result = await ref.read(authRepositoryProvider).resendVerification();
    if (result.emailVerified) {
      await refreshUser();
    }
    return result;
  }

  /// Keluar: mencabut token di server, lalu menghapusnya dari perangkat. Tanpa internet
  /// pun pengguna tetap keluar di perangkat ini.
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on ApiException {
      await _endSession();
      return;
    }
    await _endSession();
  }

  /// Menghapus akun di server (butuh kata sandi), lalu mengakhiri sesi di perangkat. Bila
  /// server menolak, galatnya dilempar dan sesi tetap berjalan.
  Future<void> deleteAccount(String password) async {
    await ref.read(authRepositoryProvider).deleteAccount(password);
    await _endSession();
  }

  /// Keluar hanya di perangkat (tanpa memanggil server), mis. saat server tak terjangkau.
  Future<void> signOutLocally() => _endSession();

  Future<void> _startSession(AuthSession session) async {
    try {
      await ref.read(tokenStorageProvider).write(session.token);
    } on PlatformException {
      // Keystore gagal menyimpan: tanpa token tersimpan sesi tidak bisa dipulihkan.
      throw const ApiException(
        kind: ApiErrorKind.unknown,
        message: AppTexts.errorGeneric,
      );
    }
    state = AuthAuthenticated(session.user);
  }

  Future<void> _endSession() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthUnauthenticated();
  }

  void _onSessionExpired() {
    state = const AuthUnauthenticated();
  }
}

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
