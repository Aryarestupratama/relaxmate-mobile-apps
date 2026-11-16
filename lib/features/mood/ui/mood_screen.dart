import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/crisis/ui/sos_button.dart';
import 'package:relaxmate/features/mood/data/mood_series.dart';
import 'package:relaxmate/features/mood/state/mood_series_controller.dart';
import 'package:relaxmate/features/mood/state/mood_series_state.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';
import 'package:relaxmate/features/mood/ui/mood_bubble_cloud.dart';
import 'package:relaxmate/features/mood/ui/mood_calendar.dart';
import 'package:relaxmate/features/mood/ui/mood_quick_log.dart';
import 'package:relaxmate/features/mood/ui/mood_range_toggle.dart';
import 'package:relaxmate/features/mood/ui/mood_recent_notes.dart';
import 'package:relaxmate/features/mood/ui/mood_reflection_card.dart';
import 'package:relaxmate/features/mood/ui/mood_summary_row.dart';
import 'package:relaxmate/features/mood/ui/mood_trend_chart.dart';
import 'package:relaxmate/shared/widgets/app_bottom_nav.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';
import 'package:relaxmate/shared/widgets/tab_back_scope.dart';

/// SCR-M23: Mood Tracker (FR-M030), didesain ulang 2026-11-15. Latar gradien lembut seperti
/// Beranda. Urutan: kalimat pengantar, pilihan rentang (pil 7 atau 30 hari), kartu isi mood
/// cepat (hanya bila hari ini belum diisi), gelembung blob mood yang paling sering
/// (`MoodBubbleCloud`), kartu refleksi dengan tombol ke RelaxMate, kartu grafik (kurva 7 hari
/// atau kalender 30 hari, plus ringkasan), riwayat terakhir, dan penegasan "bukan diagnosis".
/// Keadaan memuat, galat, dan kosong tersendiri. Perlu masuk; tanpa `ConsentGate` dan tanpa
/// AI. Data dari API-M019, hanya di memori.
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
    final shortSeries = ref.watch(
      moodSeriesControllerProvider(AppConstants.moodRangeShortDays),
    );
    final todayRecorded = ref.watch(todayMoodProvider) != null;

    // Check-in hanya menyegarkan deret 7 hari; rentang 30 hari ikut disegarkan di sini.
    ref.listen(
      checkinControllerProvider.select((value) => value.recorded),
      (previous, next) {
        if (next != null && _days != AppConstants.moodRangeShortDays) {
          ref.read(moodSeriesControllerProvider(_days).notifier).refresh();
        }
      },
    );

    // Kartu isi mood muncul setelah data 7 hari termuat, supaya tidak berkedip.
    final showQuickLog = shortSeries is MoodSeriesReady && !todayRecorded;

    return TabBackScope(
      child: Scaffold(
        backgroundColor: colors.pageBg,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => context.go(AppRoutes.home),
            tooltip: AppTexts.moodBackTooltip,
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: Semantics(
            header: true,
            child: const Text(AppTexts.moodTitle),
          ),
          actions: const <Widget>[SosAppBarAction()],
        ),
        bottomNavigationBar: const AppBottomNav(current: AppTab.mood),
        body: SoftGradientBackground(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                space.md,
                space.xs,
                space.md,
                space.lg,
              ),
              children: <Widget>[
                RbEntrance(
                  child: Text(
                    AppTexts.moodIntro,
                    style: text.body.copyWith(color: colors.textSecondary),
                  ),
                ),
                SizedBox(height: space.md),
                RbEntrance(
                  index: 1,
                  child: MoodRangeToggle(
                    days: _days,
                    onChanged: (value) => setState(() => _days = value),
                  ),
                ),
                if (showQuickLog) ...<Widget>[
                  SizedBox(height: space.md),
                  const RbEntrance(index: 2, child: MoodQuickLog()),
                ],
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
      ),
    );
  }

  List<Widget> _content(MoodSeriesState state) {
    final space = context.rbSpace;
    final controller = ref.read(moodSeriesControllerProvider(_days).notifier);

    return switch (state) {
      MoodSeriesLoading() => <Widget>[
          const FloatingCard(
            child: SizedBox(
              height: RbSize.moodCloudHeight,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      MoodSeriesFailed(:final error) => <Widget>[
          ErrorAlert(message: error.message, onRetry: controller.load),
        ],
      MoodSeriesReady(:final series) when series.isEmpty => <Widget>[
          const RbEntrance(index: 3, child: _EmptyCard()),
        ],
      MoodSeriesReady(:final series) => <Widget>[
          RbEntrance(
            index: 3,
            child: FloatingCard(child: MoodBubbleCloud(series: series)),
          ),
          SizedBox(height: space.md),
          RbEntrance(index: 4, child: MoodReflectionCard(series: series)),
          SizedBox(height: space.md),
          RbEntrance(index: 5, child: _TrendCard(series: series)),
          SizedBox(height: space.md),
          RbEntrance(
            index: 6,
            child: FloatingCard(child: MoodRecentNotes(series: series)),
          ),
        ],
    };
  }
}

/// Kartu grafik: kurva 7 hari atau kalender 30 hari, keterangan singkat, lalu ringkasan
/// rata-rata, hari terbaik, dan jumlah hari terisi dalam satu baris.
class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.series});

  final MoodSeries series;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final weekly = series.totalDays <= AppConstants.moodRangeShortDays;

    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              weekly ? AppTexts.moodTrendTitle : AppTexts.moodCalendarTitle,
              style: text.h3,
            ),
          ),
          SizedBox(height: space.sm),
          if (weekly)
            MoodTrendChart(series: series)
          else
            MoodCalendar(series: series),
          SizedBox(height: space.sm),
          if (series.filledDays == 1) ...<Widget>[
            Text(
              AppTexts.homeChartOneDay,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: space.xs),
          ],
          Text(
            weekly ? AppTexts.moodTrendCaption : AppTexts.moodCalendarCaption,
            style: text.caption.copyWith(color: colors.textSecondary),
          ),
          Divider(color: colors.border, height: space.md * 2),
          MoodSummaryRow(series: series),
        ],
      ),
    );
  }
}

/// Keadaan kosong: lima blob pudar, judul, dan ajakan mengisi mood lewat kartu isi cepat di
/// atasnya (tidak ada tombol sendiri).
class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  static const double _ghostAlpha = 0.4;
  static const double _ghostSize = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return FloatingCard(
      child: Column(
        children: <Widget>[
          ExcludeSemantics(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: space.xs,
              runSpacing: space.xs,
              children: <Widget>[
                for (final level in MoodLevel.values)
                  Opacity(
                    opacity: _ghostAlpha,
                    child: Image.asset(
                      level.asset,
                      width: _ghostSize,
                      height: _ghostSize,
                      excludeFromSemantics: true,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: space.sm),
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
        ],
      ),
    );
  }
}
