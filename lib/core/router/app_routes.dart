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

  /// Kontak bantuan (SCR-M16): terbuka untuk semua keadaan sesi (FR-M011).
  static const String crisisContacts = '/kontak-bantuan';

  /// Riwayat (SCR-M14) dan detail hari hanya baca (SCR-M15), keduanya di balik consent.
  static const String history = '/riwayat';

  static String historyDetail(String conversationId) =>
      '$history/$conversationId';

  /// Latihan lokal: daftar, latihan napas (SCR-M11), grounding 5-4-3-2-1 (SCR-M12). Hanya
  /// perlu masuk; di luar `ConsentGate` karena tanpa AI (FR-M014).
  static const String exercises = '/latihan';
  static const String breathing = '/latihan/napas';
  static const String grounding = '/latihan/grounding';

  /// Temani saja (SCR-M13): hanya perlu masuk; di luar `ConsentGate` karena tanpa AI dan
  /// tanpa kuota (FR-M015).
  static const String companion = '/temani';

  /// Pengaturan (SCR-M17) dan Hapus akun (SCR-M19). Pengaturan perlu email terverifikasi;
  /// Hapus akun juga terbuka bagi akun yang belum terverifikasi (API-M017 tanpa
  /// `api.verified`), supaya yang salah mengetik email tetap bisa menghapus datanya.
  static const String settings = '/pengaturan';
  static const String deleteAccount = '/pengaturan/hapus-akun';

  /// Maskot mengambang (SCR-M18), Android saja (TASK-M032).
  static const String overlaySettings = '/pengaturan/maskot';

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
