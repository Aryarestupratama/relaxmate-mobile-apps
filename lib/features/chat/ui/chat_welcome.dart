import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/checkin/ui/checkin_card.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';
import 'package:relaxmate/features/mascot/ui/mascot_view.dart';

/// Sambutan saat belum ada pesan hari ini (SCR-M08). Bila [canCheckin], kartu Cek Rasa
/// (SCR-M09) ditawarkan di bawah sambutan sampai pengguna mengirim atau melewatinya.
/// Dapat digulir agar tetap muat pada layar kecil, teks 200%, dan saat papan ketik terbuka.
class ChatWelcome extends ConsumerWidget {
  const ChatWelcome({required this.canCheckin, super.key});

  /// Belum ada pesan hari ini dan batas harian belum tercapai.
  final bool canCheckin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final skipped = ref.watch(
      checkinControllerProvider.select((state) => state.skipped),
    );

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const MascotView(
              state: MascotState.idle,
              height: RbSize.mascotWelcomeHeight,
            ),
            SizedBox(height: space.md),
            Text(
              AppTexts.welcome,
              textAlign: TextAlign.center,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
            if (canCheckin && !skipped) ...<Widget>[
              SizedBox(height: space.lg),
              const CheckinCard(),
            ],
          ],
        ),
      ),
    );
  }
}
