import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/features/consent/data/consent_prompt.dart';
import 'package:relaxmate/features/consent/data/consent_repository.dart';
import 'package:relaxmate/features/consent/data/training_choice.dart';

/// Pilihan persetujuan pelatihan di Pengaturan (FR-M002: dapat diubah kapan saja). Membaca
/// teks dan pilihan tersimpan dari `GET /consent` (API-M008) lalu menyimpan perubahan lewat
/// API-M010. Teks tidak disalin di klien (RULE-049 web). Dibuang saat layar ditutup.
class TrainingConsentController extends AsyncNotifier<ConsentPrompt> {
  @override
  Future<ConsentPrompt> build() {
    return ref.read(consentRepositoryProvider).fetch();
  }

  /// Menyimpan [choice]. Galat dilempar (`ApiException`, pesannya aman ditampilkan) dan
  /// pilihan yang tampil tetap yang lama.
  Future<void> choose(TrainingChoice choice) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final saved = await ref.read(consentRepositoryProvider).setTraining(choice);
    if (ref.mounted) {
      state = AsyncData<ConsentPrompt>(current.withState(saved));
    }
  }
}

final AsyncNotifierProvider<TrainingConsentController, ConsentPrompt>
    trainingConsentControllerProvider =
    AsyncNotifierProvider.autoDispose<TrainingConsentController, ConsentPrompt>(
  TrainingConsentController.new,
);
