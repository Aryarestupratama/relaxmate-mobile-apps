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
import 'package:relaxmate/features/consent/data/consent_prompt.dart';
import 'package:relaxmate/features/consent/data/training_choice.dart';
import 'package:relaxmate/features/consent/ui/consent_choice_tile.dart';
import 'package:relaxmate/features/settings/state/settings_controller.dart';
import 'package:relaxmate/features/settings/state/training_consent_controller.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// SCR-M17: Pengaturan (FR-M025, FR-M003). Akun, pilihan persetujuan pelatihan (dari server,
/// dapat diubah kapan saja), getar latihan napas, lapisan privasi, tautan Privasi,
/// Ketentuan, dan Kontak bantuan, Keluar, serta Hapus akun. Hanya perlu masuk dengan email
/// terverifikasi; di luar `ConsentGate` supaya yang menolak consent tetap bisa keluar atau
/// menghapus akun. Suara dan maskot mengambang menyusul di task fiturnya.
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

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(space.lg),
          children: <Widget>[
            const _SectionTitle(AppTexts.settingsAccount),
            if (auth is AuthAuthenticated) ...<Widget>[
              Text(auth.user.name, style: text.body),
              Text(
                auth.user.email,
                style: text.small.copyWith(color: colors.textSecondary),
              ),
            ],
            SizedBox(height: space.lg),
            const _SectionTitle(AppTexts.settingsTraining),
            training.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ErrorAlert(
                    message: error is ApiException
                        ? error.message
                        : AppTexts.errorGeneric,
                  ),
                  SizedBox(height: space.xs),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(trainingConsentControllerProvider),
                    child: const Text(AppTexts.retry),
                  ),
                ],
              ),
              data: (prompt) => _TrainingChoice(
                prompt: prompt,
                saving: _savingTraining,
                onChoose: _choose,
              ),
            ),
            SizedBox(height: space.lg),
            const _SectionTitle(AppTexts.settingsPractice),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settings.breathingHaptics,
              onChanged: ref
                  .read(settingsControllerProvider.notifier)
                  .setBreathingHaptics,
              title: Text(AppTexts.breathingHaptics, style: text.body),
              subtitle: Text(
                AppTexts.breathingHapticsHint,
                style: text.small.copyWith(color: colors.textSecondary),
              ),
            ),
            SizedBox(height: space.lg),
            const _SectionTitle(AppTexts.settingsPrivacy),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settings.privacyCover,
              onChanged:
                  ref.read(settingsControllerProvider.notifier).setPrivacyCover,
              title: Text(AppTexts.settingsPrivacyCover, style: text.body),
              subtitle: Text(
                AppTexts.settingsPrivacyCoverHint,
                style: text.small.copyWith(color: colors.textSecondary),
              ),
            ),
            _LinkTile(
              icon: LucideIcons.shieldCheck,
              label: AppTexts.settingsPolicy,
              onTap: () => _openWeb(AppConstants.privacyPath),
            ),
            _LinkTile(
              icon: LucideIcons.fileText,
              label: AppTexts.settingsTerms,
              onTap: () => _openWeb(AppConstants.termsPath),
            ),
            _LinkTile(
              icon: LucideIcons.phone,
              label: AppTexts.settingsHelp,
              onTap: () => context.push<void>(AppRoutes.crisisContacts),
            ),
            SizedBox(height: space.lg),
            OutlinedButton(
              onPressed: _signingOut ? null : _logout,
              child: Text(
                _signingOut ? AppTexts.processing : AppTexts.logout,
              ),
            ),
            SizedBox(height: space.xs),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: colors.danger),
              onPressed: () => context.push<void>(AppRoutes.deleteAccount),
              child: const Text(AppTexts.settingsDeleteAccount),
            ),
            if (version != null) ...<Widget>[
              SizedBox(height: space.md),
              Center(
                child: Text(
                  AppTexts.settingsVersion(version),
                  style: text.caption.copyWith(color: colors.textMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.rbSpace.xs),
      child: Semantics(
        header: true,
        child: Text(title, style: context.rbText.h3),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label, style: context.rbText.body),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: onTap,
    );
  }
}

class _TrainingChoice extends StatelessWidget {
  const _TrainingChoice({
    required this.prompt,
    required this.saving,
    required this.onChoose,
  });

  final ConsentPrompt prompt;
  final bool saving;
  final ValueChanged<TrainingChoice> onChoose;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final current = prompt.state.trainingChoice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(prompt.trainingQuestion, style: text.body),
        SizedBox(height: space.xxs),
        Text(
          prompt.trainingText,
          style: text.small.copyWith(color: colors.textSecondary),
        ),
        SizedBox(height: space.sm),
        ConsentChoiceTile(
          label: AppTexts.consentTrainingYes,
          selected: current == TrainingChoice.granted,
          onTap: saving ? null : () => onChoose(TrainingChoice.granted),
        ),
        SizedBox(height: space.xs),
        ConsentChoiceTile(
          label: AppTexts.consentTrainingNo,
          selected: current == TrainingChoice.denied,
          onTap: saving ? null : () => onChoose(TrainingChoice.denied),
        ),
      ],
    );
  }
}
