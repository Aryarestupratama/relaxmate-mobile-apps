/// Token ukuran tetap: target sentuh, avatar, ikon (Design-M bagian 2 dan 3).
abstract final class RbSize {
  /// Target sentuh minimal (RULE-M055).
  static const double minTouch = 48;
  static const double avatarTiny = 32;
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

  /// Lebar maksimum baris balasan RelaxMate (avatar + nama + gelembung) pada tampilan obrolan,
  /// sebagai bagian dari lebar layar.
  static const double bubbleProfileMaxWidthFactor = 0.88;

  /// Radius sudut kolom ketik chat (bentuk kapsul).
  static const double chatInputRadius = 26;

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

  /// Titik kemajuan grounding (lima titik; yang aktif memanjang) dan pratinjau lingkaran
  /// napas di layar pilih durasi.
  static const double groundingDot = 8;
  static const double groundingDotActive = 24;
  static const double breathingPreview = 168;

  /// Tinggi bilah kemajuan sesi napas (lebarnya sama dengan [breathingGuide]).
  static const double breathingProgressHeight = 8;

  /// Lingkaran ikon pada ubin daftar Latihan.
  static const double exerciseIconChip = 44;

  /// Tinggi maskot beranimasi (CMP-M20): di sambutan chat dan di layar Temani saja. Lebar
  /// mengikuti rasio gambar.
  static const double mascotWelcomeHeight = 140;
  static const double mascotCompanionHeight = 280;

  /// Tampilan maskot chat (FR-M027, SCR-M08). Maskot di tengah bawah, gelembung balasan di
  /// atasnya. Tinggi maskot dihitung dari ruang panggung: lebar maskot paling banyak
  /// [mascotStageWidthFactor] kali lebar layar dan tingginya paling banyak
  /// [mascotStageHeightFactor] kali tinggi panggung (sisanya untuk gelembung), jadi ia
  /// mengecil sendiri saat papan ketik terbuka. Ganti [mascotFrameAspect] (lebar : tinggi
  /// bingkai berkas `outlined/`, 376 : 499) dan [mascotStageWidthFactor] bila aset badan
  /// penuh dipasang (M075).
  static const double mascotStageWidthFactor = 0.56;
  static const double mascotStageHeightFactor = 0.52;
  static const double mascotFrameAspect = 376 / 499;

  /// Gelembung balasan sedikit menjorok ke bingkai maskot (bagian atas bingkai kosong) supaya
  /// ekornya menyentuh kepala; sebagai bagian dari tinggi maskot.
  static const double mascotReplyOverlapFactor = 0.06;

  /// Bagian bawah maskot yang memudar (setengah badan terpotong di tepi bawah).
  static const double mascotFadeFraction = 0.14;

  /// Ekor gelembung balasan (menunjuk ke bawah, ke kepala maskot): lebar dan tinggi.
  static const double replyTailWidth = 20;
  static const double replyTailHeight = 10;

  /// Gelembung pesan pengguna di bawah maskot: tinggi maksimum sebelum isinya digulir, dan
  /// lebar maksimum sebagai bagian dari lebar layar.
  static const double mascotUserRadius = 24;
  static const double mascotReplyRadius = 22;
  static const double userBubbleMaxHeight = 104;
  static const double userBubbleMaxWidthFactor = 0.84;

  /// Pengalih tampilan di bilah atas chat (CMP-M46) dan tombol SOS (CMP-M47).
  static const double modeSwitchHeight = 40;
  static const double modeSwitchIcon = 18;
  static const double sosHeight = 40;
  static const double sosCompactHeight = 34;
  static const double sosRingScale = 1.3;

  /// Cahaya lembut di belakang maskot: diameter sebagai kelipatan lebar maskot.
  static const double mascotAuraFactor = 1.7;

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

  /// Halaman Mood Tracker (redesign 2026-11-15): tinggi gelembung blob, tinggi dan sumbu
  /// kurva 7 hari, tinggi label "Terbaik", jarak antarsel kalender 30 hari, dan tinggi pil
  /// pilihan rentang.
  static const double moodCloudHeight = 220;
  static const double moodTrendHeight = 200;
  static const double moodTrendAxisWidth = 32;
  static const double moodAxisBlob = 24;
  static const double moodCalloutWidth = 68;
  static const double moodCalloutHeight = 28;
  static const double moodCalendarGap = 6;
  static const double moodRangePillHeight = 48;
  static const double moodLegendBlob = 20;

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

  /// Beranda yang dipoles (TASK-M074): jarak geser masuk kartu, blob besar kartu mood tercatat (halo), dan
  /// maskot di kiri gelembung pada kartu undangan (lebar mengikuti rasio gambar).
  static const double motionShift = 12;
  static const double moodHeroBlob = 104;
  static const double moodHeroHalo = 132;
  static const double inviteMascotHeight = 104;

  /// Dock navigasi bawah (CMP-M30): lebar maksimum dan tinggi pil tab. Lebar tab aktif dihitung
  /// dari panjang label dan skala teks, tab lain tidak pernah di bawah [minTouch].
  static const double navDockMaxWidth = 440;
  static const double navItemHeight = 56;

  /// Riwayat sebagai garis waktu (TASK-M073 bagian 9): lebar kolom rel di kiri, tebal garis rel,
  /// titik tanggal dan titik percakapan, jarak titik dari tepi atas barisnya, dan lingkaran
  /// ikon pada kartu percakapan.
  static const double historyRailWidth = 28;
  static const double historyRailLine = 2;
  static const double historyDateDot = 14;
  static const double historyEntryDot = 10;
  static const double historyDateDotTop = 14;
  static const double historyEntryDotTop = 31;
  static const double historyEntryChip = 40;
  static const double historyEmptyAura = 220;
  static const double historyEmptyMascot = 140;
  static const double historySkeletonHeight = 72;

  /// Temani saja (SCR-M13): maskot setengah badan menempel di tepi bawah layar dengan cincin
  /// napas di belakang kepalanya. Tinggi maskot = [companionMascotHeightFactor] kali tinggi
  /// layar (dibatasi [companionMascotMin] sampai [companionMascotMax]); garis tengah cincin
  /// terluar = [companionHaloFactor] kali tinggi maskot (tidak melebihi lebar layar); pusat
  /// cincin berada [companionHeadFromBottom] kali tinggi maskot dari tepi bawah (kira-kira
  /// tengah kepala); cincin mengecil sampai [companionHaloMinScale] saat napas habis, tebal
  /// garis cincin [companionRingStroke]. Lebar tombol "Selesai" [companionButtonWidth].
  static const double companionMascotHeightFactor = 0.3;
  static const double companionMascotMin = 180;
  static const double companionMascotMax = 300;
  static const double companionHaloFactor = 1.2;
  static const double companionHeadFromBottom = 0.72;
  static const double companionHaloMinScale = 0.82;
  static const double companionRingStroke = 1.5;
  static const double companionButtonWidth = 200;

  /// Pengaturan (SCR-M17): lingkaran inisial profil, kotak ikon baris beserta ikon dan
  /// radiusnya, dan tinggi minimal satu baris.
  static const double settingsAvatar = 56;
  static const double settingsRowChip = 36;
  static const double settingsRowIcon = 20;
  static const double settingsRowChipRadius = 10;
  static const double settingsRowMinHeight = 56;

  /// Buku harian (TASK-M079): stiker mood di halaman, ikon pena, garis buku, punggung buku,
  /// dan letak garis di dalam kotak barisnya (bagian tinggi baris dari bawah).
  static const double journalSticker = 64;
  static const double journalPenIcon = 22;
  static const double journalRuleStroke = 1;
  static const double journalSpineWidth = 6;
  static const double journalRuleDrop = 0.22;
}
