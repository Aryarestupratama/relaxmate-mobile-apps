import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/ui/chat_bubble.dart';
import 'package:relaxmate/features/history/state/conversation_controller.dart';
import 'package:relaxmate/features/history/state/conversation_state.dart';
import 'package:relaxmate/features/history/ui/history_load_more.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/rb_app_bar.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// SCR-M15: detail satu hari, hanya baca (FR-M005). Pesan urut lama ke baru memakai
/// `ChatBubble` gaya obrolan (avatar, nama, bayangan) agar sama dengan Ngobrol; tanpa kolom
/// isian, tanpa chip saran, dan tanpa "Coba lagi" untuk balasan. Latar gradien lembut dan
/// satu pil "hanya bisa dibaca" di bawah (TASK-M073 bagian 9). Dibungkus `ConsentGate` di
/// router.
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
      backgroundColor: context.rbColors.pageBg,
      extendBodyBehindAppBar: true,
      appBar: RbAppBar.pushed(title: title),
      body: SoftGradientBackground(
        child: SafeArea(
          child: switch (conversation) {
            ConversationLoading() => const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: AppTexts.loading,
                ),
              ),
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
    final space = context.rbSpace;
    final footer = ready.hasMore ? 1 : 0;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              space.md,
              space.md,
              space.md,
              space.sm,
            ),
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
              return ChatBubble(
                message: ready.messages[index],
                conversation: true,
              );
            },
          ),
        ),
        const _ReadOnlyPill(),
      ],
    );
  }
}

/// Pil kecil di kaki detail: penanda bahwa riwayat hanya bisa dibaca. Ikon dan teks
/// menyampaikannya, bukan warna (RULE-M052).
class _ReadOnlyPill extends StatelessWidget {
  const _ReadOnlyPill();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Padding(
      padding: EdgeInsets.fromLTRB(space.md, space.xxs, space.md, space.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: RbRadius.pillBorder,
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: space.md,
            vertical: space.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                LucideIcons.eye,
                size: RbSize.modeSwitchIcon,
                color: colors.textSecondary,
              ),
              SizedBox(width: space.xs),
              Flexible(
                child: Text(
                  AppTexts.historyReadOnly,
                  textAlign: TextAlign.center,
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
