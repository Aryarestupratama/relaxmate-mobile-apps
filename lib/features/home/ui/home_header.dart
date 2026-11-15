import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// SCR-M22, kepala Beranda (TASK-M074): avatar di kiri, Pengaturan di kanan sebagai tombol
/// bulat putih berbayang, lalu sapaan dua baris yang besar dan sadar waktu ("Selamat sore,
/// Arya") dengan satu kalimat hangat di bawahnya. Kalimat hangat berganti setelah mood hari
/// ini tercatat. Tanpa skor atau angka (RULE-M046).
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _salutation(DayPeriod period) => switch (period) {
        DayPeriod.morning => AppTexts.greetMorning,
        DayPeriod.noon => AppTexts.greetNoon,
        DayPeriod.afternoon => AppTexts.greetAfternoon,
        DayPeriod.evening => AppTexts.greetEvening,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final auth = ref.watch(authControllerProvider);
    final fullName = auth is AuthAuthenticated ? auth.user.name.trim() : '';
    final firstName = fullName.split(RegExp(r'\s+')).first;
    final done = ref.watch(todayMoodProvider) != null;
    final salutation = _salutation(dayPeriodOf(DateTime.now()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const MateAvatar(size: MateAvatarSize.small),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.card,
                shape: BoxShape.circle,
                boxShadow: RbShadow.card(colors),
              ),
              child: IconButton(
                onPressed: () => context.push<void>(AppRoutes.settings),
                tooltip: AppTexts.settingsTooltip,
                icon: const Icon(LucideIcons.settings),
                color: colors.primary,
                style: IconButton.styleFrom(
                  minimumSize: const Size.square(RbSize.minTouch),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: space.md),
        Semantics(
          header: true,
          child: Text(
            AppTexts.homeGreeting(salutation, firstName),
            style: text.h1,
          ),
        ),
        SizedBox(height: space.xxs),
        Text(
          done ? AppTexts.homeGreetingSubDone : AppTexts.homeGreetingSub,
          style: text.body.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
