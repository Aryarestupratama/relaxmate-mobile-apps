/// Konstanta produk di sisi klien (RULE-M026). Nilai yang berasal dari server
/// (batas pesan, kuota, versi minimum) sengaja tidak ada di sini.
abstract final class AppConstants {
  /// Awalan seluruh endpoint (Architecture-M bagian 5).
  static const String apiPrefix = '/api/v1';

  /// Timeout permintaan; lewat batas ini dianggap `ai_unavailable` (FR-M007).
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Pemeriksaan versi saat pembuka tidak boleh menahan aplikasi lama-lama.
  static const Duration versionCheckTimeout = Duration(seconds: 5);

  /// Kunci salinan kontak bantuan di `shared_preferences` (tidak sensitif).
  static const String crisisContactsCacheKey = 'crisis_contacts_v1';

  /// Sisipan antara nomor dan ekstensi pada `tel:` (`119 ext 8` menjadi `tel:119,8`).
  /// Koma = jeda pemanggil sebelum menekan ekstensi. `[Assumption]` OQ-MA9: diuji di
  /// perangkat nyata (TASK-M025); bila ekstensi terlewat, perpanjang jeda dengan `,,`.
  static const String telExtensionPause = ',';

  /// Banyak kontak yang tampil langsung di `CrisisBanner`; sisanya lewat "Lihat semua".
  static const int crisisBannerMaxContacts = 2;

  /// Nama kunci token di penyimpanan aman.
  static const String tokenStorageKey = 'auth_token';

  /// Halaman aplikasi di Play Store. `[Assumption]` Application ID A-MA5.
  static const String storeUrl =
      'https://play.google.com/store/apps/details?id=id.my.relaxboss.relaxmate';

  /// Halaman web RelaxBoss yang dibuka dari aplikasi (host sama dengan API,
  /// lihat `AppConfig.webUri`). Teks Ketentuan dan Privasi tetap milik web.
  static const String termsPath = '/ketentuan';
  static const String privacyPath = '/privasi';

  /// Halaman Konsultasi Profesional di website (tujuan chip saran, FR-M008).
  static const String consultationPath = '/konsultasi';
}
