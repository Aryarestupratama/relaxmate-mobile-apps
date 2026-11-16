import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Pilihan rentang 7 atau 30 hari (FR-M030): pil dua segmen. Segmen terpilih berwarna utama
/// (`primary`) dengan teks terang, yang lain transparan di atas pil putih tipis. Tinggi 48dp
/// (RULE-M055). Perpindahan warna halus; langsung bila gerak dikurangi.
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
    final space = context.rbSpace;

    return Container(
      height: RbSize.moodRangePillHeight,
      padding: EdgeInsets.all(space.xxs),
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: 0.8),
        borderRadius: RbRadius.pillBorder,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: <Widget>[
          _Segment(
            label: AppTexts.moodRange7,
            selected: days == AppConstants.moodRangeShortDays,
            onTap: () => onChanged(AppConstants.moodRangeShortDays),
          ),
          _Segment(
            label: AppTexts.moodRange30,
            selected: days == AppConstants.moodRangeLongDays,
            onTap: () => onChanged(AppConstants.moodRangeLongDays),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : RbMotion.screen,
            curve: RbMotion.curve,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.primary : Colors.transparent,
              borderRadius: RbRadius.pillBorder,
            ),
            child: Text(
              label,
              style: text.button.copyWith(
                color: selected ? colors.onPrimary : colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
