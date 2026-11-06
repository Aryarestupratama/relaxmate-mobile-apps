import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/features/auth/data/user_summary.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';

/// Memutuskan layar mana yang boleh tampil menurut keadaan sesi. Mengembalikan
/// `null` bila [location] sudah benar, atau jalur tujuan pengalihan.
///
/// - Memeriksa token tersimpan: hanya layar peralihan `/memuat`.
/// - Sesi belum bisa diperiksa: hanya layar `/sesi` (coba lagi atau keluar).
/// - Tamu: hanya Masuk, Daftar, Lupa sandi.
/// - Masuk tetapi email belum terverifikasi: hanya Cek email (SCR-M06).
/// - Masuk dan terverifikasi: tidak boleh di layar tamu atau peralihan.
String? authRedirect(AuthState auth, String location) {
  return switch (auth) {
    AuthRestoring() =>
      location == AppRoutes.restoring ? null : AppRoutes.restoring,
    AuthSessionCheckFailed() =>
      location == AppRoutes.sessionError ? null : AppRoutes.sessionError,
    AuthUnauthenticated() =>
      AppRoutes.guestOnly.contains(location) ? null : AppRoutes.login,
    AuthAuthenticated(:final user) => _authenticatedRedirect(user, location),
  };
}

String? _authenticatedRedirect(UserSummary user, String location) {
  if (!user.emailVerified) {
    return location == AppRoutes.checkEmail ? null : AppRoutes.checkEmail;
  }

  final leaving = AppRoutes.guestOnly.contains(location) ||
      AppRoutes.transitional.contains(location);
  return leaving ? AppRoutes.chat : null;
}
