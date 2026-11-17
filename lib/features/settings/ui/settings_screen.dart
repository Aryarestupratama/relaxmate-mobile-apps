import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/launch/web_launcher.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/consent/data/training_choice.dart';
import 'package:relaxmate/features/overlay/state/overlay_feature_provider.dart';
import 'package:relaxmate/features/settings/data/chat_view_mode.dart';
import 'package:relaxmate/features/settings/state/settings_controller.dart';
import 'package:relaxmate/features/settings/state/training_consent_controller.dart';
import 'package:relaxmate/features/settings/ui/settings_group.dart';
import 'package:relaxmate/features/settings/ui/settings_link_row.dart';
import 'package:relaxmate/features/settings/ui/settings_profile_card.dart';
import 'package:relaxmate/features/settings/ui/settings_section_title.dart';
import 'package:relaxmate/features/settings/ui/settings_switch_row.dart';
import 'package:relaxmate/features/settings/ui/settings_training_card.dart';
import 'package:relaxmate/shared/widgets/app_bottom_nav.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';
import 'package:relaxmate/shared/widgets/rb_app_bar.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';
import 'package:relaxmate/shared/widgets/tab_back_scope.dart';

/// SCR-M17: Pengaturan (FR-M025, FR-M003), tab kelima navigasi bawah dengan `RbAppBar.root`
/// dan latar gradien lembut seperti tab lain. Sejak TASK-M073 bagian 9 isinya berupa kartu
/// melayang bergrup: kartu akun, persetujuan pelatihan, Tampilan dan latihan (maskot di chat,
/// getar napas, maskot mengambang), Privasi (lapisan privasi, Kebijakan Privasi, Ketentuan),
/// Tentang dan bantuan, lalu Keluar, Hapus akun, dan versi. Perilaku tidak berubah dari
/// versi sebelumnya. Hanya perlu masuk dengan email terverifikasi; di luar `ConsentGate`
/// supaya yang menolak consent tetap bisa keluar atau menghapus akun. Gerak hanya masuk
/// berurutan sekali (`RbEntrance`).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _savingTraining = false;
  bool _signingOut = false;

  void _snack(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _choose(TrainingChoice choice) async {
    setState(() => _savingTraining = true);
    try {
      await ref.read(trainingConsentControllerProvider.notifier).choose(choice);
      if (mounted) {
        _snack(AppTexts.settingsTrainingSaved);
      }
    } on ApiException catch (error) {
      if (mounted) {
        _snack(error.fieldErrors['choice'] ?? error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _savingTraining = false);
      }
    }
  }

  Future<void> _openWeb(String path) async {
    final uri = ref.read(appConfigProvider).webUri(path);
    final opened = await ref.read(webLauncherProvider).open(uri);
    if (!opened && mounted) {
      _snack(AppTexts.webOpenFailed);
    }
  }

  Future<void> _logout() async {
    setState(() => _signingOut = true);
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final auth = ref.watch(authControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final version = ref.watch(appVersionProvider).value;
    final training = ref.watch(trainingConsentControllerProvider);
    final showOverlay = defaultTargetPlatform == TargetPlatform.android &&
        (ref.watch(overlayFeatureProvider).value ?? true);

    return TabBackScope(
      child: Scaffold(
        backgroundColor: colors.pageBg,
        extendBodyBehindAppBar: true,
        appBar: const RbAppBar.root(title: AppTexts.settingsTitle),
        bottomNavigationBar: const AppBottomNav(current: AppTab.settings),
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
                if (auth is AuthAuthenticated) ...<Widget>[
                  RbEntrance(
                    child: SettingsProfileCard(
                      name: auth.user.name,
                      email: auth.user.email,
                    ),
                  ),
                  SizedBox(height: space.lg),
                ],
                RbEntrance(
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SettingsSectionTitle(AppTexts.settingsTraining),
                      training.when(
                        loading: () => const FloatingCard(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => FloatingCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ErrorAlert(
                                message: error is ApiException
                                    ? error.message
                                    : AppTexts.errorGeneric,
                              ),
                              SizedBox(height: space.xs),
                              TextButton(
                                onPressed: () => ref.invalidate(
                                  trainingConsentControllerProvider,
                                ),
                                child: const Text(AppTexts.retry),
                              ),
                            ],
                          ),
                        ),
                        data: (prompt) => SettingsTrainingCard(
                          prompt: prompt,
                          saving: _savingTraining,
                          onChoose: _choose,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: space.lg),
                RbEntrance(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SettingsSectionTitle(AppTexts.settingsPreferences),
                      SettingsGroup(
                        children: <Widget>[
                          SettingsSwitchRow(
                            icon: LucideIcons.messageCircle,
                            tint: colors.mood2,
                            title: AppTexts.settingsChatMascotMode,
                            subtitle: AppTexts.settingsChatMascotModeHint,
                            value: settings.chatViewMode == ChatViewMode.mascot,
                            onChanged: (enabled) => ref
                                .read(settingsControllerProvider.notifier)
                                .setChatViewMode(
                                  enabled
                                      ? ChatViewMode.mascot
                                      : ChatViewMode.conversation,
                                ),
                          ),
                          SettingsSwitchRow(
                            icon: LucideIcons.wind,
                            tint: colors.mood2,
                            title: AppTexts.breathingHaptics,
                            subtitle: AppTexts.breathingHapticsHint,
                            value: settings.breathingHaptics,
                            onChanged: ref
                                .read(settingsControllerProvider.notifier)
                                .setBreathingHaptics,
                          ),
                          if (showOverlay)
                            SettingsLinkRow(
                              icon: LucideIcons.heartHandshake,
                              tint: colors.mood2,
                              label: AppTexts.overlayTitle,
                              onTap: () =>
                                  context.push<void>(AppRoutes.overlaySettings),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: space.lg),
                RbEntrance(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SettingsSectionTitle(AppTexts.settingsPrivacy),
                      SettingsGroup(
                        children: <Widget>[
                          SettingsSwitchRow(
                            icon: LucideIcons.eye,
                            tint: colors.softLavender,
                            title: AppTexts.settingsPrivacyCover,
                            subtitle: AppTexts.settingsPrivacyCoverHint,
                            value: settings.privacyCover,
                            onChanged: ref
                                .read(settingsControllerProvider.notifier)
                                .setPrivacyCover,
                          ),
                          SettingsLinkRow(
                            icon: LucideIcons.shieldCheck,
                            tint: colors.softLavender,
                            label: AppTexts.settingsPolicy,
                            onTap: () => _openWeb(AppConstants.privacyPath),
                          ),
                          SettingsLinkRow(
                            icon: LucideIcons.fileText,
                            tint: colors.softLavender,
                            label: AppTexts.settingsTerms,
                            onTap: () => _openWeb(AppConstants.termsPath),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: space.lg),
                RbEntrance(
                  index: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SettingsSectionTitle(AppTexts.settingsInfo),
                      SettingsGroup(
                        children: <Widget>[
                          SettingsLinkRow(
                            icon: LucideIcons.smile,
                            tint: colors.mood1,
                            label: AppTexts.settingsAbout,
                            onTap: () => context.push<void>(AppRoutes.about),
                          ),
                          SettingsLinkRow(
                            icon: LucideIcons.phone,
                            tint: colors.mood3,
                            label: AppTexts.settingsHelp,
                            onTap: () =>
                                context.push<void>(AppRoutes.crisisContacts),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: space.xl),
                RbEntrance(
                  index: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      OutlinedButton(
                        onPressed: _signingOut ? null : _logout,
                        child: Text(
                          _signingOut ? AppTexts.processing : AppTexts.logout,
                        ),
                      ),
                      SizedBox(height: space.xs),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: colors.danger,
                        ),
                        onPressed: () =>
                            context.push<void>(AppRoutes.deleteAccount),
                        child: const Text(AppTexts.settingsDeleteAccount),
                      ),
                      if (version != null) ...<Widget>[
                        SizedBox(height: space.sm),
                        Center(
                          child: Text(
                            AppTexts.settingsVersion(version),
                            style: text.caption.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
