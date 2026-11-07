import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/checkin/ui/mood_blob_row.dart';

/// SCR-M09: Cek Rasa di kartu sambutan, awal sesi harian (FR-M013). Pilih satu blob, lalu
/// "Kirim ke RelaxMate" (pesan chat + Mood Entry) atau "Lewati". Dapat diabaikan: kolom ketik
/// chat tetap tersedia di bawahnya.
class CheckinCard extends ConsumerStatefulWidget {
  const CheckinCard({super.key});

  @override
  ConsumerState<CheckinCard> createState() => _CheckinCardState();
}

class _CheckinCardState extends ConsumerState<CheckinCard> {
  MoodLevel? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final submitting = ref.watch(
      checkinControllerProvider.select((state) => state.submitting),
    );
    final controller = ref.read(checkinControllerProvider.notifier);
    final choice = _selected;

    return Container(
      padding: EdgeInsets.all(space.sm),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: RbRadius.cardBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              AppTexts.checkinTitle,
              textAlign: TextAlign.center,
              style: text.h3.copyWith(color: colors.primary),
            ),
          ),
          SizedBox(height: space.sm),
          MoodBlobRow(
            selected: choice,
            enabled: !submitting,
            onSelected: (level) => setState(() => _selected = level),
          ),
          SizedBox(height: space.sm),
          FilledButton(
            onPressed: choice == null || submitting
                ? null
                : () => controller.submit(choice),
            child: const Text(AppTexts.checkinSend),
          ),
          TextButton(
            onPressed: submitting ? null : controller.skip,
            child: const Text(AppTexts.checkinSkip),
          ),
        ],
      ),
    );
  }
}
