import 'package:relaxmate/features/chat/data/chat_suggestion.dart';

/// Tujuan yang bisa dibuka dari chip saran (FR-M008).
enum SuggestionDestination {
  /// Layar kontak bantuan di aplikasi (SCR-M16).
  crisisContacts,

  /// Halaman Konsultasi Profesional di website.
  consultation,

  /// Latihan napas lokal (SCR-M11).
  breathing,

  /// Grounding 5-4-3-2-1 lokal (SCR-M12).
  grounding;

  /// Tujuan yang belum dibangun tidak dijadikan chip.
  bool get isAvailable => switch (this) {
        crisisContacts || consultation => true,
        // TODO(TASK-M029): ubah menjadi true bersama layar latihan napas dan grounding.
        breathing || grounding => false,
      };
}

/// Peta `suggestion.type` ke tujuan, urut sesuai tampilan. Hanya tujuan yang sudah tersedia.
List<SuggestionDestination> destinationsFor(SuggestionKind kind) {
  final all = switch (kind) {
    SuggestionKind.escalateCrisis => const <SuggestionDestination>[
        SuggestionDestination.crisisContacts,
        SuggestionDestination.consultation,
      ],
    SuggestionKind.recommendProfessional => const <SuggestionDestination>[
        SuggestionDestination.consultation,
      ],
    SuggestionKind.recommendSupport => const <SuggestionDestination>[
        SuggestionDestination.breathing,
        SuggestionDestination.grounding,
      ],
  };
  return all.where((destination) => destination.isAvailable).toList();
}
