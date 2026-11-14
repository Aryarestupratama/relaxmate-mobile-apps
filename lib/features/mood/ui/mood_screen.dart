import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';
import 'package:relaxmate/features/mood/ui/mood_chart.dart';
import 'package:relaxmate/features/mood/ui/mood_range_toggle.dart';
import 'package:relaxmate/features/mood/ui/mood_recent_notes.dart';
import 'package:relaxmate/features/mood/ui/mood_summary_row.dart';
import 'package:relaxmate/shared/widgets/app_bottom_nav.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/surface_card.dart';
import 'package:relaxmate/shared/widgets/tab_back_scope.dart';

/// SCR-M23: Mood (FR-M030). Grafik 7 atau 30 hari, ringkasan, catatan terakhir, keadaan
/// kosong, dan penegasan "bukan diagnosis". Perlu masuk; tanpa `ConsentGate` dan tanpa AI.
/// Data dari API-M019, hanya di memori.
class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int _days = AppConstants.moodRangeShortDays;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final state = ref.watch(moodSeriesControllerProvider(_days));

    return TabBackScope(
      child: Scaffold(
        backgroundColor: colors.surfaceAlt,
        appBar: AppBar(
          backgroundColor: colors.surfaceAlt,
          leading: IconButton(
            onPressed: () => context.go(AppRoutes.home),
            tooltip: AppTexts.moodBackTooltip,
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: Semantics(
            header: true,
            child: const Text(AppTexts.moodTitle),
          ),
        ),
        bottomNavigationBar: const AppBottomNav(current: AppTab.mood),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(space.md),
            children: <Widget>[
              MoodRangeToggle(
                days: _days,
                onChanged: (value) => setState(() => _days = value),
              ),
              SizedBox(height: space.md),
              ..._content(state),
              SizedBox(height: space.md),
              Center(
                child: Text(
                  AppTexts.moodDisclaimer,
                  textAlign: TextAlign.center,
                  style: text.small.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(MoodSeriesState state) {
    final space = context.rbSpace;
    final controller = ref.read(moodSeriesControllerProvider(_days).notifier);

    return switch (state) {
      MoodSeriesLoading() => <Widget>[
          const SurfaceCard(
            child: SizedBox(
              height: RbSize.moodChartHeight,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      MoodSeriesFailed(:final error) => <Widget>[
          ErrorAlert(message: error.message, onRetry: controller.load),
        ],
      MoodSeriesReady(:final series) when series.isEmpty => <Widget>[
          const _EmptyCard(),
        ],
      MoodSeriesReady(:final series) => <Widget>[
          _ChartCard(series: series),
          SizedBox(height: space.sm),
          MoodSummaryRow(series: series),
          SizedBox(height: space.sm),
          MoodRecentNotes(series: series),
        ],
    };
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.series});

  final MoodSeries series;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MoodChart(series: series),
          SizedBox(height: space.sm),
          if (series.filledDays == 1) ...<Widget>[
            Text(
              AppTexts.homeChartOneDay,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.xs),
          ],
          Text(
            AppTexts.moodChartCaption,
            style: text.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return SurfaceCard(
      child: Column(
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(AppTexts.moodEmptyTitle, style: text.h3),
          ),
          SizedBox(height: space.xs),
          Text(
            AppTexts.moodEmptyBody,
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: space.md),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text(AppTexts.moodEmptyAction),
          ),
        ],
      ),
    );
  }
}
