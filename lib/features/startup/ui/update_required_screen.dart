import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/startup/data/store_launcher.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// SCR-M20: layar "Perbarui aplikasi" saat versi terpasang terlalu lama.
/// TODO(TASK-M025): tambahkan tautan Kontak bantuan di layar ini
/// (bantuan nyata tidak boleh tersembunyi, Design-M prinsip 4).
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(space.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const MateAvatar(size: MateAvatarSize.large),
                SizedBox(height: space.md),
                Semantics(
                  header: true,
                  child: Text(
                    AppTexts.updateTitle,
                    textAlign: TextAlign.center,
                    style: text.h2,
                  ),
                ),
                SizedBox(height: space.xs),
                Text(
                  AppTexts.updateBody,
                  textAlign: TextAlign.center,
                  style: text.body.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: space.lg),
                FilledButton(
                  onPressed: () => _openStore(context, ref),
                  child: const Text(AppTexts.updateAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context, WidgetRef ref) async {
    final opened = await ref.read(storeLauncherProvider).openStore();
    if (!opened && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(AppTexts.storeOpenFailed)),
      );
    }
  }
}
