import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/texts/app_texts.dart';

/// Skala mood 1 sampai 5 (ENT-006, enum `MoodLevel` di server). Label mengikuti web agar
/// satu catatan terbaca sama di dua tempat (Design-M A-D3).
enum MoodLevel {
  verySad(1, AppTexts.moodVerySad),
  sad(2, AppTexts.moodSad),
  neutral(3, AppTexts.moodNeutral),
  happy(4, AppTexts.moodHappy),
  great(5, AppTexts.moodGreat);

  const MoodLevel(this.value, this.label);

  /// Nilai yang dikirim ke API-M018 (`mood`).
  final int value;
  final String label;

  /// Gambar blob untuk tingkat ini.
  String get asset => AppAssets.moodBlob(value);

  /// Kalimat pembuka chat yang ditawarkan sebagai chip bila mood hari ini sudah tercatat
  /// (OQ-MP5). Tidak pernah dikirim otomatis.
  String get chatMessage => AppTexts.moodChatMessage(label);

  /// Tingkat dari nilai API (1 sampai 5); `null` di luar rentang.
  static MoodLevel? fromValue(Object? value) {
    if (value is! num) {
      return null;
    }
    final rounded = value.toInt();
    if (rounded != value) {
      return null;
    }
    for (final level in MoodLevel.values) {
      if (level.value == rounded) {
        return level;
      }
    }
    return null;
  }

  /// Tingkat terdekat dari rata-rata (mis. 3,4 menjadi Biasa).
  static MoodLevel fromAverage(double average) {
    final clamped = average.round().clamp(1, 5);
    return MoodLevel.values[clamped - 1];
  }
}
