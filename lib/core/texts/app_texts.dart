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
}
