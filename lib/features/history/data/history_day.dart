import 'package:relaxmate/core/api/json_map.dart';

/// Satu baris riwayat: satu Percakapan yang sudah berisi pesan (`days[]` API-M015).
class HistoryDay {
  const HistoryDay({
    required this.id,
    required this.day,
    required this.label,
    required this.totalTurns,
    required this.hasCrisis,
  });

  /// Id Percakapan (UUID); dipakai membuka detail (API-M016).
  final String id;

  /// Kunci hari percakapan `YYYY-MM-DD`, dihitung server (batas 04.00 WIB, RULE-M033).
  final String day;

  /// Teks siap tampil dari server, mis. "6 November 2026, 14.30 WIB".
  final String label;

  /// Jumlah giliran (pesan pengguna yang sudah dibalas).
  final int totalTurns;

  final bool hasCrisis;

  /// `null` bila bentuknya tidak sesuai kontrak.
  static HistoryDay? tryParse(Object? value) {
    if (value is! JsonMap) {
      return null;
    }
    final id = value['id'];
    final day = value['day'];
    final label = value['label'];
    final totalTurns = value['total_turns'];
    if (id is! String ||
        id.isEmpty ||
        day is! String ||
        label is! String ||
        totalTurns is! int) {
      return null;
    }
    return HistoryDay(
      id: id,
      day: day,
      label: label,
      totalTurns: totalTurns,
      hasCrisis: value['has_crisis'] == true,
    );
  }
}
