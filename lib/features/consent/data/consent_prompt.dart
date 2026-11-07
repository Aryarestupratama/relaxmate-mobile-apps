import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/consent/data/consent_state.dart';

/// Teks consent dari server (API-M008) beserta status pengguna. Teks tidak disalin di
/// klien agar sama dengan web (RULE-049 web, FR-M002).
class ConsentPrompt {
  const ConsentPrompt({
    required this.aiTitle,
    required this.aiText,
    required this.trainingQuestion,
    required this.trainingText,
    required this.state,
  });

  final String aiTitle;
  final String aiText;
  final String trainingQuestion;
  final String trainingText;
  final ConsentState state;

  /// `null` bila bentuknya tidak sesuai kontrak atau ada teks kosong: persetujuan tanpa
  /// teks tidak boleh diminta.
  static ConsentPrompt? tryParse(JsonMap json) {
    final ai = json['ai'];
    final training = json['training'];
    final state = ConsentState.tryParse(json['state']);
    if (ai is! JsonMap || training is! JsonMap || state == null) {
      return null;
    }

    final aiTitle = _text(ai['title']);
    final aiText = _text(ai['text']);
    final question = _text(training['question']);
    final trainingText = _text(training['text']);
    if (aiTitle.isEmpty ||
        aiText.isEmpty ||
        question.isEmpty ||
        trainingText.isEmpty) {
      return null;
    }

    return ConsentPrompt(
      aiTitle: aiTitle,
      aiText: aiText,
      trainingQuestion: question,
      trainingText: trainingText,
      state: state,
    );
  }

  /// Salinan dengan status baru (teks sama).
  ConsentPrompt withState(ConsentState next) {
    return ConsentPrompt(
      aiTitle: aiTitle,
      aiText: aiText,
      trainingQuestion: trainingQuestion,
      trainingText: trainingText,
      state: next,
    );
  }
}

String _text(Object? value) => value is String ? value.trim() : '';
