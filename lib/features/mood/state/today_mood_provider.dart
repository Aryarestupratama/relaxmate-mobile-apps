import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/mood/data/mood_today.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';

/// Mood hari ini (WIB) bila sudah ada: dari catatan yang baru dibuat sesi ini atau dari deret
/// 7 hari server, mana yang lebih baru. `null` selagi memuat, gagal, atau belum diisi. Dipakai
/// Beranda (kartu konfirmasi) dan sambutan chat (chip pembuka).
final Provider<MoodToday?> todayMoodProvider = Provider.autoDispose<MoodToday?>(
  (ref) {
    final recorded =
        ref.watch(checkinControllerProvider.select((state) => state.recorded));
    final series = ref.watch(
      moodSeriesControllerProvider(AppConstants.moodRangeShortDays),
    );

    MoodToday? fromServer;
    var today = wibToday();
    if (series is MoodSeriesReady) {
      today = series.series.to;
      final day = series.series.today;
      if (day != null) {
        fromServer = MoodToday(level: day.level, loggedAt: day.loggedAt);
      }
    }

    final local = recorded != null && wibDate(recorded.loggedAt) == today
        ? recorded
        : null;
    if (local == null) {
      return fromServer;
    }
    if (fromServer == null) {
      return local;
    }
    return local.loggedAt.isAfter(fromServer.loggedAt) ? local : fromServer;
  },
);
