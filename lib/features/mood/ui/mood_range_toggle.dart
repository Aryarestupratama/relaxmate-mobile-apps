import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Pilihan rentang 7 atau 30 hari (kontrol segmen, FR-M030).
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
    final colors = context.rbColors;
    final text = context.rbText;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const <ButtonSegment<int>>[
          ButtonSegment<int>(
            value: AppConstants.moodRangeShortDays,
            label: Text(AppTexts.moodRange7),
          ),
          ButtonSegment<int>(
            value: AppConstants.moodRangeLongDays,
            label: Text(AppTexts.moodRange30),
          ),
        ],
        selected: <int>{days},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll<TextStyle>(text.button),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => states.contains(WidgetState.selected)
                ? colors.primary
                : colors.card,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => states.contains(WidgetState.selected)
                ? colors.onPrimary
                : colors.primary,
          ),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: colors.border),
          ),
        ),
      ),
    );
  }
}
