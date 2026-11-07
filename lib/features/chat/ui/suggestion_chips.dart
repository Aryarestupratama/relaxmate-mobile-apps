import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/launch/web_launcher.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_suggestion.dart';
import 'package:relaxmate/features/chat/data/suggestion_destination.dart';

/// CMP-M05: chip saran tindakan di bawah balasan RelaxMate (FR-M008). Satu chip per tujuan
/// (`destinationsFor`); gayanya mengikuti `OutlinedButton` tema (pil putih berbingkai navy).
/// Saran krisis tidak punya tombol tutup (FR-M010). Latihan napas dan grounding langsung
/// terbuka ke layar latihannya (tanpa lewat daftar latihan).
class SuggestionChips extends ConsumerWidget {
  const SuggestionChips({
    required this.suggestion,
    required this.onDismiss,
    super.key,
  });

  final ChatSuggestion suggestion;

  /// Dipanggil saat tombol tutup diketuk; hanya dipakai bila `suggestion.dismissible`.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.rbSpace;
    final destinations = destinationsFor(suggestion.kind);

    return Padding(
      padding: EdgeInsets.only(top: space.xxs, bottom: space.xs),
      child: Wrap(
        spacing: space.xs,
        runSpacing: space.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final destination in destinations)
            OutlinedButton.icon(
              onPressed: () => _open(context, ref, destination),
              icon: Icon(_iconFor(destination)),
              label: Text(_labelFor(destination)),
            ),
          if (suggestion.dismissible)
            IconButton(
              onPressed: onDismiss,
              tooltip: AppTexts.suggestionDismiss,
              icon: const Icon(LucideIcons.x),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(SuggestionDestination destination) {
    return switch (destination) {
      SuggestionDestination.crisisContacts => LucideIcons.phone,
      SuggestionDestination.consultation => LucideIcons.heartHandshake,
      SuggestionDestination.breathing => LucideIcons.wind,
      SuggestionDestination.grounding => LucideIcons.eye,
    };
  }

  String _labelFor(SuggestionDestination destination) {
    return switch (destination) {
      SuggestionDestination.crisisContacts => AppTexts.suggestionContacts,
      SuggestionDestination.consultation => AppTexts.suggestionConsultation,
      SuggestionDestination.breathing => AppTexts.breathingTitle,
      SuggestionDestination.grounding => AppTexts.groundingTitle,
    };
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    SuggestionDestination destination,
  ) async {
    switch (destination) {
      case SuggestionDestination.crisisContacts:
        await context.push<void>(AppRoutes.crisisContacts);
      case SuggestionDestination.consultation:
        final uri =
            ref.read(appConfigProvider).webUri(AppConstants.consultationPath);
        final opened = await ref.read(webLauncherProvider).open(uri);
        if (!opened && context.mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            const SnackBar(content: Text(AppTexts.webOpenFailed)),
          );
        }
      case SuggestionDestination.breathing:
        await context.push<void>(AppRoutes.breathing);
      case SuggestionDestination.grounding:
        await context.push<void>(AppRoutes.grounding);
    }
  }
}
