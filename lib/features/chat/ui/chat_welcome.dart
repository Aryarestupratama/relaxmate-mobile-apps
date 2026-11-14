import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/state/chat_controller.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';
import 'package:relaxmate/features/mascot/ui/mascot_view.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';

/// Sambutan saat belum ada pesan hari ini (SCR-M08). Bila mood hari ini sudah tercatat di
/// Beranda dan batas harian belum tercapai ([canSend]), ditawarkan chip pembuka "Aku merasa
/// (nama mood) hari ini" (OQ-MP5): dikirim hanya bila pengguna mengetuknya, tanpa panggilan AI
/// tambahan. Dapat digulir agar tetap muat pada layar kecil, teks 200%, dan saat papan ketik
/// terbuka.
class ChatWelcome extends ConsumerWidget {
  const ChatWelcome({required this.canSend, super.key});

  /// Batas pesan harian belum tercapai.
  final bool canSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final mood = ref.watch(todayMoodProvider);

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
            if (canSend && mood != null) ...<Widget>[
              SizedBox(height: space.lg),
              Text(
                AppTexts.chatMoodChipHint,
                textAlign: TextAlign.center,
                style: text.small.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: space.xs),
              OutlinedButton(
                onPressed: () => ref
                    .read(chatControllerProvider.notifier)
                    .send(mood.level.chatMessage),
                child: Text(mood.level.chatMessage),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
