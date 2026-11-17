import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/history/data/history_timeline.dart';
import 'package:relaxmate/features/history/state/history_controller.dart';
import 'package:relaxmate/features/history/state/history_state.dart';
import 'package:relaxmate/features/history/ui/history_date_label.dart';
import 'package:relaxmate/features/history/ui/history_empty_view.dart';
import 'package:relaxmate/features/history/ui/history_entry_tile.dart';
import 'package:relaxmate/features/history/ui/history_load_more.dart';
import 'package:relaxmate/features/history/ui/history_rail_item.dart';
import 'package:relaxmate/features/history/ui/history_skeleton.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/rb_app_bar.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// SCR-M14: riwayat sebagai garis waktu per tanggal, hanya baca (FR-M005). Latar gradien
/// lembut seperti layar lain, satu kalimat pembuka, lalu rel dengan penanda tanggal dan kartu
/// percakapan melayang (TASK-M073 bagian 9). Dibungkus `ConsentGate` di router. Isi diambil
/// dari server tiap layar dibuka (ADR-M07) dan butuh internet. Gerak hanya masuk berurutan
/// untuk beberapa baris pertama.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);
    final space = context.rbSpace;

    return Scaffold(
      backgroundColor: context.rbColors.pageBg,
      extendBodyBehindAppBar: true,
      appBar: const RbAppBar.pushed(title: AppTexts.historyTitle),
      body: SoftGradientBackground(
        child: SafeArea(
          child: switch (history) {
            HistoryLoading() => const HistorySkeleton(),
            HistoryLoadFailed(:final error) => Center(
                child: Padding(
                  padding: EdgeInsets.all(space.lg),
                  child: ErrorAlert(
                    message: error.message,
                    onRetry: controller.load,
                  ),
                ),
              ),
            final HistoryReady ready => ready.days.isEmpty
                ? const HistoryEmptyView()
                : _HistoryList(ready: ready, onLoadMore: controller.loadMore),
          },
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.ready, required this.onLoadMore});

  final HistoryReady ready;
  final VoidCallback onLoadMore;

  /// Hanya sebanyak ini baris pertama yang masuk berurutan; sisanya tampil langsung supaya
  /// gulir panjang tidak memutar gerak masuk berulang.
  static const int _entranceRows = 5;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final items = buildHistoryTimeline(ready.days);
    final footer = ready.hasMore ? 1 : 0;
    // Baris 0 adalah kalimat pembuka; garis waktu mulai dari baris 1.
    final lastIndex = items.length;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(space.lg, space.md, space.lg, space.lg),
      itemCount: items.length + footer + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: space.md),
            child: RbEntrance(
              child: Text(
                AppTexts.historySubtitle,
                style: text.body.copyWith(color: colors.textSecondary),
              ),
            ),
          );
        }
        if (index > lastIndex) {
          return Padding(
            padding: EdgeInsetsDirectional.only(
              start: RbSize.historyRailWidth,
            ),
            child: HistoryLoadMore(
              label: AppTexts.historyLoadMore,
              loading: ready.loadingMore,
              error: ready.moreError,
              onPressed: onLoadMore,
            ),
          );
        }
        final itemIndex = index - 1;
        final item = items[itemIndex];
        final isLast = itemIndex == items.length - 1 && !ready.hasMore;
        final Widget row = switch (item) {
          HistoryDateHeader(:final dayKey) => HistoryRailItem(
              dot: HistoryRailDot.date,
              isFirst: itemIndex == 0,
              child: HistoryDateLabel(dayKey: dayKey),
            ),
          HistoryEntry(:final day) => HistoryRailItem(
              dot: HistoryRailDot.entry,
              isLast: isLast,
              child: HistoryEntryTile(
                day: day,
                onTap: () => context.push(AppRoutes.historyDetail(day.id)),
              ),
            ),
        };
        if (itemIndex >= _entranceRows) {
          return row;
        }
        return RbEntrance(index: itemIndex + 1, child: row);
      },
    );
  }
}
