import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/history/data/history_timeline.dart';
import 'package:relaxmate/features/history/state/history_controller.dart';
import 'package:relaxmate/features/history/state/history_state.dart';
import 'package:relaxmate/features/history/ui/history_entry_tile.dart';
import 'package:relaxmate/features/history/ui/history_load_more.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M14: riwayat sebagai garis waktu per tanggal, hanya baca (FR-M005). Dibungkus
/// `ConsentGate` di router. Isi diambil dari server tiap layar dibuka (ADR-M07) dan butuh
/// internet.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);
    final space = context.rbSpace;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.historyTitle),
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
        child: switch (history) {
          HistoryLoading() => const Center(child: CircularProgressIndicator()),
          HistoryLoadFailed(:final error) => Center(
              child: Padding(
                padding: EdgeInsets.all(space.lg),
                child: ErrorAlert(
                  message: error.message,
                  onRetry: controller.load,
                ),
              ),
            ),
          final HistoryReady ready => _HistoryList(
              ready: ready,
              onLoadMore: controller.loadMore,
            ),
        },
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.ready, required this.onLoadMore});

  final HistoryReady ready;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    if (ready.days.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(space.lg),
          child: Text(
            AppTexts.historyEmpty,
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    final items = buildHistoryTimeline(ready.days);
    final footer = ready.hasMore ? 1 : 0;

    return ListView.builder(
      padding: EdgeInsets.all(space.md),
      itemCount: items.length + footer,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return HistoryLoadMore(
            label: AppTexts.historyLoadMore,
            loading: ready.loadingMore,
            error: ready.moreError,
            onPressed: onLoadMore,
          );
        }
        return switch (items[index]) {
          HistoryDateHeader(:final dayKey) => _DateHeader(dayKey: dayKey),
          HistoryEntry(:final day) => HistoryEntryTile(
              day: day,
              onTap: () => context.push(AppRoutes.historyDetail(day.id)),
            ),
        };
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.dayKey});

  final String dayKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsets.only(top: space.sm, bottom: space.xxs),
        child: Text(
          formatDayKey(dayKey),
          style: text.small.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
