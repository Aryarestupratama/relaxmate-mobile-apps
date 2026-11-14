import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// API-M019: deret mood 7 atau 30 hari, hanya baca (FR-M030). Catatan teks (`note`) tidak
/// pernah dikirim server. Semua panggilan lewat `ApiClient` (RULE-M022).
class MoodSeriesRepository {
  const MoodSeriesRepository(this._api);

  final ApiClient _api;

  Future<MoodSeries> fetch(int days) async {
    final json = await _api.get(
      '/mood-entries',
      query: <String, Object?>{'days': days},
    );
    final series = MoodSeries.tryParse(json);
    if (series == null) {
      throw const ApiException(
        kind: ApiErrorKind.unknown,
        message: AppTexts.errorGeneric,
      );
    }
    return series;
  }
}

final Provider<MoodSeriesRepository> moodSeriesRepositoryProvider =
    Provider<MoodSeriesRepository>(
  (ref) => MoodSeriesRepository(ref.watch(apiClientProvider)),
);
