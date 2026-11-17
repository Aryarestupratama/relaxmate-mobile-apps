import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/history/data/history_timeline.dart';

/// CMP-M59: penanda tanggal pada garis waktu Riwayat. Hari ini dan kemarin tampil sebagai
/// kata yang akrab dengan tanggal lengkap di bawahnya; tanggal lain tampil lengkap dengan
/// nama hari. Hari dihitung dari kunci hari server (batas 04.00 WIB, RULE-M033) dan
/// dibandingkan dengan tanggal WIB hari ini. Kunci yang bentuknya salah tampil apa adanya.
class HistoryDateLabel extends StatelessWidget {
  const HistoryDateLabel({required this.dayKey, super.key});

  final String dayKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final date = parseDateKey(dayKey);

    String title = formatDayKey(dayKey);
    String? caption;
    if (date != null) {
      final diff = wibToday().difference(date).inDays;
      final full = fullDateLabel(date);
      if (diff == 0) {
        title = AppTexts.today;
        caption = full;
      } else if (diff == 1) {
        title = AppTexts.yesterday;
        caption = full;
      } else {
        title = full;
      }
    }

    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsets.only(top: space.xs, bottom: space.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: text.h3),
            if (caption != null)
              Text(
                caption,
                style: text.caption.copyWith(color: colors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
