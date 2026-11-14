import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/mood/data/mood_day.dart';

/// Balasan API-M019: deret mood harian beserta ringkasannya. Semua angka dihitung server;
/// klien hanya menampilkan (RULE-M033).
class MoodSeries {
  const MoodSeries({
    required this.days,
    required this.average,
    required this.bestDate,
    required this.filledDays,
    required this.totalDays,
    required this.from,
    required this.to,
  });

  /// Terlama ke terbaru; hari tanpa catatan tidak ada di daftar.
  final List<MoodDay> days;

  /// Rata-rata mood harian, `null` bila kosong. Dibaca sebagai `num` (JSON bisa `4`).
  final double? average;
  final DateTime? bestDate;
  final int filledDays;

  /// 7 atau 30.
  final int totalDays;

  /// Jendela tanggal WIB (awal dan hari ini), dari server supaya tidak bergantung jam perangkat.
  final DateTime from;
  final DateTime to;

  bool get isEmpty => days.isEmpty;

  MoodLevel? get averageLevel {
    final value = average;
    return value == null ? null : MoodLevel.fromAverage(value);
  }

  /// Catatan hari ini (WIB), bila ada.
  MoodDay? get today {
    if (days.isEmpty) {
      return null;
    }
    final last = days.last;
    return last.date == to ? last : null;
  }

  /// Tanggal ke-[index] dalam jendela (0 = hari paling awal).
  DateTime dateAt(int index) => from.add(Duration(days: index));

  /// `null` bila bentuknya tidak sesuai kontrak (satu elemen rusak menolak seluruh balasan).
  static MoodSeries? tryParse(JsonMap json) {
    final rawDays = json['days'];
    final summary = json['summary'];
    final range = json['range'];
    if (rawDays is! List<Object?> || summary is! JsonMap || range is! JsonMap) {
      return null;
    }
    final days = <MoodDay>[];
    for (final item in rawDays) {
      final day = MoodDay.tryParse(item);
      if (day == null) {
        return null;
      }
      days.add(day);
    }
    final from = parseDateKey(range['from']);
    final to = parseDateKey(range['to']);
    final filled = summary['filled_days'];
    final total = summary['total_days'];
    if (from == null || to == null || filled is! int || total is! int) {
      return null;
    }
    final average = summary['average'];
    final best = summary['best_date'];
    return MoodSeries(
      days: days,
      average: average is num ? average.toDouble() : null,
      bestDate: parseDateKey(best),
      filledDays: filled,
      totalDays: total,
      from: from,
      to: to,
    );
  }
}
