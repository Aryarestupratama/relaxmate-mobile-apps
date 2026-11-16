import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/shared/widgets/pill_segments.dart';

/// Pilihan rentang 7 atau 30 hari (FR-M030): `PillSegments` selebar penuh dengan dua pilihan.
class MoodRangeToggle extends StatelessWidget {
  const MoodRangeToggle({
    required this.days,
    required this.onChanged,
    super.key,
  });

  final int days;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return PillSegments<int>(
      selected: days,
      onChanged: onChanged,
      segments: const <PillSegment<int>>[
        PillSegment<int>(
          value: AppConstants.moodRangeShortDays,
          label: AppTexts.moodRange7,
          semanticLabel: AppTexts.moodRange7,
        ),
        PillSegment<int>(
          value: AppConstants.moodRangeLongDays,
          label: AppTexts.moodRange30,
          semanticLabel: AppTexts.moodRange30,
        ),
      ],
    );
  }
}
