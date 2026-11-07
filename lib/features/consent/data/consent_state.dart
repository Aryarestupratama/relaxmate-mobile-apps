import 'package:relaxmate/core/api/json_map.dart';

/// Status consent pengguna dari server (`state` pada `GET /consent`, `GET /me`, dan balasan
/// POST consent). Hanya kolom yang dipakai klien yang dibaca.
class ConsentState {
  const ConsentState({
    required this.aiGranted,
    required this.trainingAnswered,
    required this.complete,
  });

  /// Consent AI sudah disetujui pada versi terbaru.
  final bool aiGranted;

  /// Pilihan persetujuan pelatihan sudah dijawab pada versi terbaru.
  final bool trainingAnswered;

  /// Keduanya lengkap: fitur AI boleh dipakai.
  final bool complete;

  /// `null` bila bentuknya tidak sesuai kontrak. Tidak ada nilai bawaan yang menganggap
  /// consent sudah lengkap.
  static ConsentState? tryParse(Object? value) {
    if (value is! JsonMap) {
      return null;
    }
    final ai = value['ai'];
    final training = value['training'];
    if (ai is! JsonMap || training is! JsonMap) {
      return null;
    }
    return ConsentState(
      aiGranted: ai['granted'] == true,
      trainingAnswered: training['answered'] == true,
      complete: value['complete'] == true,
    );
  }
}
