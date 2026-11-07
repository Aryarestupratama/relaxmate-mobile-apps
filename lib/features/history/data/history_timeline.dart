import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/history/data/history_day.dart';

/// Item daftar garis waktu: penanda tanggal atau satu Percakapan.
sealed class HistoryTimelineItem {
  const HistoryTimelineItem();
}

class HistoryDateHeader extends HistoryTimelineItem {
  const HistoryDateHeader(this.dayKey);

  /// Kunci hari `YYYY-MM-DD` dari server.
  final String dayKey;
}

class HistoryEntry extends HistoryTimelineItem {
  const HistoryEntry(this.day);

  final HistoryDay day;
}

/// Menyusun garis waktu per tanggal dari daftar yang sudah urut terbaru dulu: satu penanda
/// tanggal per kunci hari berurutan, diikuti Percakapan hari itu. Urutan dari server tidak
/// diubah. Beberapa Percakapan dari web di hari yang sama muncul di bawah satu tanggal.
List<HistoryTimelineItem> buildHistoryTimeline(List<HistoryDay> days) {
  final items = <HistoryTimelineItem>[];
  String? currentKey;
  for (final day in days) {
    if (day.day != currentKey) {
      currentKey = day.day;
      items.add(HistoryDateHeader(day.day));
    }
    items.add(HistoryEntry(day));
  }
  return items;
}

final RegExp _dayKeyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// `2026-11-06` menjadi "6 November 2026". Bentuk lain dikembalikan apa adanya.
String formatDayKey(String dayKey) {
  final match = _dayKeyPattern.firstMatch(dayKey);
  if (match == null) {
    return dayKey;
  }
  final year = match.group(1);
  final month = int.tryParse(match.group(2) ?? '');
  final day = int.tryParse(match.group(3) ?? '');
  if (year == null ||
      month == null ||
      day == null ||
      month < 1 ||
      month > AppTexts.months.length) {
    return dayKey;
  }
  return '$day ${AppTexts.months[month - 1]} $year';
}

/// Bagian jam dari `label` server ("6 November 2026, 14.30 WIB" menjadi "14.30 WIB").
/// Tanpa pemisah, label dikembalikan utuh.
String timeOfLabel(String label) {
  final cut = label.lastIndexOf(', ');
  if (cut < 0 || cut + 2 >= label.length) {
    return label;
  }
  return label.substring(cut + 2);
}
