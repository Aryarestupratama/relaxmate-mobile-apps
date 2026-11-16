import 'package:relaxmate/features/mood/data/mood_series.dart';

/// Gambaran pola mood untuk kartu refleksi di halaman Mood Tracker. Murni dihitung di
/// perangkat dari deret yang sudah ada, tanpa AI, dan hanya membandingkan tiga catatan
/// terakhir dengan catatan sebelumnya. Tidak pernah menyimpulkan kondisi atau diagnosis
/// (RULE-M046): hasilnya hanya salah satu dari empat kalimat netral.
enum MoodInsight {
  /// Catatan belum cukup untuk melihat pola.
  notEnough,

  /// Tiga catatan terakhir terasa lebih ringan dari sebelumnya.
  lighter,

  /// Tiga catatan terakhir terasa lebih berat dari sebelumnya.
  heavier,

  /// Tidak ada perubahan berarti.
  steady;

  /// Jumlah catatan terakhir yang dibandingkan, dan catatan minimum agar pola dihitung.
  static const int _recentCount = 3;
  static const int _minimumDays = 4;

  /// Selisih rata-rata (skala 1 sampai 5) yang dianggap perubahan berarti.
  static const double _shift = 0.75;

  /// Rata-rata terakhir tidak boleh sudah tinggi untuk disebut "lebih berat", dan tidak
  /// boleh sudah rendah untuk disebut "lebih ringan".
  static const double _heavierCeiling = 3.5;
  static const double _lighterFloor = 3;

  static MoodInsight of(MoodSeries series) {
    final values = <int>[for (final day in series.days) day.level.value];
    if (values.length < _minimumDays) {
      return MoodInsight.notEnough;
    }
    final split = values.length - _recentCount;
    final recent = _average(values.sublist(split));
    final earlier = _average(values.sublist(0, split));
    final diff = recent - earlier;
    if (diff >= _shift && recent >= _lighterFloor) {
      return MoodInsight.lighter;
    }
    if (diff <= -_shift && recent <= _heavierCeiling) {
      return MoodInsight.heavier;
    }
    return MoodInsight.steady;
  }

  static double _average(List<int> values) =>
      values.reduce((a, b) => a + b) / values.length;
}
