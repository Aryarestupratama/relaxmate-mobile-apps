import 'package:relaxmate/features/checkin/data/mood_level.dart';

/// Mood yang tercatat untuk hari ini (WIB): tingkat dan saat dicatat (UTC).
class MoodToday {
  const MoodToday({required this.level, required this.loggedAt});

  final MoodLevel level;
  final DateTime loggedAt;
}
