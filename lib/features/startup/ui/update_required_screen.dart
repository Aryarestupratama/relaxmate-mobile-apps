import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/crisis/ui/crisis_contacts_list.dart';
import 'package:relaxmate/features/startup/data/store_launcher.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// SCR-M20: layar "Perbarui aplikasi" saat versi terpasang terlalu lama.
///
/// Layar ini berada di luar router (dipasang `StartupGate`), jadi kontak bantuan
/// ditampilkan di tempat, bukan lewat rute (Design-M prinsip 4, TASK-M025).
class UpdateRequiredScreen extends ConsumerStatefulWidget {
  const UpdateRequiredScreen({super.key});

  @override
  ConsumerState<UpdateRequiredScreen> createState() =>
      _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends ConsumerState<UpdateRequiredScreen> {
  bool _showHelp = false;

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _openStore,
                  child: const Text(AppTexts.updateAction),
                ),
                SizedBox(height: space.md),
                if (_showHelp)
                  const CrisisContactsList()
                else
                  TextButton(
                    onPressed: () => setState(() => _showHelp = true),
                    child: const Text(AppTexts.crisisNeedHelp),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final opened = await ref.read(storeLauncherProvider).openStore();
    if (!opened && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(AppTexts.storeOpenFailed)),
      );
    }
  }
}
