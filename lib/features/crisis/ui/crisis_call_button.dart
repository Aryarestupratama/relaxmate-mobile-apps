import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/launch/web_launcher.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/crisis/data/crisis_contact.dart';

/// Tombol telepon langsung (`tel:`) untuk satu kontak bantuan (FR-M010). Bila perangkat
/// tidak bisa memulai panggilan (mis. tablet tanpa telepon), nomornya ditampilkan di `Snack`
/// supaya tetap bisa dihubungi lewat cara lain. Tidak tampil bila kontak tanpa nomor.
class CrisisCallButton extends ConsumerWidget {
  const CrisisCallButton({
    required this.contact,
    this.label = AppTexts.crisisCall,
    this.style,
    super.key,
  });

  final CrisisContact contact;
  final String label;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tel = contact.telUri;
    if (tel == null) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: AppTexts.crisisCallContact(contact.name),
      child: FilledButton.icon(
        style: style,
        onPressed: () => _dial(context, ref, tel),
        icon: const Icon(LucideIcons.phone),
        label: Text(label),
      ),
    );
  }

  Future<void> _dial(BuildContext context, WidgetRef ref, Uri tel) async {
    final opened = await ref.read(webLauncherProvider).open(tel);
    if (!opened && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(AppTexts.crisisCallFailed(contact.phone ?? '')),
        ),
      );
    }
  }
}
