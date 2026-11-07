import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/history/data/history_day.dart';
import 'package:relaxmate/features/history/data/history_timeline.dart';

/// Satu baris riwayat: jam percakapan dan jumlah giliran. Menyentuhnya membuka detail hari
/// (hanya baca). Tinggi minimal 48dp (Design-M aksesibilitas). Tidak menandai hari krisis di
/// daftar agar tidak menyorot hari yang berat.
class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({required this.day, required this.onTap, super.key});

  final HistoryDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final time = timeOfLabel(day.label);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.xxs),
      child: Semantics(
        button: true,
        label: AppTexts.historyOpenDay(formatDayKey(day.day), time),
        onTap: onTap,
        excludeSemantics: true,
        child: Material(
          color: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: RbRadius.cardBorder,
            side: BorderSide(color: colors.border, width: RbSize.borderThin),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: RbRadius.cardBorder,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: RbSize.minTouch),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: space.md,
                  vertical: space.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(time, style: text.body),
                          Text(
                            AppTexts.historyTurns(day.totalTurns),
                            style: text.caption.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: RbSize.icon,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
