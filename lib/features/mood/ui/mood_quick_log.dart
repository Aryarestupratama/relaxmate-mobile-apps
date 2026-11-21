import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/ui/mood_blob_row.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// Isi mood hari ini langsung dari halaman Mood Tracker, memakai `MoodBlobRow`; memilih satu
/// membuka halaman menulis buku harian (SCR-M24), sama dengan kartu mood di Beranda. Hanya
/// dipasang oleh `MoodScreen` selama mood hari ini belum tercatat; setelah tersimpan kartu ini
/// hilang dan semua bagian halaman menyegarkan diri.
class MoodQuickLog extends StatelessWidget {
  const MoodQuickLog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(AppTexts.moodLogTitle, style: text.h3),
          ),
          SizedBox(height: space.xxs),
          Text(
            AppTexts.moodLogHint,
            style: text.small.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: space.sm),
          MoodBlobRow(
            selected: null,
            onSelected: (level) =>
                context.push(AppRoutes.journalWrite, extra: level),
          ),
        ],
      ),
    );
  }
}
