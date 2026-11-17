import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/history/data/history_day.dart';
import 'package:relaxmate/features/history/data/history_timeline.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// Satu percakapan di garis waktu Riwayat: kartu putih melayang (`FloatingCard`) berisi
/// lingkaran ikon lavender, jam percakapan, jumlah giliran, dan panah. Menyentuhnya membuka
/// detail hari (hanya baca). Tinggi minimal 48dp (RULE-M055). Tidak menandai hari krisis di
/// daftar agar tidak menyorot hari yang berat.
class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({required this.day, required this.onTap, super.key});

  final HistoryDay day;
  final VoidCallback onTap;

  /// Seberapa kuat `softLavender` dicampurkan ke putih pada lingkaran ikon.
  static const double _chipStrength = 0.7;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final time = timeOfLabel(day.label);

    return Padding(
      padding: EdgeInsets.only(bottom: space.sm),
      child: Semantics(
        button: true,
        label: AppTexts.historyOpenDay(formatDayKey(day.day), time),
        onTap: onTap,
        excludeSemantics: true,
        child: FloatingCard(
          padding: EdgeInsets.zero,
          clip: Clip.antiAlias,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: RbSize.minTouch),
                child: Padding(
                  padding: EdgeInsets.all(space.md),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: RbSize.historyEntryChip,
                        height: RbSize.historyEntryChip,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.alphaBlend(
                            colors.softLavender.withValues(
                              alpha: _chipStrength,
                            ),
                            colors.card,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.messageCircle,
                          size: RbSize.icon,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(width: space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              time,
                              style: text.body.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              AppTexts.historyTurns(day.totalTurns),
                              style: text.caption.copyWith(
                                color: colors.textSecondary,
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
      ),
    );
  }
}
