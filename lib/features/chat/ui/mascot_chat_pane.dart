import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';
import 'package:relaxmate/features/chat/data/chat_suggestion.dart';
import 'package:relaxmate/features/chat/state/chat_controller.dart';
import 'package:relaxmate/features/chat/state/chat_state.dart';
import 'package:relaxmate/features/chat/ui/mascot_aura.dart';
import 'package:relaxmate/features/chat/ui/mascot_reply_bubble.dart';
import 'package:relaxmate/features/chat/ui/mascot_user_bubble.dart';
import 'package:relaxmate/features/chat/ui/suggestion_chips.dart';
import 'package:relaxmate/features/crisis/ui/sos_button.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';
import 'package:relaxmate/features/mascot/ui/mascot_view.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';

/// Aset maskot yang terpasang masih setengah badan: bagian bawahnya dipudarkan. Ubah ke
/// `false` (dan sesuaikan `RbSize.mascotFrameAspect`) saat aset badan penuh dipasang (M075).
const bool _mascotIsHalfBody = true;

/// Isi tengah SCR-M08 pada tampilan maskot (FR-M027, dipoles di TASK-M073 bagian 8).
///
/// Panggung: maskot besar berbingkai gelap agak ke kiri dengan cahaya lembut di belakangnya;
/// balasan RelaxMate berbentuk gelembung chat di samping kanan kepalanya (tiga titik selagi
/// menulis, lalu teks yang "diketik"). Di bawah panggung, di tengah, pesan terakhir pengguna.
/// Saran tindakan tampil di kaki gelembung balasan. Saat krisis terdeteksi hari itu, tombol
/// SOS tampil di pojok kanan atas panggung (menggantikan `CrisisBanner` pada tampilan ini).
/// Banner krisis, kolom ketik, kuota, dan galat tetap dipasang `ChatScreen`.
///
/// Keadaan maskot: berpikir selama menunggu balasan; bicara selama balasan baru diketik;
/// selain itu diam. Setelah krisis terdeteksi maskot tetap diam dan tenang. Tanpa suara, jadi
/// teks tetap sumber utama dan diumumkan lewat live region gelembung.
class MascotChatPane extends ConsumerWidget {
  const MascotChatPane({
    required this.ready,
    required this.suggestionIds,
    required this.onDismissSuggestion,
    required this.onReplyTyped,
    super.key,
  });

  final ChatReady ready;

  /// Id pesan yang saran tindakannya tampil (aturan sama dengan tampilan obrolan).
  final Set<int> suggestionIds;
  final ValueChanged<int> onDismissSuggestion;

  /// Animasi mengetik sebuah balasan selesai (id pesan).
  final ValueChanged<int> onReplyTyped;

  static ChatMessage? _lastWhere(List<ChatMessage> messages, ChatRole role) {
    for (final message in messages.reversed) {
      if (message.role == role) {
        return message;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.rbSpace;
    final messages = ready.messages;
    final empty = messages.isEmpty;
    final tail = empty ? null : messages.last;
    // Balasan yang tampil: pesan terakhir bila itu balasan RelaxMate.
    final reply = tail != null && tail.role == ChatRole.assistant ? tail : null;
    final lastUser = _lastWhere(messages, ChatRole.user);
    final fresh = reply != null && ready.freshAssistantId == reply.id;
    final mood = ref.watch(todayMoodProvider);
    final canSend = !ready.limitReached;

    final MascotState mascot;
    if (ready.hasCrisis) {
      mascot = MascotState.idle;
    } else if (ready.sending) {
      mascot = MascotState.thinking;
    } else {
      mascot = fresh ? MascotState.speaking : MascotState.idle;
    }

    final replySuggestion = reply == null ||
            fresh ||
            ready.sending ||
            !suggestionIds.contains(reply.id)
        ? null
        : reply.suggestion;
    // Saran mendesak pada pesan lama tetap tampil (aturan sama dengan tampilan obrolan).
    final olderSuggestions = messages
        .where(
          (message) =>
              suggestionIds.contains(message.id) &&
              message.suggestion != null &&
              message.id != reply?.id,
        )
        .toList();

    return Column(
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final mascotHeight = math.min(
                height,
                width *
                    RbSize.mascotStageWidthFactor /
                    RbSize.mascotFrameAspect,
              );
              final mascotWidth = mascotHeight * RbSize.mascotFrameAspect;
              final left = width * RbSize.mascotStageLeftFactor;
              final bubbleLeft =
                  left + mascotWidth * RbSize.mascotHeadRightFactor - space.xxs;
              final bubbleTopBase = (height - mascotHeight) +
                  mascotHeight * RbSize.mascotReplyTopFactor;
              // Saat SOS tampil, gelembung turun supaya tidak tertimpa tombolnya.
              final bubbleTop = ready.hasCrisis
                  ? math.max(bubbleTopBase, RbSize.minTouch + space.sm)
                  : bubbleTopBase;
              final bubbleMaxHeight =
                  math.max(height - bubbleTop - space.xs, 0).toDouble();
              final auraDiameter = mascotWidth * RbSize.mascotAuraFactor;
              final centerX = left + mascotWidth / 2;
              final centerY = height - mascotHeight * 0.6;

              final Widget? bubble = _replyBubble(
                reply: reply,
                empty: empty,
                fresh: fresh,
                maxHeight: bubbleMaxHeight,
                suggestion: replySuggestion,
              );

              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    left: centerX - auraDiameter / 2,
                    top: centerY - auraDiameter / 2,
                    child: MascotAura(diameter: auraDiameter),
                  ),
                  Positioned(
                    left: left,
                    bottom: 0,
                    width: mascotWidth,
                    height: mascotHeight,
                    child: MascotView(
                      state: mascot,
                      height: mascotHeight,
                      outlined: true,
                      fadeBottom: _mascotIsHalfBody,
                    ),
                  ),
                  if (bubble != null)
                    Positioned(
                      left: bubbleLeft,
                      top: bubbleTop,
                      right: space.md,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: MediaQuery.disableAnimationsOf(context)
                            ? bubble
                            : AnimatedSwitcher(
                                duration: RbMotion.bubbleSwap,
                                switchInCurve: RbMotion.curve,
                                layoutBuilder: (current, previous) => Stack(
                                  alignment: Alignment.topLeft,
                                  children: <Widget>[
                                    ...previous,
                                    if (current != null) current,
                                  ],
                                ),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: RbMotion.popFrom,
                                      end: 1,
                                    ).animate(animation),
                                    alignment: Alignment.centerLeft,
                                    child: child,
                                  ),
                                ),
                                child: bubble,
                              ),
                      ),
                    ),
                  if (ready.hasCrisis)
                    Positioned(
                      top: space.xs,
                      right: space.md,
                      child: const SosButton(),
                    ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(space.md, space.xs, space.md, space.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (lastUser != null)
                RbEntrance(
                  // Gerak masuk saat pesan pengguna baru ditambahkan (indeksnya bertambah);
                  // pesan tertunda yang menjadi pesan sungguhan tidak mengulangnya.
                  key: ValueKey<int>(messages.lastIndexOf(lastUser)),
                  child: MascotUserBubble(message: lastUser),
                )
              else if (canSend && mood != null) ...<Widget>[
                Text(
                  AppTexts.chatMoodChipHint,
                  textAlign: TextAlign.center,
                  style: context.rbText.small.copyWith(
                    color: context.rbColors.textSecondary,
                  ),
                ),
                SizedBox(height: space.xs),
                OutlinedButton(
                  onPressed: () => ref
                      .read(chatControllerProvider.notifier)
                      .send(mood.level.chatMessage),
                  child: Text(mood.level.chatMessage),
                ),
              ],
              for (final message in olderSuggestions)
                if (message.suggestion case final suggestion?)
                  SuggestionChips(
                    suggestion: suggestion,
                    onDismiss: () => onDismissSuggestion(message.id),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gelembung balasan sesuai keadaan, dengan kunci yang berubah tiap isi berganti (titik
  /// mengetik, sambutan, balasan) supaya `AnimatedSwitcher` memainkan pergantiannya. `null`
  /// bila tidak ada balasan untuk ditampilkan (pesan pengguna belum dijawab dan tidak sedang
  /// menunggu).
  Widget? _replyBubble({
    required ChatMessage? reply,
    required bool empty,
    required bool fresh,
    required double maxHeight,
    required ChatSuggestion? suggestion,
  }) {
    if (ready.sending) {
      return MascotReplyBubble(
        key: const ValueKey<String>('typing'),
        typing: true,
        maxHeight: maxHeight,
      );
    }
    if (empty) {
      return MascotReplyBubble(
        key: const ValueKey<String>('welcome'),
        text: AppTexts.welcome,
        maxHeight: maxHeight,
      );
    }
    if (reply == null) {
      return null;
    }
    return MascotReplyBubble(
      key: ValueKey<String>('reply-${reply.id}'),
      text: reply.content,
      typewriter: fresh,
      crisis: reply.isCrisis,
      onTyped: fresh ? () => onReplyTyped(reply.id) : null,
      suggestion: suggestion,
      onDismissSuggestion: () => onDismissSuggestion(reply.id),
      maxHeight: maxHeight,
    );
  }
}
