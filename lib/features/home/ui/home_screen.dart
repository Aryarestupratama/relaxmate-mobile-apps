import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/home/ui/home_chart_card.dart';
import 'package:relaxmate/features/home/ui/mood_checkin_card.dart';
import 'package:relaxmate/features/mood/state/today_mood_provider.dart';
import 'package:relaxmate/shared/widgets/app_bottom_nav.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';
import 'package:relaxmate/shared/widgets/surface_card.dart';

/// SCR-M22: Beranda, layar pertama setelah masuk (FR-M029). Sapaan, kartu mood, grafik 7 hari,
/// jalan ke Ngobrol, Latihan napas, Temani saja, dan tautan Kontak bantuan yang selalu ada.
/// Tanpa `ConsentGate` dan tanpa AI: consent hanya dicek saat membuka Ngobrol. Setelah mood
/// tercatat, tata letak mengikuti mockup: konfirmasi, ajakan bercerita, grafik, lalu kartu
/// bantuan lembut bila mood rendah.
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
      backgroundColor: colors.surfaceAlt,
      bottomNavigationBar: const AppBottomNav(current: AppTab.home),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(space.md),
          children: <Widget>[
            const _HomeHeader(),
            SizedBox(height: space.md),
            const MoodCheckinCard(),
            SizedBox(height: space.sm),
            if (done) ...<Widget>[
              _InviteCard(low: low),
              SizedBox(height: space.sm),
            ],
            const HomeChartCard(),
            SizedBox(height: space.sm),
            if (!done) ...<Widget>[
              const _ChatButton(),
              SizedBox(height: space.sm),
              const _Shortcuts(),
            ],
            SizedBox(height: space.md),
            if (done && low) const _SupportCard() else const _HelpLink(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final auth = ref.watch(authControllerProvider);
    final fullName = auth is AuthAuthenticated ? auth.user.name.trim() : '';
    final firstName = fullName.split(RegExp(r'\s+')).first;

    return Row(
      children: <Widget>[
        const MateAvatar(size: MateAvatarSize.small),
        SizedBox(width: space.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                longDateLabel(wibToday()),
                style: text.small.copyWith(color: colors.textSecondary),
              ),
              Semantics(
                header: true,
                child: Text(
                  AppTexts.homeGreeting(firstName),
                  style: text.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        IconButton.outlined(
          onPressed: () => context.push<void>(AppRoutes.settings),
          tooltip: AppTexts.settingsTooltip,
          icon: const Icon(LucideIcons.settings),
          style: IconButton.styleFrom(
            side: BorderSide(color: colors.border),
            backgroundColor: colors.card,
            minimumSize: const Size.square(RbSize.minTouch),
          ),
        ),
      ],
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.low});

  final bool low;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return SurfaceCard(
      color: colors.softLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(AppTexts.homeInviteTitle, style: text.h3),
          ),
          SizedBox(height: space.xxs),
          Text(
            low ? AppTexts.homeInviteLow : AppTexts.homeInviteNormal,
            style: text.small.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: space.sm),
          Wrap(
            spacing: space.xs,
            runSpacing: space.xs,
            children: <Widget>[
              FilledButton(
                onPressed: () => context.go(AppRoutes.chat),
                child: const Text(AppTexts.homeInviteChat),
              ),
              OutlinedButton(
                onPressed: () => context.push<void>(AppRoutes.companion),
                child: const Text(AppTexts.homeInviteCompanion),
              ),
            ],
          ),
        ],
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
      child: Material(
        color: colors.primary,
        borderRadius: RbRadius.cardBorder,
        child: InkWell(
          onTap: () => context.go(AppRoutes.chat),
          borderRadius: RbRadius.cardBorder,
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
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) > RbSize.homeRowMaxTextScale;

    final breathing = _ShortcutTile(
      title: AppTexts.homeBreathingTitle,
      subtitle: AppTexts.homeBreathingSubtitle,
      onTap: () => context.push<void>(AppRoutes.breathing),
    );
    final companion = _ShortcutTile(
      title: AppTexts.homeCompanionTitle,
      subtitle: AppTexts.homeCompanionSubtitle,
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

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$title. $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: RbRadius.cardBorder,
        child: SurfaceCard(
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
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;

    return SurfaceCard(
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
