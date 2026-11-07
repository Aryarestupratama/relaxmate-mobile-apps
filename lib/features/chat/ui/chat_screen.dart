import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/chat/data/suggestion_visibility.dart';
import 'package:relaxmate/features/chat/state/chat_controller.dart';
import 'package:relaxmate/features/chat/state/chat_state.dart';
import 'package:relaxmate/features/chat/state/send_outcome.dart';
import 'package:relaxmate/features/chat/ui/chat_bubble.dart';
import 'package:relaxmate/features/chat/ui/chat_input_bar.dart';
import 'package:relaxmate/features/chat/ui/suggestion_chips.dart';
import 'package:relaxmate/features/chat/ui/typing_indicator.dart';
import 'package:relaxmate/features/crisis/ui/crisis_banner.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// SCR-M08: aliran chat harian (FR-M004, M006, M007). Dibungkus `ConsentGate` di router.
/// Tampilan sengaja sederhana sampai desain final tersedia.
/// TODO(TASK-M031): pindahkan tombol Keluar ke Pengaturan.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _input = TextEditingController();

  /// Pesan yang saran tindakannya sudah ditutup pengguna. Hanya di memori; kembali tampil
  /// bila layar dibuka ulang (sama dengan web).
  final Set<int> _dismissedSuggestions = <int>{};

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) {
      return;
    }
    _input.clear();
    final outcome = await ref.read(chatControllerProvider.notifier).send(text);
    // Pesan yang tidak tersimpan dikembalikan ke kolom teks (isian tidak hilang).
    if (outcome == SendOutcome.rejected && mounted && _input.text.isEmpty) {
      _input.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _dismissSuggestion(int messageId) {
    setState(() => _dismissedSuggestions.add(messageId));
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);
    final space = context.rbSpace;

    return Scaffold(
      appBar: AppBar(
        title: const _ChatTitle(),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push(AppRoutes.history),
            tooltip: AppTexts.historyTooltip,
            icon: const Icon(LucideIcons.history),
          ),
          // Jalur ke bantuan nyata selalu terlihat, tidak tersembunyi di menu (Design-M
          // prinsip 4).
          IconButton(
            onPressed: () => context.push(AppRoutes.crisisContacts),
            tooltip: AppTexts.crisisMenuTooltip,
            icon: const Icon(LucideIcons.phone),
          ),
          TextButton(
            onPressed: ref.read(authControllerProvider.notifier).logout,
            child: const Text(AppTexts.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (chat) {
          ChatLoading() => const Center(child: CircularProgressIndicator()),
          ChatLoadFailed(:final error) => Center(
              child: Padding(
                padding: EdgeInsets.all(space.lg),
                child: ErrorAlert(
                  message: error.message,
                  onRetry: controller.load,
                ),
              ),
            ),
          final ChatReady ready => _ChatBody(
              ready: ready,
              input: _input,
              onSend: _send,
              onRetry: controller.retry,
              dismissedSuggestions: _dismissedSuggestions,
              onDismissSuggestion: _dismissSuggestion,
            ),
        },
      ),
    );
  }
}

class _ChatTitle extends StatelessWidget {
  const _ChatTitle();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Row(
      children: <Widget>[
        const MateAvatar(size: MateAvatarSize.small),
        SizedBox(width: space.sm),
        Text(AppTexts.appName, style: text.h3),
        SizedBox(width: space.xs),
        Container(
          padding: EdgeInsets.symmetric(horizontal: space.xs),
          decoration: BoxDecoration(
            color: colors.softLavender,
            borderRadius: RbRadius.pillBorder,
          ),
          child: Text(AppTexts.aiBadge, style: text.caption),
        ),
      ],
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.ready,
    required this.input,
    required this.onSend,
    required this.onRetry,
    required this.dismissedSuggestions,
    required this.onDismissSuggestion,
  });

  final ChatReady ready;
  final TextEditingController input;
  final VoidCallback onSend;
  final VoidCallback onRetry;
  final Set<int> dismissedSuggestions;
  final ValueChanged<int> onDismissSuggestion;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final error = ready.error;
    final newestFirst = ready.messages.reversed.toList();
    final typing = ready.sending ? 1 : 0;
    final suggestionIds = visibleSuggestionIds(
      ready.messages,
      dismissedSuggestions,
    );

    return Column(
      children: <Widget>[
        if (ready.hasCrisis) const CrisisBanner(),
        Expanded(
          child: newestFirst.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(space.lg),
                    child: Text(
                      AppTexts.welcome,
                      textAlign: TextAlign.center,
                      style: text.body.copyWith(color: colors.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(space.md),
                  itemCount: newestFirst.length + typing,
                  itemBuilder: (context, index) {
                    if (typing == 1 && index == 0) {
                      return const TypingIndicator();
                    }
                    final position = index - typing;
                    final message = newestFirst[position];
                    final bubble = ChatBubble(
                      message: message,
                      announce: position == 0,
                    );
                    final suggestion = message.suggestion;
                    if (suggestion == null ||
                        !suggestionIds.contains(message.id)) {
                      return bubble;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        bubble,
                        SuggestionChips(
                          suggestion: suggestion,
                          onDismiss: () => onDismissSuggestion(message.id),
                        ),
                      ],
                    );
                  },
                ),
        ),
        if (error != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: space.md),
            child: ErrorAlert(
              message: error,
              onRetry: ready.unanswered && !ready.sending ? onRetry : null,
            ),
          ),
        if (ready.limitReached)
          Padding(
            padding: EdgeInsets.all(space.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    AppTexts.chatDailyLimit,
                    textAlign: TextAlign.center,
                    style: text.small.copyWith(color: colors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.crisisContacts),
                  child: const Text(AppTexts.crisisSeeAll),
                ),
              ],
            ),
          )
        else ...<Widget>[
          ChatInputBar(
            controller: input,
            sendEnabled: !ready.sending,
            maxLength: ready.limits.messageMaxChars,
            onSend: onSend,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: space.xs),
            child: Text(
              AppTexts.chatRemaining(
                ready.limits.remainingToday,
                ready.limits.perDay,
              ),
              style: text.caption.copyWith(color: colors.textMuted),
            ),
          ),
        ],
      ],
    );
  }
}
