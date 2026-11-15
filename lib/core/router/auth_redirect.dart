import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/features/auth/data/user_summary.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/onboarding/state/onboarding_controller.dart';

/// Memutuskan layar mana yang boleh tampil menurut keadaan sesi. Mengembalikan
/// `null` bila [location] sudah benar, atau jalur tujuan pengalihan.
///
/// - Kontak bantuan (SCR-M16): selalu boleh, di keadaan apa pun (Design-M prinsip 4).
/// - Memeriksa token tersimpan: hanya layar peralihan `/memuat`.
/// - Sesi belum bisa diperiksa: hanya layar `/sesi` (coba lagi atau keluar).
/// - Tamu: hanya Sambutan, Masuk, Daftar, Lupa sandi. Tamu yang belum pernah melihat
///   sambutan diarahkan ke sambutan (SCR-M02), selain itu langsung ke Masuk; selagi penanda
///   [onboarding] dibaca, tamu menunggu di layar peralihan.
/// - Masuk tetapi email belum terverifikasi: hanya Cek email (SCR-M06) dan Hapus akun
///   (SCR-M19).
/// - Masuk dan terverifikasi: tidak boleh di layar tamu atau peralihan.
String? authRedirect(
  AuthState auth,
  String location, {
  OnboardingStatus onboarding = OnboardingStatus.seen,
}) {
  if (location == AppRoutes.crisisContacts) {
    return null;
  }
  return switch (auth) {
    AuthRestoring() =>
      location == AppRoutes.restoring ? null : AppRoutes.restoring,
    AuthSessionCheckFailed() =>
      location == AppRoutes.sessionError ? null : AppRoutes.sessionError,
    AuthUnauthenticated() => _guestRedirect(location, onboarding),
    AuthAuthenticated(:final user) => _authenticatedRedirect(user, location),
  };
}

String? _guestRedirect(String location, OnboardingStatus onboarding) {
  if (onboarding == OnboardingStatus.loading) {
    return location == AppRoutes.restoring ? null : AppRoutes.restoring;
  }
  if (AppRoutes.guestOnly.contains(location)) {
    return null;
  }
  return onboarding == OnboardingStatus.unseen
      ? AppRoutes.welcome
      : AppRoutes.login;
}

String? _authenticatedRedirect(UserSummary user, String location) {
  if (!user.emailVerified) {
    final allowed =
        location == AppRoutes.checkEmail || location == AppRoutes.deleteAccount;
    return allowed ? null : AppRoutes.checkEmail;
  }

  final leaving = AppRoutes.guestOnly.contains(location) ||
      AppRoutes.transitional.contains(location);
  return leaving ? AppRoutes.home : null;
}
