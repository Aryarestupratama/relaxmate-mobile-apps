import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/history/ui/history_rail_item.dart';

/// CMP-M60: kerangka pemuatan Riwayat: penanda tanggal dan tiga kartu kosong di atas rel yang
/// berdenyut pelan, supaya bentuk halaman sudah terlihat sebelum isinya tiba. Satu label
/// "Memuat..." untuk pembaca layar. Bila gerak dikurangi (RULE-M055) kerangka diam.
class HistorySkeleton extends StatefulWidget {
  const HistorySkeleton({super.key});

  @override
  State<HistorySkeleton> createState() => _HistorySkeletonState();
}

class _HistorySkeletonState extends State<HistorySkeleton>
    with SingleTickerProviderStateMixin {
  static const int _cardCount = 3;
  static const double _lowestOpacity = 0.45;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RbMotion.sosPulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;

    Widget block({required double height, required double width}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: RbRadius.sheetBorder,
        ),
      );
    }

    return Semantics(
      container: true,
      liveRegion: true,
      label: AppTexts.loading,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: Tween<double>(begin: _lowestOpacity, end: 1).animate(
            CurvedAnimation(
              parent: _controller,
              curve: RbMotion.breathCurve,
            ),
          ),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              space.lg,
              space.md,
              space.lg,
              space.lg,
            ),
            children: <Widget>[
              HistoryRailItem(
                dot: HistoryRailDot.date,
                isFirst: true,
                child: Padding(
                  padding: EdgeInsets.only(top: space.xs, bottom: space.sm),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: block(height: space.md, width: space.xxl * 2),
                  ),
                ),
              ),
              for (var i = 0; i < _cardCount; i++)
                HistoryRailItem(
                  dot: HistoryRailDot.entry,
                  isLast: i == _cardCount - 1,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: space.sm),
                    child: block(
                      height: RbSize.historySkeletonHeight,
                      width: double.infinity,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
