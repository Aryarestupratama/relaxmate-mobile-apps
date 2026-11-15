import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/suggestion_visibility.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';
import 'package:relaxmate/features/chat/state/chat_controller.dart';
import 'package:relaxmate/features/chat/state/chat_state.dart';
import 'package:relaxmate/features/chat/state/send_outcome.dart';
import 'package:relaxmate/features/chat/ui/chat_backdrop.dart';
import 'package:relaxmate/features/chat/ui/chat_bubble.dart';
import 'package:relaxmate/features/chat/ui/chat_date_chip.dart';
import 'package:relaxmate/features/chat/ui/chat_entrance.dart';
import 'package:relaxmate/features/chat/ui/chat_input_bar.dart';
import 'package:relaxmate/features/chat/ui/chat_typing_row.dart';
import 'package:relaxmate/features/chat/ui/chat_welcome.dart';
import 'package:relaxmate/features/chat/ui/mascot_chat_pane.dart';
import 'package:relaxmate/features/chat/ui/suggestion_chips.dart';
import 'package:relaxmate/features/overlay/ui/overlay_resume_banner.dart';
import 'package:relaxmate/features/crisis/ui/crisis_banner.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/features/settings/data/chat_view_mode.dart';
import 'package:relaxmate/features/settings/state/settings_controller.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';
import 'package:relaxmate/shared/widgets/app_bottom_nav.dart';
import 'package:relaxmate/shared/widgets/tab_back_scope.dart';

/// Pilihan di menu bilah atas chat. Ikon telepon (kontak bantuan) sengaja di luar menu.
enum _ChatMenuAction { history, companion, settings }

/// SCR-M08: aliran chat harian (FR-M004, M006, M007), tab Ngobrol. Dibungkus `ConsentGate` di
/// router; Latihan kini tab sendiri di navigasi bawah, jadi tidak ada lagi di menu tiga titik.
/// Tampilan obrolan dipoles di TASK-M073 bagian 7: latar bulatan warna-warni tipis (`ChatBackdrop`),
/// avatar dan nama RelaxMate di balasan, penanda tanggal, balasan yang "diketik", dan kolom
/// ketik berbentuk kapsul.
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

  /// Indeks pesan (urut lama ke baru) yang gerak masuknya sudah dimainkan. Pesan yang sudah
  /// ada saat layar dibuka langsung dianggap sudah dimainkan, jadi hanya pesan baru yang
  /// bergerak masuk.
  final Set<int> _entered = <int>{};
  bool _seeded = false;

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
    final viewMode = ref.watch(
      settingsControllerProvider.select((settings) => settings.chatViewMode),
    );
    final isMascotView = viewMode == ChatViewMode.mascot;
    if (chat is ChatReady && !_seeded) {
      _seeded = true;
      _entered.addAll(
        List<int>.generate(chat.messages.length, (index) => index),
      );
    }

    return TabBackScope(
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: ChatBackdrop()),
          Scaffold(
            backgroundColor: Colors.transparent,
            bottomNavigationBar: const AppBottomNav(current: AppTab.chat),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const _ChatTitle(),
              actions: <Widget>[
                IconButton(
                  onPressed: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setChatViewMode(
                        isMascotView
                            ? ChatViewMode.conversation
                            : ChatViewMode.mascot,
                      ),
                  tooltip: isMascotView
                      ? AppTexts.chatModeToConversation
                      : AppTexts.chatModeToMascot,
                  icon: Icon(
                    isMascotView
                        ? LucideIcons.messageCircle
                        : LucideIcons.smile,
                  ),
                ),
                // Jalur ke bantuan nyata selalu terlihat, tidak tersembunyi di menu (Design-M
                // prinsip 4).
                IconButton(
                  onPressed: () => context.push(AppRoutes.crisisContacts),
                  tooltip: AppTexts.crisisMenuTooltip,
                  icon: const Icon(LucideIcons.phone),
                ),
                PopupMenuButton<_ChatMenuAction>(
                  tooltip: AppTexts.chatMenuTooltip,
                  onSelected: (action) {
                    switch (action) {
                      case _ChatMenuAction.history:
                        context.push<void>(AppRoutes.history);
                      case _ChatMenuAction.companion:
                        context.push<void>(AppRoutes.companion);
                      case _ChatMenuAction.settings:
                        context.push<void>(AppRoutes.settings);
                    }
                  },
                  itemBuilder: (context) =>
                      const <PopupMenuEntry<_ChatMenuAction>>[
                    PopupMenuItem<_ChatMenuAction>(
                      value: _ChatMenuAction.history,
                      child: Text(AppTexts.historyTooltip),
                    ),
                    PopupMenuItem<_ChatMenuAction>(
                      value: _ChatMenuAction.companion,
                      child: Text(AppTexts.companionMenu),
                    ),
                    PopupMenuItem<_ChatMenuAction>(
                      value: _ChatMenuAction.settings,
                      child: Text(AppTexts.settingsTitle),
                    ),
                  ],
                ),
              ],
            ),
            body: SafeArea(
              child: switch (chat) {
                ChatLoading() =>
                  const Center(child: CircularProgressIndicator()),
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
                    viewMode: viewMode,
                    onShowConversation: () => ref
                        .read(settingsControllerProvider.notifier)
                        .setChatViewMode(ChatViewMode.conversation),
                    input: _input,
                    onSend: _send,
                    onRetry: controller.retry,
                    dismissedSuggestions: _dismissedSuggestions,
                    onDismissSuggestion: _dismissSuggestion,
                    entered: _entered,
                    onReplyTyped: controller.markReplyShown,
                  ),
              },
            ),
          ),
        ],
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
    final showSubtitle =
        MediaQuery.textScalerOf(context).scale(1) <= RbSize.homeRowMaxTextScale;

    return Row(
      children: <Widget>[
        const MateAvatar(size: MateAvatarSize.small),
        SizedBox(width: space.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      AppTexts.appName,
                      style: text.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
              ),
              if (showSubtitle)
                Text(
                  AppTexts.chatHeaderSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.ready,
    required this.viewMode,
    required this.onShowConversation,
    required this.input,
    required this.onSend,
    required this.onRetry,
    required this.dismissedSuggestions,
    required this.onDismissSuggestion,
    required this.entered,
    required this.onReplyTyped,
  });

  final ChatReady ready;
  final ChatViewMode viewMode;
  final VoidCallback onShowConversation;
  final TextEditingController input;
  final VoidCallback onSend;
  final VoidCallback onRetry;
  final Set<int> dismissedSuggestions;
  final ValueChanged<int> onDismissSuggestion;

  /// Indeks pesan yang gerak masuknya sudah dimainkan (lihat `_ChatScreenState._entered`).
  final Set<int> entered;

  /// Animasi mengetik sebuah balasan selesai (id pesan).
  final ValueChanged<int> onReplyTyped;

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
        const OverlayResumeBanner(),
        Expanded(
          child: newestFirst.isEmpty
              ? ChatWelcome(canSend: !ready.limitReached)
              : viewMode == ChatViewMode.mascot
                  ? MascotChatPane(
                      ready: ready,
                      suggestionIds: suggestionIds,
                      onDismissSuggestion: onDismissSuggestion,
                      onShowConversation: onShowConversation,
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(space.md),
                      // Item terakhir (paling atas) adalah penanda tanggal.
                      itemCount: newestFirst.length + typing + 1,
                      // Kunci mengikuti urutan lama ke baru (stabil saat pesan tertunda
                      // menjadi pesan sungguhan), jadi animasi mengetik tidak mengulang
                      // ketika indikator menulis muncul dan menggeser daftar.
                      findChildIndexCallback: (key) {
                        if (key is ValueKey<int>) {
                          return ready.messages.length - 1 - key.value + typing;
                        }
                        if (key == _typingKey) {
                          return 0;
                        }
                        if (key == _dateKey) {
                          return newestFirst.length + typing;
                        }
                        return null;
                      },
                      itemBuilder: (context, index) {
                        if (typing == 1 && index == 0) {
                          return const ChatTypingRow(key: _typingKey);
                        }
                        if (index == newestFirst.length + typing) {
                          return const ChatDateChip(key: _dateKey);
                        }
                        final position = index - typing;
                        final message = newestFirst[position];
                        final oldestIndex =
                            ready.messages.length - 1 - position;
                        final isUser = message.role == ChatRole.user;
                        final fresh =
                            !isUser && message.id == ready.freshAssistantId;
                        final bubble = ChatBubble(
                          message: message,
                          announce: position == 0,
                          conversation: true,
                          typewriter: fresh,
                          onTyped:
                              fresh ? () => onReplyTyped(message.id) : null,
                        );
                        final suggestion = message.suggestion;
                        // Saran tindakan muncul setelah balasannya selesai diketik.
                        final Widget content = suggestion == null ||
                                fresh ||
                                !suggestionIds.contains(message.id)
                            ? bubble
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  bubble,
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: RbSize.avatarTiny + space.xs,
                                    ),
                                    child: _FadeIn(
                                      child: SuggestionChips(
                                        suggestion: suggestion,
                                        onDismiss: () =>
                                            onDismissSuggestion(message.id),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                        return ChatEntrance(
                          key: ValueKey<int>(oldestIndex),
                          entranceKey: oldestIndex,
                          played: entered,
                          alignment: isUser
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft,
                          child: content,
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

const ValueKey<String> _typingKey = ValueKey<String>('typing');
const ValueKey<String> _dateKey = ValueKey<String>('date');

/// Memudar masuk sekali saat pertama tampil (saran tindakan setelah balasan selesai diketik).
/// Bila gerak dikurangi, langsung tampil.
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: RbMotion.enter,
      curve: RbMotion.curve,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
