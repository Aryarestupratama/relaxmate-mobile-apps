import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';

/// SCR-M22, sapaan Beranda (TASK-M074): sapaan dua baris yang besar dan sadar waktu ("Selamat
/// sore, Arya") dengan satu kalimat hangat di bawahnya, kalimat itu hilang setelah mood hari ini
/// tercatat. Logo, nama fitur, dan SOS kini ada di `RbAppBar` (2026-11-15), Pengaturan di tab
/// navigasi bawah. Tanpa skor atau angka (RULE-M046).
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _salutation(GreetingPeriod period) => switch (period) {
        GreetingPeriod.morning => AppTexts.greetMorning,
        GreetingPeriod.noon => AppTexts.greetNoon,
        GreetingPeriod.afternoon => AppTexts.greetAfternoon,
        GreetingPeriod.evening => AppTexts.greetEvening,
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
    final salutation = _salutation(greetingPeriodOf(DateTime.now()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            AppTexts.homeGreeting(salutation, firstName),
            style: text.h1,
          ),
        ),
        if (!done) ...<Widget>[
          SizedBox(height: space.xxs),
          Text(
            AppTexts.homeGreetingSub,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}
