import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/crisis/state/crisis_contacts_controller.dart';
import 'package:relaxmate/features/crisis/ui/crisis_contact_card.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// Daftar kartu kontak bantuan. Dipakai `CrisisContactsScreen` dan layar "Perbarui aplikasi"
/// (yang berada di luar router sehingga tidak bisa berpindah layar).
class CrisisContactsList extends ConsumerWidget {
  const CrisisContactsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.rbSpace;
    final contacts = ref.watch(crisisContactsProvider);

    return contacts.when(
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < list.length; i++) ...<Widget>[
            if (i > 0) SizedBox(height: space.sm),
            CrisisContactCard(contact: list[i]),
          ],
        ],
      ),
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(space.lg),
          child: const CircularProgressIndicator(
            semanticsLabel: AppTexts.loading,
          ),
        ),
      ),
      // Aset bawaan rusak: hampir mustahil, tetapi tetap beri jalan untuk mencoba lagi.
      error: (error, stackTrace) => ErrorAlert(
        message: AppTexts.errorGeneric,
        onRetry: () => ref.invalidate(crisisContactsProvider),
      ),
    );
  }
}
