import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/auth/data/user_summary.dart';

/// Keadaan sesi pengguna. Router memilih layar dari keadaan ini (`authRedirect`).
sealed class AuthState {
  const AuthState();
}

/// Aplikasi sedang membaca token tersimpan dan memeriksanya ke server.
class AuthRestoring extends AuthState {
  const AuthRestoring();
}

/// Belum masuk: tidak ada token, atau server menolaknya (401).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sudah masuk. Email bisa belum terverifikasi (`user.emailVerified`).
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserSummary user;
}

/// Token tersimpan tetapi sesi belum bisa diperiksa (offline, timeout, galat server).
/// Pengguna diberi pilihan coba lagi atau keluar; token tidak dihapus.
class AuthSessionCheckFailed extends AuthState {
  const AuthSessionCheckFailed(this.error);

  final ApiException error;
}
