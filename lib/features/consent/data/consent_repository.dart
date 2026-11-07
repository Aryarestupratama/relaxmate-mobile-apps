import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/consent/data/consent_prompt.dart';
import 'package:relaxmate/features/consent/data/consent_state.dart';
import 'package:relaxmate/features/consent/data/training_choice.dart';

/// API-M008 sampai M010: teks dan status consent, persetujuan AI, dan pilihan pelatihan.
/// Semua panggilan lewat `ApiClient` (RULE-M022). Validasi sebenarnya di server (RULE-M023).
class ConsentRepository {
  const ConsentRepository(this._api);

  final ApiClient _api;

  /// API-M008. Boleh dibaca akun yang belum terverifikasi.
  Future<ConsentPrompt> fetch() async {
    final json = await _api.get('/consent');
    final prompt = ConsentPrompt.tryParse(json);
    if (prompt == null) {
      throw _malformed();
    }
    return prompt;
  }

  /// API-M009: mencatat consent AI versi terbaru (idempoten, tanpa badan permintaan).
  Future<ConsentState> grantAi() async {
    final json = await _api.post('/relaxmate/consent');
    return _parseState(json['consent']);
  }

  /// API-M010: mencatat pilihan pelatihan. Dapat diubah kapan saja.
  Future<ConsentState> setTraining(TrainingChoice choice) async {
    final json = await _api.post(
      '/account/training-consent',
      body: <String, Object?>{'choice': choice.wireValue},
    );
    return _parseState(json['consent']);
  }

  ConsentState _parseState(Object? value) {
    final state = ConsentState.tryParse(value);
    if (state == null) {
      throw _malformed();
    }
    return state;
  }

  /// Bentuk balasan tidak sesuai kontrak: tampilkan galat umum, tanpa detail.
  ApiException _malformed() {
    return const ApiException(
      kind: ApiErrorKind.unknown,
      message: AppTexts.errorGeneric,
    );
  }
}

final Provider<ConsentRepository> consentRepositoryProvider =
    Provider<ConsentRepository>(
  (ref) => ConsentRepository(ref.watch(apiClientProvider)),
);
