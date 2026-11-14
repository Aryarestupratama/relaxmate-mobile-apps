import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';

/// Keadaan deret mood satu rentang (7 atau 30 hari). Hanya di memori.
sealed class MoodSeriesState {
  const MoodSeriesState();
}

class MoodSeriesLoading extends MoodSeriesState {
  const MoodSeriesLoading();
}

class MoodSeriesFailed extends MoodSeriesState {
  const MoodSeriesFailed(this.error);

  final ApiException error;
}

class MoodSeriesReady extends MoodSeriesState {
  const MoodSeriesReady(this.series);

  final MoodSeries series;
}
