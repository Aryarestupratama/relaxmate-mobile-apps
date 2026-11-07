import 'package:relaxmate/features/chat/data/chat_message.dart';
import 'package:relaxmate/features/chat/data/suggestion_destination.dart';

/// Id pesan yang saran tindakannya ditampilkan (aturan sama dengan web, FR-029): saran
/// mendesak (prioritas 1) selalu tampil; saran lain hanya pada balasan RelaxMate terakhir.
/// Saran yang sudah ditutup pengguna, atau yang belum punya tujuan tersedia, tidak tampil.
Set<int> visibleSuggestionIds(List<ChatMessage> messages, Set<int> dismissed) {
  int? lastAssistantId;
  for (final message in messages) {
    if (message.role == ChatRole.assistant) {
      lastAssistantId = message.id;
    }
  }

  final visible = <int>{};
  for (final message in messages) {
    final suggestion = message.suggestion;
    if (suggestion == null || dismissed.contains(message.id)) {
      continue;
    }
    if (destinationsFor(suggestion.kind).isEmpty) {
      continue;
    }
    if (suggestion.isUrgent || message.id == lastAssistantId) {
      visible.add(message.id);
    }
  }
  return visible;
}
