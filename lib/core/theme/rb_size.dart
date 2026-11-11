/// Token ukuran tetap: target sentuh, avatar, ikon (Design-M bagian 2 dan 3).
abstract final class RbSize {
  /// Target sentuh minimal (RULE-M055).
  static const double minTouch = 48;
  static const double avatarSmall = 40;
  static const double avatarMedium = 56;
  static const double avatarLarge = 72;
  static const double icon = 24;

  /// Blob mood pada `MoodBlobRow` (Design-M CMP-M10).
  static const double moodBlob = 56;

  /// Di atas skala teks ini `MoodBlobRow` berganti dari satu baris lima kolom ke daftar menurun,
  /// karena label kolom sempit tidak muat dan terpotong tengah kata (RULE-M055, TASK-M042).
  static const double moodRowMaxTextScale = 1.3;

  /// Tebal garis tepi kartu pilihan: biasa dan terpilih (Design-M CMP-M20).
  static const double borderThin = 1;
  static const double borderSelected = 2;

  /// Lebar maksimum gelembung chat sebagai bagian dari lebar layar (Design-M CMP-M02).
  static const double bubbleMaxWidthFactor = 0.8;

  /// Tinggi maksimum `CrisisBanner` sebagai bagian dari tinggi layar (Design-M CMP-M04);
  /// di atas itu isinya digulir supaya daftar pesan dan kolom ketik tetap terlihat pada
  /// teks 200% (RULE-M055).
  static const double crisisBannerMaxHeightFactor = 0.4;

  /// Garis tengah cincin panduan napas (Design-M CMP-M11). Lingkaran di dalamnya membesar dan
  /// mengecil antara [breathingMinScale] dan 1 kali ukuran ini.
  static const double breathingGuide = 240;

  /// Skala terkecil lingkaran napas (saat napas habis), sebagai bagian dari [breathingGuide].
  static const double breathingMinScale = 0.5;

  /// Lingkaran angka pada langkah grounding (SCR-M12) dan ukuran angka di dalamnya. Angka
  /// diperkecil otomatis (`FittedBox`) bila teks sistem sangat besar.
  static const double groundingBadge = 112;
  static const double groundingNumber = 56;

  /// Tinggi maskot beranimasi (CMP-M20): di sambutan chat dan di layar Temani saja. Lebar
  /// mengikuti rasio gambar.
  static const double mascotWelcomeHeight = 140;
  static const double mascotCompanionHeight = 280;

  /// Maskot di tampilan maskot chat (FR-M027): ukuran biasa, dan ukuran kecil saat papan ketik
  /// terbuka atau teks sistem besar supaya balasan tetap punya ruang.
  static const double mascotChatHeight = 200;
  static const double mascotChatCompactHeight = 96;

  /// Titik pada `TypingIndicator` (CMP-M03) dan jarak antarnya.
  static const double typingDot = 8;

  /// Seberapa tinggi titik naik pada puncak geraknya.
  static const double typingDotLift = 5;
}
