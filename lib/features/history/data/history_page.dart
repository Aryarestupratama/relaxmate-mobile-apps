import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/history/data/history_day.dart';

/// Satu halaman riwayat (`GET /relaxmate/days`, API-M015): terbaru dulu, halaman berkursor.
class HistoryPage {
  const HistoryPage({required this.days, required this.nextCursor});

  final List<HistoryDay> days;

  /// Diteruskan apa adanya sebagai `?cursor=`; `null` bila tidak ada halaman berikutnya.
  final String? nextCursor;

  /// `null` bila bentuknya tidak sesuai kontrak (satu baris rusak menolak seluruh halaman).
  static HistoryPage? tryParse(JsonMap json) {
    final raw = json['days'];
    if (raw is! List<Object?>) {
      return null;
    }
    final days = <HistoryDay>[];
    for (final item in raw) {
      final day = HistoryDay.tryParse(item);
      if (day == null) {
        return null;
      }
      days.add(day);
    }
    final cursor = json['next_cursor'];
    return HistoryPage(
      days: days,
      nextCursor: cursor is String && cursor.isNotEmpty ? cursor : null,
    );
  }
}
