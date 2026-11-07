import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/crisis/ui/crisis_contacts_list.dart';

/// SCR-M16: kontak bantuan. Terbuka untuk semua keadaan (tamu, belum verifikasi, belum
/// consent) dan bekerja tanpa internet (FR-M011, Design-M prinsip 4). Tidak dibungkus
/// `ConsentGate`.
class CrisisContactsScreen extends StatelessWidget {
  const CrisisContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.crisisContactsTitle)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(space.lg),
          children: <Widget>[
            Text(AppTexts.crisisContactsIntro, style: text.body),
            SizedBox(height: space.md),
            const CrisisContactsList(),
            SizedBox(height: space.md),
            Text(
              AppTexts.crisisContactsEmergency,
              style: text.small.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
