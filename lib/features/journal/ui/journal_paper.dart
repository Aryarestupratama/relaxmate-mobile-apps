import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/checkin/data/mood_arousal.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';

/// Satu halaman buku harian (CMP-M57, TASK-M079): kertas putih dengan punggung buku di kiri,
/// kepala berisi tanggal, jam WIB, tenaga, dan mood sebagai stiker, lalu [child] (kolom menulis
/// atau teks yang sedang ditulis). Dipakai bersama halaman menulis dan tampilan baca
/// (TASK-M080). Warna hanya dari token (RULE-M050); mood tidak hanya lewat gambar karena
/// labelnya ikut dibacakan (RULE-M052).
class JournalPaper extends StatelessWidget {
  const JournalPaper({
    required this.level,
    required this.when,
    required this.child,
    this.arousal,
    super.key,
  });

  /// Mood halaman ini; `null` selama belum dipilih (stiker kosong).
  final MoodLevel? level;

  /// Saat catatan dibuat (UTC); tampil dalam WIB.
  final DateTime when;
  final MoodArousal? arousal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final date = fullDateLabel(wibDate(when));
    final time = wibTimeLabel(when);
    final mood = level;
    final energy = arousal;

    final semanticLabel = <String>[
      '$date, $time',
      if (mood != null) mood.label,
      if (energy != null) energy.label,
    ].join('. ');

    final Widget sticker = SizedBox(
      width: RbSize.journalSticker,
      height: RbSize.journalSticker,
      child: mood == null
          ? null
          : Image.asset(
              mood.asset,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: RbRadius.cardBorder,
        boxShadow: RbShadow.card(colors),
      ),
      child: ClipRRect(
        borderRadius: RbRadius.cardBorder,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: RbSize.journalSpineWidth,
              child: ColoredBox(color: colors.brandSoft),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                space.md + RbSize.journalSpineWidth,
                space.md,
                space.md,
                space.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Semantics(
                    container: true,
                    label: semanticLabel,
                    excludeSemantics: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(date, style: text.h3),
                              Text(
                                energy == null
                                    ? time
                                    : '$time · ${energy.label}',
                                style: text.small
                                    .copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: space.sm),
                        sticker,
                      ],
                    ),
                  ),
                  SizedBox(height: space.md),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
