import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/home/ui/home_chart_card.dart';
import 'package:relaxmate/features/home/ui/home_header.dart';
import 'package:relaxmate/features/home/ui/home_invite_card.dart';
import 'package:relaxmate/features/home/ui/home_week_card.dart';
import 'package:relaxmate/features/home/ui/mood_checkin_card.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';
import 'package:relaxmate/shared/widgets/app_bottom_nav.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

/// SCR-M22: Beranda, layar pertama setelah masuk (FR-M029). Latar gradien lembut seperti
/// layar Masuk dengan kartu putih melayang (TASK-M074). Sapaan sadar waktu, kartu mood, kartu
/// ringkasan mingguan, grafik 7 hari, undangan bercerita, jalan ke Ngobrol, Latihan napas,
/// Temani saja, dan tautan Kontak bantuan yang selalu ada. Tanpa `ConsentGate` dan tanpa AI:
/// consent hanya dicek saat membuka Ngobrol. Kartu masuk berurutan (`RbEntrance`); gerak
/// berulang hanya napas maskot di kartu undangan. Setelah mood tercatat: konfirmasi, ajakan
/// bercerita, ringkasan, grafik, lalu kartu bantuan lembut bila mood rendah.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final space = context.rbSpace;
    final today = ref.watch(todayMoodProvider);
    final editing =
        ref.watch(checkinControllerProvider.select((state) => state.editing));
    final done = today != null && !editing;
    final low = today != null &&
        today.level.value <= AppConstants.moodSupportCardMaxLevel;

    return Scaffold(
      backgroundColor: colors.pageBg,
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
      body: SoftGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(space.md),
            children: <Widget>[
              const RbEntrance(
                key: ValueKey<String>('header'),
                child: HomeHeader(),
              ),
              SizedBox(height: space.md),
              const RbEntrance(
                key: ValueKey<String>('mood'),
                index: 1,
                child: MoodCheckinCard(),
              ),
              SizedBox(height: space.sm),
              if (done) ...<Widget>[
                RbEntrance(
                  key: const ValueKey<String>('invite'),
                  index: 2,
                  child: HomeInviteCard(low: low),
                ),
                SizedBox(height: space.sm),
              ],
              const RbEntrance(
                key: ValueKey<String>('week'),
                index: 3,
                child: HomeWeekCard(),
              ),
              SizedBox(height: space.sm),
              const RbEntrance(
                key: ValueKey<String>('chart'),
                index: 4,
                child: HomeChartCard(),
              ),
              SizedBox(height: space.sm),
              if (!done) ...<Widget>[
                const RbEntrance(
                  key: ValueKey<String>('chat'),
                  index: 5,
                  child: _ChatButton(),
                ),
                SizedBox(height: space.sm),
                const RbEntrance(
                  key: ValueKey<String>('shortcuts'),
                  index: 6,
                  child: _Shortcuts(),
                ),
              ],
              SizedBox(height: space.md),
              if (done && low) const _SupportCard() else const _HelpLink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${AppTexts.homeChatTitle}. ${AppTexts.homeChatSubtitle}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: RbRadius.sheetBorder,
          boxShadow: RbShadow.card(colors),
        ),
        child: Material(
          color: colors.primary,
          borderRadius: RbRadius.sheetBorder,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.go(AppRoutes.chat),
            child: Padding(
              padding: EdgeInsets.all(space.md),
              child: Row(
                children: <Widget>[
                  const MateAvatar(size: MateAvatarSize.small),
                  SizedBox(width: space.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppTexts.homeChatTitle,
                          style: text.body.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          AppTexts.homeChatSubtitle,
                          style: text.small.copyWith(color: colors.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, color: colors.onPrimary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) > RbSize.homeRowMaxTextScale;

    final breathing = _ShortcutTile(
      title: AppTexts.homeBreathingTitle,
      subtitle: AppTexts.homeBreathingSubtitle,
      tint: colors.mood2,
      onTap: () => context.push<void>(AppRoutes.breathing),
    );
    final companion = _ShortcutTile(
      title: AppTexts.homeCompanionTitle,
      subtitle: AppTexts.homeCompanionSubtitle,
      tint: colors.mood1,
      onTap: () => context.push<void>(AppRoutes.companion),
    );

    if (stacked) {
      return Column(
        children: <Widget>[
          breathing,
          SizedBox(height: space.xs),
          companion,
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: breathing),
          SizedBox(width: space.xs),
          Expanded(child: companion),
        ],
      ),
    );
  }
}

/// Ubin pastel (token `mood2` dan `mood1`) berisi judul dan satu baris keterangan.
class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$title. $subtitle',
      child: FloatingCard(
        tint: tint,
        padding: EdgeInsets.zero,
        clip: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(space.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: text.small.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;

    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              AppTexts.homeSupportTitle,
              style: text.body.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            AppTexts.homeSupportBody,
            style: text.small.copyWith(color: colors.textSecondary),
          ),
          TextButton(
            onPressed: () => context.push<void>(AppRoutes.crisisContacts),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              AppTexts.homeSupportAction,
              style: text.button.copyWith(
                color: colors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tautan bantuan yang selalu terlihat di Beranda (FR-M029, Design-M prinsip 4); diganti
/// `_SupportCard` yang memuat tautan yang sama bila mood rendah.
class _HelpLink extends StatelessWidget {
  const _HelpLink();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;

    return Center(
      child: TextButton(
        onPressed: () => context.push<void>(AppRoutes.crisisContacts),
        child: Text(
          AppTexts.homeHelpLink + AppTexts.homeHelpLinkAction,
          textAlign: TextAlign.center,
          style: text.small.copyWith(
            color: colors.crisisText,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
