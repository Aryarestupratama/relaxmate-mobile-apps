import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/launch/web_launcher.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// SCR-M21: Tentang RelaxBoss (FR-M028). Menjelaskan bahwa RelaxMate bagian dari RelaxBoss:
/// kisah awal, visi, arti nama, kolaborasi kampus, penegasan bukan diagnosis, dan tautan ke
/// situs serta Instagram. Teks tetap (tanpa jaringan) dan mengikuti halaman Tentang di situs;
/// daftar tim dan acara tetap di situs.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, Uri uri) async {
    final opened = await ref.read(webLauncherProvider).open(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(AppTexts.webOpenFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final config = ref.watch(appConfigProvider);
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.aboutTitle)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(space.lg),
          children: <Widget>[
            const Center(child: MateAvatar(size: MateAvatarSize.large)),
            SizedBox(height: space.md),
            Semantics(
              header: true,
              child: Text(
                AppTexts.aboutHeadline,
                style: text.h2,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: space.sm),
            Text(AppTexts.aboutIntro, style: text.body),
            SizedBox(height: space.lg),
            const _Section(
              title: AppTexts.aboutStoryTitle,
              body: AppTexts.aboutStoryBody,
            ),
            const _Section(
              title: AppTexts.aboutVisionTitle,
              body: AppTexts.aboutVisionBody,
            ),
            Semantics(
              header: true,
              child: Text(AppTexts.aboutNameTitle, style: text.h3),
            ),
            SizedBox(height: space.xs),
            const _NameCard(
              name: AppTexts.aboutNameRelax,
              meaning: AppTexts.aboutNameRelaxBody,
            ),
            SizedBox(height: space.xs),
            const _NameCard(
              name: AppTexts.aboutNameBoss,
              meaning: AppTexts.aboutNameBossBody,
            ),
            SizedBox(height: space.lg),
            const _Section(
              title: AppTexts.aboutCampusTitle,
              body: AppTexts.aboutCampusBody,
            ),
            Container(
              padding: EdgeInsets.all(space.md),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: RbRadius.cardBorder,
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(AppTexts.aboutSafeTitle, style: text.h3),
                  ),
                  SizedBox(height: space.xs),
                  Text(
                    AppTexts.aboutSafeBody,
                    style: text.small.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: space.sm),
                  OutlinedButton(
                    onPressed: () =>
                        context.push<void>(AppRoutes.crisisContacts),
                    child: const Text(AppTexts.aboutHelpButton),
                  ),
                ],
              ),
            ),
            SizedBox(height: space.lg),
            Semantics(
              header: true,
              child: Text(AppTexts.aboutLinksTitle, style: text.h3),
            ),
            _LinkRow(
              label: AppTexts.aboutWebsite,
              onTap: () => _open(
                context,
                ref,
                config.webUri(AppConstants.homeWebPath),
              ),
            ),
            _LinkRow(
              label: AppTexts.aboutWebsiteFull,
              onTap: () => _open(
                context,
                ref,
                config.webUri(AppConstants.aboutWebPath),
              ),
            ),
            _LinkRow(
              label: AppTexts.aboutInstagram,
              onTap: () => _open(
                context,
                ref,
                Uri.parse(AppConstants.instagramUrl),
              ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final text = context.rbText;

    return Padding(
      padding: EdgeInsets.only(bottom: space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(header: true, child: Text(title, style: text.h3)),
          SizedBox(height: space.xs),
          Text(
            body,
            style: text.small.copyWith(color: context.rbColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  const _NameCard({required this.name, required this.meaning});

  final String name;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Container(
      padding: EdgeInsets.all(space.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: RbRadius.cardBorder,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name, style: text.h3.copyWith(color: colors.primary)),
          SizedBox(width: space.md),
          Expanded(
            child: Text(
              meaning,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: context.rbText.body),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: onTap,
    );
  }
}
