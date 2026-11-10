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

  /// Kunci pengaturan di `shared_preferences` (tidak sensitif): getar halus latihan napas dan
  /// lapisan privasi di daftar aplikasi terbaru (TASK-M031).
  static const String settingsBreathingHapticsKey =
      'settings_breathing_haptics_v1';
  static const String settingsPrivacyCoverKey = 'settings_privacy_cover_v1';

  /// Epoch milidetik sampai kapan maskot istirahat (0 atau tidak ada = tidak istirahat). Ditulis
  /// juga oleh layanan Kotlin (`OverlayPrefs.KEY_SNOOZE_UNTIL`), jadi harus sama.
  static const String overlaySnoozeUntilKey = 'overlay_snooze_until_v1';

  /// Pilihan pengguna untuk maskot mengambang (TASK-M032). Bawaan mati; pilihan ini bukan izin.
  static const String settingsOverlayEnabledKey = 'settings_overlay_enabled_v1';

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

  /// Ritme latihan napas dalam detik: tarik, tahan, embuskan (FR-M014). `[Assumption]` 4-4-6:
  /// embusan lebih panjang dari tarikan agar terasa menenangkan; ubah angka di sini bila
  /// founder ingin ritme lain (satu putaran = jumlah ketiganya).
  static const int breathingInhaleSeconds = 4;
  static const int breathingHoldSeconds = 4;
  static const int breathingExhaleSeconds = 6;

  /// Pilihan durasi latihan napas dalam menit (Design-M SCR-M11) dan pilihan awalnya.
  static const List<int> breathingMinuteChoices = <int>[1, 3, 5];
  static const int breathingDefaultMinutes = 3;
}
