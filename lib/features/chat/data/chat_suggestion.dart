import 'package:relaxmate/core/api/json_map.dart';

/// Jenis saran tindakan dari server (`suggestion.type`, enum `SuggestionType` di backend).
/// Nilai yang tidak dikenal diabaikan (Architecture-M bagian 5), jadi server boleh menambah
/// jenis baru tanpa merusak aplikasi lama.
enum SuggestionKind {
  escalateCrisis('escalate_crisis'),
  recommendProfessional('recommend_professional'),
  recommendSupport('recommend_support');

  const SuggestionKind(this.wireValue);

  final String wireValue;

  static SuggestionKind? fromWire(Object? value) {
    for (final kind in SuggestionKind.values) {
      if (kind.wireValue == value) {
        return kind;
      }
    }
    return null;
  }
}

/// Saran tindakan pada satu balasan RelaxMate (FR-M008).
class ChatSuggestion {
  const ChatSuggestion({
    required this.kind,
    required this.priority,
    required this.dismissible,
  });

  final SuggestionKind kind;

  /// 1 = paling mendesak (krisis). Prioritas 1 selalu tampil dan tidak bisa ditutup.
  final int priority;
  final bool dismissible;

  bool get isUrgent => priority == 1;

  /// `null` bila tidak ada saran atau jenisnya tidak dikenal.
  static ChatSuggestion? tryParse(Object? value) {
    if (value is! JsonMap) {
      return null;
    }
    final kind = SuggestionKind.fromWire(value['type']);
    final priority = value['priority'];
    if (kind == null || priority is! int) {
      return null;
    }
    return ChatSuggestion(
      kind: kind,
      priority: priority,
      // Saran krisis tidak pernah dapat ditutup, apa pun kata server (Design-M CMP-M05).
      dismissible: kind != SuggestionKind.escalateCrisis &&
          value['dismissible'] != false,
    );
  }
}
