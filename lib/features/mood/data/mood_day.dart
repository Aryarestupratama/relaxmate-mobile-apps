import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';

/// Satu hari pada grafik (API-M019): catatan **terakhir** hari itu menurut tanggal WIB.
class MoodDay {
  const MoodDay({
    required this.date,
    required this.level,
    required this.loggedAt,
  });

  /// Tanggal WIB tanpa jam (`DateTime.utc(y, m, d)`).
  final DateTime date;
  final MoodLevel level;

  /// Saat dicatat (UTC); ditampilkan sebagai jam WIB.
  final DateTime loggedAt;

  /// `null` bila bentuknya tidak sesuai kontrak.
  static MoodDay? tryParse(Object? raw) {
    if (raw is! JsonMap) {
      return null;
    }
    final date = parseDateKey(raw['date']);
    final level = MoodLevel.fromValue(raw['mood']);
    final loggedRaw = raw['logged_at'];
    final loggedAt = loggedRaw is String ? DateTime.tryParse(loggedRaw) : null;
    if (date == null || level == null || loggedAt == null) {
      return null;
    }
    return MoodDay(date: date, level: level, loggedAt: loggedAt.toUtc());
  }
}
