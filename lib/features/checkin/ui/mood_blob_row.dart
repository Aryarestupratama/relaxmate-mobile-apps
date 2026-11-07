import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';

/// CMP-M10: lima blob mood dengan label teks di bawahnya (warna bukan satu-satunya pembawa
/// makna). Satu pilihan; yang terpilih diberi cincin `primary`. Tanpa nilai awal: pengguna
/// memilih sendiri.
class MoodBlobRow extends StatelessWidget {
  const MoodBlobRow({
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  final MoodLevel? selected;
  final ValueChanged<MoodLevel> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final level in MoodLevel.values)
          Expanded(
            child: _MoodBlob(
              level: level,
              isSelected: level == selected,
              enabled: enabled,
              onTap: () => onSelected(level),
            ),
          ),
      ],
    );
  }
}

class _MoodBlob extends StatelessWidget {
  const _MoodBlob({
    required this.level,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final MoodLevel level;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: enabled,
      label: level.label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: RbRadius.cardBorder,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: space.xxs),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: RbSize.moodBlob,
                height: RbSize.moodBlob,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: RbRadius.cardBorder,
                    border: isSelected
                        ? Border.all(
                            color: colors.primary,
                            width: RbSize.borderSelected,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(space.xxs),
                    child: Image.asset(
                      level.asset,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: space.xxs),
              Text(
                level.label,
                textAlign: TextAlign.center,
                style: text.caption.copyWith(
                  color: colors.primary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
