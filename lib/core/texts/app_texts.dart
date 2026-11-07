/// Bank teks UI (RULE-M054). Nada: "kamu", hangat, tidak menggurui.
/// Teks panjang (privasi, ketentuan) ada di `assets/texts`; teks consent dan
/// Crisis Response berasal dari API, bukan disalin di sini (RULE-049 web).
abstract final class AppTexts {
  static const String appName = 'RelaxMate';

  static const String welcome =
      'Halo, aku RelaxMate. Teman ceritamu. Aku bukan psikolog atau layanan '
      'medis, tapi aku siap mendengarkan.';

  static const String mascotLabel = 'Maskot RelaxMate';

  /// Hanya tampil di flavor `dev`.
  static const String devBadge = 'Mode pengembangan';

  static const String configError =
      'Konfigurasi aplikasi belum lengkap. Hubungi pengembang.';

  static const String loading = 'Memuat...';

  // Perbarui aplikasi (SCR-M20).
  static const String updateTitle = 'Perbarui aplikasi';
  static const String updateBody =
      'Versi aplikasi ini sudah terlalu lama. Perbarui dulu supaya semuanya '
      'berjalan aman.';
  static const String updateAction = 'Perbarui sekarang';
  static const String storeOpenFailed =
      'Toko aplikasi belum bisa dibuka. Coba lagi nanti.';

  // Galat jaringan dan API (Architecture-M bagian 11). Tanpa detail teknis.
  static const String errorGeneric =
      'Ada yang tidak berjalan semestinya. Coba lagi, ya.';
  static const String errorOffline =
      'Koneksi terputus. Periksa internetmu, lalu coba lagi.';
  static const String errorTimeout =
      'Permintaan terlalu lama. Coba lagi sebentar lagi, ya.';
  static const String errorUnauthorized =
      'Sesimu sudah berakhir. Silakan masuk lagi.';
  static const String errorForbidden = 'Kamu belum bisa mengakses ini.';
  static const String errorNotFound = 'Yang kamu cari tidak ditemukan.';
  static const String errorConflict = 'Permintaan ini sudah pernah diproses.';
  static const String errorValidation = 'Periksa lagi isianmu, ya.';
  static const String errorRateLimited =
      'Terlalu banyak percobaan. Coba lagi sebentar lagi.';
  static const String errorServer =
      'Layanan sedang bermasalah. Coba lagi sebentar lagi.';

  static String rateLimitedIn(int seconds) =>
      'Terlalu banyak percobaan. Coba lagi dalam $seconds detik.';

  // Umum.
  static const String processing = 'Memproses...';
  static const String retry = 'Coba lagi';
  static const String logout = 'Keluar';
  static const String showPassword = 'Tampilkan kata sandi';
  static const String hidePassword = 'Sembunyikan kata sandi';
  static const String webOpenFailed =
      'Halaman belum bisa dibuka. Coba lagi nanti.';

  // Kolom isian dan validasi klien (sama dengan pesan server agar konsisten).
  static const String fieldName = 'Nama';
  static const String fieldEmail = 'Email';
  static const String fieldPassword = 'Kata sandi';
  static const String fieldNameRequired = 'Nama wajib diisi.';
  static const String fieldEmailRequired = 'Email wajib diisi.';
  static const String fieldEmailInvalid = 'Format email belum benar.';
  static const String fieldPasswordRequired = 'Kata sandi wajib diisi.';
  static const String termsRequired =
      'Centang dulu bahwa kamu sudah membaca ketentuan.';

  // Masuk (SCR-M04).
  static const String loginTitle = 'Masuk';
  static const String loginSubtitle = 'Lanjutkan ceritamu bersama RelaxMate.';
  static const String loginAction = 'Masuk';
  static const String loginToForgot = 'Lupa kata sandi?';
  static const String loginToRegister = 'Belum punya akun? Daftar';

  // Daftar (SCR-M03).
  static const String registerTitle = 'Buat akun';
  static const String registerSubtitle =
      'Akun ini sama dengan akun RelaxBoss di website.';
  static const String registerAction = 'Daftar';
  static const String registerToLogin = 'Sudah punya akun? Masuk';
  static const String termsAccept =
      'Aku sudah membaca dan menyetujui Ketentuan dan Kebijakan Privasi.';
  static const String termsLink = 'Baca Ketentuan';
  static const String privacyLink = 'Baca Kebijakan Privasi';

  // Lupa kata sandi (SCR-M05).
  static const String forgotTitle = 'Lupa kata sandi';
  static const String forgotSubtitle =
      'Masukkan emailmu. Kami kirim tautan untuk mengatur ulang kata sandi.';
  static const String forgotAction = 'Kirim tautan';
  static const String forgotSentFallback =
      'Jika email itu terdaftar, tautan untuk mengatur ulang kata sandi sudah '
      'dikirim. Cek kotak masukmu, ya.';
  static const String forgotBack = 'Kembali ke masuk';

  // Cek email (SCR-M06).
  static const String checkEmailTitle = 'Cek emailmu';
  static const String checkEmailDone = 'Saya sudah verifikasi';
  static const String checkEmailResend = 'Kirim ulang email';
  static const String checkEmailResent =
      'Email verifikasi sudah dikirim ulang. Cek kotak masukmu, ya.';
  static const String checkEmailNotYet =
      'Emailmu belum terverifikasi. Cek kotak masuk atau folder spam, ya.';

  static String checkEmailBody(String email) =>
      'Kami mengirim tautan verifikasi ke $email. Buka tautannya, lalu kembali '
      'ke sini.';

  // Sesi belum bisa diperiksa (offline, timeout, galat server).
  static const String sessionCheckTitle = 'Belum bisa memeriksa sesimu';
  static const String sessionCheckBody =
      'Kamu masih masuk di perangkat ini. Pastikan internetmu aktif, lalu coba '
      'lagi.';

  // Consent AI dan persetujuan pelatihan (SCR-M07). Judul dan isi consent berasal dari
  // server (API-M008), bukan dari sini.
  static const String consentAgree = 'Setuju dan lanjutkan';
  static const String consentSaveChoice = 'Simpan pilihan';
  static const String consentTrainingTitle = 'Satu pilihan untukmu';
  static const String consentTrainingYes = 'Boleh';
  static const String consentTrainingNo = 'Tidak boleh';
  static const String consentChoiceRequired = 'Pilih salah satu dulu.';
  static const String consentCheckTitle = 'Belum bisa memuat persetujuan';
  static const String consentCheckBody =
      'Sebelum bercerita, kami perlu memastikan persetujuanmu. Pastikan '
      'internetmu aktif, lalu coba lagi.';

  // Layar sambutan sementara (TASK-M024 menggantinya).
  static String signedInAs(String email) => 'Masuk sebagai $email';
}
