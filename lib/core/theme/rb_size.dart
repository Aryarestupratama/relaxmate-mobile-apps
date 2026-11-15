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

  /// Navigasi bawah, Beranda dan layar Mood (TASK-M072).
  static const double homeRowMaxTextScale = 1.3;
  static const double moodNoteBlob = 36;
  static const double homeButtonAvatar = 40;

  /// Grafik mood (`MoodChart`): tinggi area gambar, jari-jari titik, garis, dan lebar label.
  static const double moodChartCompactHeight = 120;
  static const double moodChartHeight = 180;
  static const double moodChartPointRadius = 7;
  static const double moodChartPointRadiusSmall = 4;
  static const double moodChartTodayExtra = 3;
  static const double moodChartLineStroke = 2;
  static const double moodChartGridStroke = 1;
  static const double moodChartDash = 5;
  static const double moodChartDashGap = 4;
  static const double moodChartAxisWidth = 64;
  static const double moodChartLabelWidth = 52;
  static const double moodChartLabelHeight = 20;
  static const double moodChartMaxLabelScale = 1.3;

  /// Layar sambutan (SCR-M02, TASK-M073): sisi ilustrasi (persegi) sebagai bagian dari
  /// tinggi layar, dibatasi antara [onboardingHeroMin] dan [onboardingHeroMax]; tanpa lingkaran
  /// atau hiasan di sekitarnya.
  static const double onboardingHeroFactor = 0.36;
  static const double onboardingHeroMin = 180;
  static const double onboardingHeroMax = 300;

  /// Ikon tombol "Bantuan" (CMP-M35) di pojok kanan atas layar tamu.
  static const double crisisHelpIcon = 18;

  /// Lebar isi maksimum layar tamu (Masuk, Daftar, Lupa sandi, sambutan) agar tetap nyaman
  /// di layar lebar atau lanskap.
  static const double authMaxContentWidth = 440;

  /// Beranda yang dipoles (TASK-M074): jarak geser masuk kartu, blob besar kartu mingguan, dan
  /// maskot di kiri gelembung pada kartu undangan (lebar mengikuti rasio gambar).
  static const double motionShift = 12;
  static const double weekBlob = 88;
  static const double inviteMascotHeight = 104;
  static const double weekActionIcon = 18;

  /// Dock navigasi bawah (CMP-M30): lebar maksimum dan tinggi pil tab. Lebar tab aktif dihitung
  /// dari panjang label dan skala teks, tab lain tidak pernah di bawah [minTouch].
  static const double navDockMaxWidth = 440;
  static const double navItemHeight = 56;
}
