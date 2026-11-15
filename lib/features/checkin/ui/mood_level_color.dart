import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';

/// Warna token untuk tiap tingkat mood (`mood1` sampai `mood5`), satu pemetaan untuk
/// komponen yang ingin berwarna sesuai mood (mis. indikator navigasi bawah).
extension MoodLevelColor on MoodLevel {
  Color colorOf(RbColors colors) => switch (this) {
        MoodLevel.verySad => colors.mood1,
        MoodLevel.sad => colors.mood2,
        MoodLevel.neutral => colors.mood3,
        MoodLevel.happy => colors.mood4,
        MoodLevel.great => colors.mood5,
      };
}
