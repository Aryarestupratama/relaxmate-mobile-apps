import 'dart:async';

import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';
import 'package:relaxmate/features/chat/state/chat_state.dart';
import 'package:relaxmate/features/chat/ui/chat_bubble.dart';
import 'package:relaxmate/features/chat/ui/suggestion_chips.dart';
import 'package:relaxmate/features/chat/ui/typing_indicator.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';
import 'package:relaxmate/features/mascot/ui/mascot_view.dart';

/// Isi tengah SCR-M08 pada tampilan maskot (FR-M027): maskot di atas, di bawahnya pesan
/// terakhir pengguna dan balasan terakhir RelaxMate. Isi percakapan, banner krisis, kolom
/// ketik, kuota, dan galat sama dengan tampilan obrolan (dipasang oleh `ChatScreen`); hanya
/// bagian tengah ini yang berbeda. Percakapan lengkap ada di tampilan obrolan.
///
/// Keadaan maskot: berpikir selama menunggu balasan; bicara beberapa detik setelah balasan
/// baru tampil; selain itu diam. Setelah krisis terdeteksi hari itu maskot tetap diam dan
/// tenang. Tanpa suara, jadi teks tetap sumber utama dan diumumkan lewat live region.
class MascotChatPane extends StatefulWidget {
  const MascotChatPane({
    required this.ready,
    required this.suggestionIds,
    required this.onDismissSuggestion,
    required this.onShowConversation,
    super.key,
  });

  final ChatReady ready;

  /// Id pesan yang saran tindakannya tampil (aturan sama dengan tampilan obrolan).
  final Set<int> suggestionIds;
  final ValueChanged<int> onDismissSuggestion;
  final VoidCallback onShowConversation;

  @override
  State<MascotChatPane> createState() => _MascotChatPaneState();
}

class _MascotChatPaneState extends State<MascotChatPane> {
  Timer? _speakingTimer;
  bool _speaking = false;
  int? _seenAssistantId;

  @override
  void initState() {
    super.initState();
    // Balasan yang sudah ada saat layar dibuka bukan balasan baru.
    _seenAssistantId = _latestAssistant(widget.ready.messages)?.id;
  }

  @override
  void didUpdateWidget(MascotChatPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    final latest = _latestAssistant(widget.ready.messages);
    if (latest != null && latest.id != _seenAssistantId) {
      _seenAssistantId = latest.id;
      _speaking = true;
      _speakingTimer?.cancel();
      _speakingTimer = Timer(RbMotion.mascotSpeaking, () {
        if (mounted) {
          setState(() => _speaking = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _speakingTimer?.cancel();
    super.dispose();
  }

  static ChatMessage? _latestAssistant(List<ChatMessage> messages) {
    for (final message in messages.reversed) {
      if (message.role == ChatRole.assistant) {
        return message;
      }
    }
    return null;
  }

  /// Pesan terakhir; bila itu balasan RelaxMate, pesan pengguna tepat sebelumnya ikut tampil
  /// sebagai konteks.
  static List<ChatMessage> _shown(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return const <ChatMessage>[];
    }
    final tail = messages.last;
    if (tail.role == ChatRole.assistant && messages.length > 1) {
      final previous = messages[messages.length - 2];
      if (previous.role == ChatRole.user) {
        return <ChatMessage>[previous, tail];
      }
    }
    return <ChatMessage>[tail];
  }

  MascotState _mascotState() {
    final ready = widget.ready;
    if (ready.hasCrisis) {
      return MascotState.idle;
    }
    if (ready.sending) {
      return MascotState.thinking;
    }
    return _speaking ? MascotState.speaking : MascotState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final ready = widget.ready;
    final shown = _shown(ready.messages);
    if (shown.isEmpty) {
      return const SizedBox.shrink();
    }
    final compact = MediaQuery.viewInsetsOf(context).bottom > 0 ||
        MediaQuery.textScalerOf(context).scale(1) >
            RbSize.moodRowMaxTextScale;
    // Saran mendesak pada pesan lama tetap tampil (aturan sama dengan tampilan obrolan).
    final withSuggestions = ready.messages
        .where((message) => widget.suggestionIds.contains(message.id))
        .toList();

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: space.sm),
          child: MascotView(
            state: _mascotState(),
            height: compact
                ? RbSize.mascotChatCompactHeight
                : RbSize.mascotChatHeight,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            // Pesan baru memulai gulir dari atas.
            key: ValueKey<int>(shown.last.id),
            padding: EdgeInsets.all(space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final message in shown)
                  ChatBubble(
                    message: message,
                    announce: identical(message, shown.last),
                    fullWidth: message.role == ChatRole.assistant,
                  ),
                if (ready.sending) const TypingIndicator(),
                for (final message in withSuggestions)
                  if (message.suggestion case final suggestion?)
                    SuggestionChips(
                      suggestion: suggestion,
                      onDismiss: () => widget.onDismissSuggestion(message.id),
                    ),
                Center(
                  child: TextButton(
                    onPressed: widget.onShowConversation,
                    child: const Text(AppTexts.chatSeeConversation),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
