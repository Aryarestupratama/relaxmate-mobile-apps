import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/chat/data/chat_suggestion.dart';

enum ChatRole { user, assistant }

/// Satu pesan dalam aliran harian (objek `message` API-M012, M013, M016). Hanya kolom yang
/// dipakai layar chat yang dibaca; `intent` tidak dikirim server.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.time,
    this.isCrisis = false,
    this.suggestion,
  });

  /// Pesan pengguna yang baru dikirim dan belum dikonfirmasi server.
  const ChatMessage.pending(String content)
      : this(id: pendingId, role: ChatRole.user, content: content, time: '');

  static const int pendingId = -1;

  final int id;
  final ChatRole role;
  final String content;

  /// Teks waktu WIB siap tampil dari server (mis. "14.30 WIB"); kosong untuk pesan tertunda.
  final String time;

  /// Balasan Crisis Response (`is_crisis`): gelembung memakai warna krisis (CMP-M02).
  final bool isCrisis;

  /// Saran tindakan di bawah balasan RelaxMate (FR-M008); `null` bila tidak ada.
  final ChatSuggestion? suggestion;

  bool get isPending => id == pendingId;

  /// `null` bila bentuknya tidak sesuai kontrak.
  static ChatMessage? tryParse(Object? value) {
    if (value is! JsonMap) {
      return null;
    }
    final id = value['id'];
    final content = value['content'];
    final role = switch (value['role']) {
      'user' => ChatRole.user,
      'assistant' => ChatRole.assistant,
      _ => null,
    };
    if (id is! int || content is! String || role == null) {
      return null;
    }
    final time = value['time'];
    return ChatMessage(
      id: id,
      role: role,
      content: content,
      time: time is String ? time : '',
      isCrisis: value['is_crisis'] == true,
      suggestion: role == ChatRole.assistant
          ? ChatSuggestion.tryParse(value['suggestion'])
          : null,
    );
  }
}
