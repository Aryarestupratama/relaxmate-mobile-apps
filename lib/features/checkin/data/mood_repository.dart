import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/mood/data/mood_today.dart';

/// API-M018: catat Mood Entry dari kartu mood di Beranda (FR-M013, OQ-M3). Hanya `mood` yang
/// dikirim; tenaga dan catatan tidak ditanyakan di mobile. Batas harian dan validasi ada di
/// server (RULE-M023); galat dilempar sebagai `ApiException` oleh `ApiClient`.
class MoodRepository {
  const MoodRepository(this._api);

  final ApiClient _api;

  /// Mengembalikan catatan yang baru dibuat (tingkat dan waktunya dari server).
  Future<MoodToday> record(MoodLevel level) async {
    final json = await _api.post(
      '/mood-entries',
      body: <String, Object?>{'mood': level.value},
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
