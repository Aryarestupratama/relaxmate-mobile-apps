import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/crisis/data/crisis_contact.dart';
import 'package:relaxmate/features/crisis/state/crisis_contacts_controller.dart';
import 'package:relaxmate/features/crisis/ui/crisis_call_button.dart';

/// CMP-M04: banner Crisis Response. Menempel di atas daftar pesan selama Percakapan hari
/// itu dan tidak dapat ditutup (FR-M010). Teksnya tetap (bukan keluaran AI) dan kontaknya
/// dari perangkat, jadi tampil juga tanpa internet (FR-M011, RULE-M034). Tombol "Lihat
/// semua kontak bantuan" selalu ada, walau daftar kontak belum termuat.
class CrisisBanner extends ConsumerWidget {
  const CrisisBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    final contacts = ref.watch(crisisContactsProvider).when(
          data: (list) => list,
          loading: () => const <CrisisContact>[],
          error: (error, stackTrace) => const <CrisisContact>[],
        );
    final callable = contacts
        .where((contact) => contact.telUri != null)
        .take(AppConstants.crisisBannerMaxContacts)
        .toList();

    final callStyle = FilledButton.styleFrom(
      backgroundColor: colors.crisisText,
      foregroundColor: colors.crisisBg,
    );

    final maxHeight =
        MediaQuery.sizeOf(context).height * RbSize.crisisBannerMaxHeightFactor;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: colors.crisisBg,
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  AppTexts.crisisBannerTitle,
                  style: text.h3.copyWith(color: colors.crisisText),
                ),
              ),
              SizedBox(height: space.xxs),
              Text(
                AppTexts.crisisBannerBody,
                style: text.small.copyWith(color: colors.crisisText),
              ),
              SizedBox(height: space.sm),
              Wrap(
                spacing: space.xs,
                runSpacing: space.xs,
                children: <Widget>[
                  for (final contact in callable)
                    CrisisCallButton(
                      contact: contact,
                      label: AppTexts.crisisCallContact(contact.name),
                      style: callStyle,
                    ),
                ],
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: colors.crisisText),
                onPressed: () => context.push(AppRoutes.crisisContacts),
                child: const Text(AppTexts.crisisSeeAll),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
