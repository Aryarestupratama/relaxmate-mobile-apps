import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Satu pilihan pada [PillSegments]. [label] dikosongkan (`null`) bila hanya ikon yang
/// tampil (teks sistem besar); [semanticLabel] tetap dibacakan.
class PillSegment<T> {
  const PillSegment({
    required this.value,
    required this.semanticLabel,
    this.label,
    this.icon,
  });

  final T value;
  final String semanticLabel;
  final String? label;
  final IconData? icon;
}

/// CMP-M56: kontrol pilihan berbentuk pil dua segmen atau lebih, dipakai di pilihan rentang
/// Mood Tracker dan pengalih tampilan Ngobrol. Segmen terpilih berwarna utama (`primary`)
/// dengan teks terang, yang lain transparan di atas pil putih tipis. Tinggi 48dp (RULE-M055).
/// [expand] membagi lebar sama rata dan memenuhi lebar yang tersedia; bila `false`, pil
/// selebar isinya. Perpindahan warna halus; langsung bila gerak dikurangi.
class PillSegments<T> extends StatelessWidget {
  const PillSegments({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expand = true,
    super.key,
  });

  final List<PillSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool expand;

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
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          for (final segment in segments)
            _wrap(
              _Segment(
                segment: segment,
                selected: segment.value == selected,
                onTap: () => onChanged(segment.value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _wrap(Widget child) => expand ? Expanded(child: child) : child;
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final PillSegment<T> segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final foreground = selected ? colors.onPrimary : colors.primary;

    return Semantics(
      button: true,
      selected: selected,
      label: segment.semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : RbMotion.screen,
          curve: RbMotion.curve,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: space.md),
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: RbRadius.pillBorder,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (segment.icon != null)
                Icon(
                  segment.icon,
                  size: RbSize.modeSwitchIcon,
                  color: foreground,
                ),
              if (segment.icon != null && segment.label != null)
                SizedBox(width: space.xs),
              if (segment.label != null)
                Text(
                  segment.label!,
                  style: text.button.copyWith(color: foreground),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
