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

  /// Pesan chat yang dikirim sebagai jawaban Cek Rasa (FR-M013).
  String get chatMessage => AppTexts.checkinMessage(label);
}
