import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

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

/// CMP-M30: navigasi bawah empat tab. Dipasang di `bottomNavigationBar` tiap layar tab (bukan
/// satu cangkang bersama) agar papan ketik di chat tidak mengecilkan layar dua kali. Tab aktif
/// tebal dan berwarna `primary`; label selalu tampil; target sentuh >= 48dp dari
/// `NavigationBar`. Berpindah tab memakai `go` (mengganti tumpukan).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.current, super.key});

  final AppTab current;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colors.card,
          surfaceTintColor: colors.card,
          elevation: 0,
          indicatorColor: colors.card,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) => states.contains(WidgetState.selected)
                ? text.caption.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  )
                : text.caption.copyWith(color: colors.textSecondary),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.textSecondary,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: current.index,
          onDestinationSelected: (index) {
            final target = AppTab.values[index];
            if (target != current) {
              context.go(target.route);
            }
          },
          destinations: <Widget>[
            for (final tab in AppTab.values)
              NavigationDestination(icon: Icon(tab.icon), label: tab.label),
          ],
        ),
      ),
    );
  }
}
