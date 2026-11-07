import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';

/// API-M018: catat Mood Entry dari Cek Rasa (FR-M013, OQ-M3). Hanya `mood` yang dikirim;
/// tenaga dan catatan tidak ditanyakan di mobile. Batas harian dan validasi ada di server
/// (RULE-M023); galat dilempar sebagai `ApiException` oleh `ApiClient`.
class MoodRepository {
  const MoodRepository(this._api);

  final ApiClient _api;

  Future<void> record(MoodLevel level) async {
    await _api.post(
      '/mood-entries',
      body: <String, Object?>{'mood': level.value},
    );
  }
}

final Provider<MoodRepository> moodRepositoryProvider =
    Provider<MoodRepository>(
  (ref) => MoodRepository(ref.watch(apiClientProvider)),
);
