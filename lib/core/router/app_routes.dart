/// Jalur rute. Satu tempat agar tidak ada string jalur tersebar di widget.
abstract final class AppRoutes {
  /// Rumah aplikasi: aliran harian RelaxMate (SCR-M08).
  static const String chat = '/';

  /// Peralihan saat token tersimpan sedang diperiksa (SCR-M01).
  static const String restoring = '/memuat';

  /// Peralihan saat sesi belum bisa diperiksa (offline, timeout, galat server).
  static const String sessionError = '/sesi';

  static const String login = '/masuk'; // SCR-M04
  static const String register = '/daftar'; // SCR-M03
  static const String forgotPassword = '/lupa-sandi'; // SCR-M05
  static const String checkEmail = '/cek-email'; // SCR-M06

  /// Layar yang hanya untuk tamu; pengguna yang sudah masuk dialihkan keluar.
  static const Set<String> guestOnly = <String>{
    login,
    register,
    forgotPassword
  };

  /// Layar peralihan yang tidak boleh ditinggali pengguna terverifikasi.
  static const Set<String> transitional = <String>{
    restoring,
    sessionError,
    checkEmail,
  };
}
