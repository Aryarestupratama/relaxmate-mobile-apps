import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/checkin/data/mood_arousal.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/mood/data/mood_today.dart';

/// API-M018: catat Mood Entry dari halaman menulis buku harian (FR-M013, FR-M032). `mood`
/// wajib; tenaga dan catatan opsional dan hanya dikirim bila diisi. Batas harian, panjang
/// catatan, dan validasi ada di server (RULE-M023); galat dilempar sebagai `ApiException` oleh
/// `ApiClient`. Isi catatan tidak disimpan di sini dan tidak pernah dicatat (RULE-M074).
class MoodRepository {
  const MoodRepository(this._api);

  final ApiClient _api;

  /// Mengembalikan catatan yang baru dibuat (tingkat dan waktunya dari server).
  Future<MoodToday> record(
    MoodLevel level, {
    String? note,
    MoodArousal? arousal,
  }) async {
    final json = await _api.post(
      '/mood-entries',
      body: <String, Object?>{
        'mood': level.value,
        if (arousal != null) 'arousal_input': arousal.apiValue,
        if (note != null) 'note': note,
      },
    );
    final entry = json['entry'];
    final createdRaw = entry is JsonMap ? entry['created_at'] : null;
    final createdAt =
        createdRaw is String ? DateTime.tryParse(createdRaw) : null;
    return MoodToday(
      level: level,
      loggedAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }
}

final Provider<MoodRepository> moodRepositoryProvider =
    Provider<MoodRepository>(
  (ref) => MoodRepository(ref.watch(apiClientProvider)),
);
