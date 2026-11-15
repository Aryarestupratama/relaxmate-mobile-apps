import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_space.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/ui/mood_level_color.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';

/// Empat tab utama (FR-M029): Beranda, Ngobrol, Latihan, Mood.
enum AppTab {
  home(AppRoutes.home, AppTexts.navHome),
  chat(AppRoutes.chat, AppTexts.navChat),
  exercises(AppRoutes.exercises, AppTexts.navExercises),
  mood(AppRoutes.mood, AppTexts.navMood);

  const AppTab(this.route, this.label);

  final String route;
  final String label;

  IconData get icon => switch (this) {
        AppTab.home => LucideIcons.house,
        AppTab.chat => LucideIcons.messageCircle,
        AppTab.exercises => LucideIcons.wind,
        AppTab.mood => Icons.bar_chart_rounded,
      };
}

/// Tab yang terakhir ditampilkan dock. Dock dibuat ulang tiap layar tab (ADR-M16), jadi
/// nilai ini yang memungkinkan pil aktif meluncur dari tab sebelumnya ke tab baru.
AppTab? _lastShownTab;

/// CMP-M30: dock navigasi bawah melayang, empat tab. Tab aktif berupa pil yang memuat ikon
/// dan label; tab lain hanya ikon. Warna pil mengikuti mood hari ini (token `mood1` sampai
/// `mood5`), `softLavender` bila belum diisi. Pil meluncur dari tab sebelumnya selama
/// [RbMotion.screen] (langsung pindah bila animasi dikurangi). Dipasang di
/// `bottomNavigationBar` tiap layar tab (ADR-M16). Berpindah tab memakai `go`.
class AppBottomNav extends ConsumerStatefulWidget {
  const AppBottomNav({required this.current, super.key});

  final AppTab current;

  @override
  ConsumerState<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends ConsumerState<AppBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: RbMotion.screen);
  late final AppTab _from;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _from = _lastShownTab ?? widget.current;
    _lastShownTab = widget.current;
    _controller.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (_from != widget.current && !MediaQuery.disableAnimationsOf(context)) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(AppTab target) {
    if (target == widget.current) {
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    context.go(target.route);
  }

  _DockLayout _layoutFor(
    AppTab tab,
    double inner,
    TextStyle labelStyle,
    TextScaler scaler,
    RbSpace space,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: tab.label, style: labelStyle),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final textWidth = painter.width;
    painter.dispose();

    final others = AppTab.values.length - 1;
    final chrome = space.sm * 2 + RbSize.icon + space.xxs;
    final maxActive = inner - others * RbSize.minTouch;
    final wanted = math.max(textWidth + chrome, RbSize.minTouch);
    final active = math.min(wanted, maxActive);
    return _DockLayout(
      active: tab,
      activeWidth: active,
      itemWidth: (inner - active) / others,
      labelWidth: math.max(0, math.min(textWidth, active - chrome)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final scaler = MediaQuery.textScalerOf(context);
    final today = ref.watch(todayMoodProvider);
    final accent =
        today == null ? colors.softLavender : today.level.colorOf(colors);
    final current = widget.current;
    final labelStyle = text.caption.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(space.md, space.xs, space.md, space.sm),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: RbSize.navDockMaxWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius:
                    const BorderRadius.all(Radius.circular(RbRadius.pill)),
                border: Border.all(color: colors.border),
                boxShadow: RbShadow.panel(colors),
              ),
              child: Padding(
                padding: EdgeInsets.all(space.xxs),
                child: Material(
                  type: MaterialType.transparency,
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final from = _layoutFor(
                        _from,
                        box.maxWidth,
                        labelStyle,
                        scaler,
                        space,
                      );
                      final to = _layoutFor(
                        current,
                        box.maxWidth,
                        labelStyle,
                        scaler,
                        space,
                      );
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => _buildDock(
                          colors: colors,
                          labelStyle: labelStyle,
                          space: space,
                          accent: accent,
                          from: from,
                          to: to,
                          t: RbMotion.curve.transform(_controller.value),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDock({
    required RbColors colors,
    required TextStyle labelStyle,
    required RbSpace space,
    required Color accent,
    required _DockLayout from,
    required _DockLayout to,
    required double t,
  }) {
    final current = widget.current;
    final moving = _from != current;

    double labelOpacityOf(AppTab tab) {
      if (!moving) {
        return tab == current ? 1 : 0;
      }
      if (tab == current) {
        return t;
      }
      return tab == _from ? 1 - t : 0;
    }

    return SizedBox(
      height: RbSize.navItemHeight,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: lerpDouble(from.indicatorLeft, to.indicatorLeft, t),
            width: lerpDouble(from.activeWidth, to.activeWidth, t),
            top: 0,
            bottom: 0,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: accent),
              duration: RbMotion.screen,
              builder: (context, color, _) => DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(RbRadius.pill)),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final tab in AppTab.values)
                SizedBox(
                  width: lerpDouble(from.widthOf(tab), to.widthOf(tab), t),
                  child: _DockItem(
                    tab: tab,
                    selected: tab == current,
                    labelOpacity: labelOpacityOf(tab),
                    labelWidth: tab == current
                        ? to.labelWidth
                        : (tab == _from ? from.labelWidth : 0),
                    labelStyle: labelStyle,
                    onTap: () => _select(tab),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ukuran dock untuk satu tab aktif: lebar pil, lebar tab lain, dan lebar kotak label.
@immutable
class _DockLayout {
  const _DockLayout({
    required this.active,
    required this.activeWidth,
    required this.itemWidth,
    required this.labelWidth,
  });

  final AppTab active;
  final double activeWidth;
  final double itemWidth;
  final double labelWidth;

  double widthOf(AppTab tab) => tab == active ? activeWidth : itemWidth;

  double get indicatorLeft => active.index * itemWidth;
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.tab,
    required this.selected,
    required this.labelOpacity,
    required this.labelWidth,
    required this.labelStyle,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final double labelOpacity;
  final double labelWidth;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;
    final iconColor =
        Color.lerp(colors.textSecondary, colors.primary, labelOpacity);

    final item = InkWell(
      onTap: selected ? null : onTap,
      customBorder: const StadiumBorder(),
      child: ClipRect(
        child: OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(tab.icon, size: RbSize.icon, color: iconColor),
              if (labelOpacity > 0) ...<Widget>[
                SizedBox(width: space.xxs),
                Opacity(
                  opacity: labelOpacity,
                  child: SizedBox(
                    width: labelWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        softWrap: false,
                        style: labelStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      onTap: selected ? null : onTap,
      child: selected
          ? item
          : Tooltip(
              message: tab.label,
              excludeFromSemantics: true,
              child: item,
            ),
    );
  }
}
