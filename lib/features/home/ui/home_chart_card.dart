import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';
import 'package:relaxmate/features/mood/ui/mood_chart.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/surface_card.dart';

/// SCR-M22, kartu "7 hari terakhir" (FR-M029): grafik ringkas, ringkasan satu kalimat, dan
/// tautan "Lihat semua" ke Mood. Gagal memuat tidak menghalangi bagian Beranda lainnya.
class HomeChartCard extends ConsumerWidget {
  const HomeChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final state = ref.watch(
      moodSeriesControllerProvider(AppConstants.moodRangeShortDays),
    );

    final Widget body = switch (state) {
      MoodSeriesLoading() => const SizedBox(
          height: RbSize.moodChartCompactHeight,
          child: Center(child: CircularProgressIndicator()),
        ),
      MoodSeriesFailed(:final error) => ErrorAlert(
          message: error.message,
          onRetry: ref
              .read(
                moodSeriesControllerProvider(AppConstants.moodRangeShortDays)
                    .notifier,
              )
              .load,
        ),
      MoodSeriesReady(:final series) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MoodChart(series: series, compact: true),
            SizedBox(height: space.xs),
            _Summary(series: series),
          ],
        ),
    };

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(AppTexts.homeChartTitle, style: text.h3),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.mood),
                child: Text(
                  AppTexts.homeChartSeeAll,
                  style: text.small.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          body,
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.series});

  final MoodSeries series;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final style = text.small.copyWith(color: colors.textSecondary);

    if (series.filledDays == 0) {
      return Text(AppTexts.homeChartEmpty, style: style);
    }
    if (series.filledDays == 1) {
      return Text(AppTexts.homeChartOneDay, style: style);
    }
    final average = series.averageLevel;
    final best = series.bestDate;
    if (average == null || best == null) {
      return const SizedBox.shrink();
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: <InlineSpan>[
          const TextSpan(text: AppTexts.homeChartAverageLead),
          TextSpan(
            text: average.label,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: AppTexts.homeChartBestLead),
          TextSpan(text: relativeDayLabel(best, series.to)),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
