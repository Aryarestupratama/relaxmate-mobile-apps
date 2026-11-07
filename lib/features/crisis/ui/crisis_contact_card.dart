import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/launch/web_launcher.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/crisis/data/crisis_contact.dart';
import 'package:relaxmate/features/crisis/ui/crisis_call_button.dart';

/// Kartu satu kontak bantuan: nama, keterangan, nomor, tombol "Telepon" dan "Buka situs".
class CrisisContactCard extends ConsumerWidget {
  const CrisisContactCard({required this.contact, super.key});

  final CrisisContact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final note = contact.note;
    final phone = contact.phone;
    final site = contact.url;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(space.md),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: RbRadius.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(contact.name, style: text.h3),
          if (note != null) ...<Widget>[
            SizedBox(height: space.xxs),
            Text(
              note,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
          ],
          if (phone != null) ...<Widget>[
            SizedBox(height: space.xxs),
            Text(phone, style: text.body),
          ],
          SizedBox(height: space.sm),
          Wrap(
            spacing: space.xs,
            runSpacing: space.xs,
            children: <Widget>[
              CrisisCallButton(contact: contact),
              if (site != null)
                OutlinedButton(
                  onPressed: () => _openSite(context, ref, site),
                  child: const Text(AppTexts.crisisOpenSite),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openSite(BuildContext context, WidgetRef ref, Uri site) async {
    final opened = await ref.read(webLauncherProvider).open(site);
    if (!opened && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text(AppTexts.webOpenFailed)),
      );
    }
  }
}
