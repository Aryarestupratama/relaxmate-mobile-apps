import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/ui/chat_bubble.dart';
import 'package:relaxmate/features/history/state/conversation_controller.dart';
import 'package:relaxmate/features/history/state/conversation_state.dart';
import 'package:relaxmate/features/history/ui/history_load_more.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M15: detail satu hari, hanya baca (FR-M005). Pesan urut lama ke baru memakai
/// `ChatBubble` yang sama dengan chat; tanpa kolom isian, tanpa chip saran, dan tanpa
/// "Coba lagi" untuk balasan. Dibungkus `ConsentGate` di router.
class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = conversationControllerProvider(conversationId);
    final conversation = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final space = context.rbSpace;
    final title = switch (conversation) {
      ConversationReady(:final label) when label.isNotEmpty => label,
      _ => AppTexts.historyTitle,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          // Jalur ke bantuan nyata selalu terlihat (Design-M prinsip 4).
          IconButton(
            onPressed: () => context.push(AppRoutes.crisisContacts),
            tooltip: AppTexts.crisisMenuTooltip,
            icon: const Icon(LucideIcons.phone),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (conversation) {
          ConversationLoading() =>
            const Center(child: CircularProgressIndicator()),
          ConversationLoadFailed(:final error) => Center(
              child: Padding(
                padding: EdgeInsets.all(space.lg),
                child: ErrorAlert(
                  message: error.message,
                  onRetry: controller.load,
                ),
              ),
            ),
          final ConversationReady ready => _ConversationBody(
              ready: ready,
              onLoadMore: controller.loadMore,
            ),
        },
      ),
    );
  }
}

class _ConversationBody extends StatelessWidget {
  const _ConversationBody({required this.ready, required this.onLoadMore});

  final ConversationReady ready;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final footer = ready.hasMore ? 1 : 0;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(space.md),
            itemCount: ready.messages.length + footer,
            itemBuilder: (context, index) {
              if (index == ready.messages.length) {
                return HistoryLoadMore(
                  label: AppTexts.historyLoadMoreMessages,
                  loading: ready.loadingMore,
                  error: ready.moreError,
                  onPressed: onLoadMore,
                );
              }
              return ChatBubble(message: ready.messages[index]);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(space.sm),
          child: Text(
            AppTexts.historyReadOnly,
            textAlign: TextAlign.center,
            style: text.caption.copyWith(color: colors.textMuted),
          ),
        ),
      ],
    );
  }
}
