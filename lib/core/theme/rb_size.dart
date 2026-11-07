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

  /// Tebal garis tepi kartu pilihan: biasa dan terpilih (Design-M CMP-M20).
  static const double borderThin = 1;
  static const double borderSelected = 2;

  /// Lebar maksimum gelembung chat sebagai bagian dari lebar layar (Design-M CMP-M02).
  static const double bubbleMaxWidthFactor = 0.8;

  /// Tinggi maksimum `CrisisBanner` sebagai bagian dari tinggi layar (Design-M CMP-M04);
  /// di atas itu isinya digulir supaya daftar pesan dan kolom ketik tetap terlihat pada
  /// teks 200% (RULE-M055).
  static const double crisisBannerMaxHeightFactor = 0.4;
}
