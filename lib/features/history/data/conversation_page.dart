import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// Satu halaman pesan satu Percakapan (`GET /relaxmate/conversations/{id}/messages`,
/// API-M016): hanya baca, urut lama ke baru, halaman berkursor.
class ConversationPage {
  const ConversationPage({
    required this.label,
    required this.hasCrisis,
    required this.messages,
    required this.nextCursor,
  });

  /// Teks siap tampil dari server, mis. "6 November 2026, 14.30 WIB".
  final String label;
  final bool hasCrisis;
  final List<ChatMessage> messages;

  /// Diteruskan apa adanya sebagai `?cursor=`; `null` bila tidak ada halaman berikutnya.
  final String? nextCursor;

  /// `null` bila bentuknya tidak sesuai kontrak (satu pesan rusak menolak seluruh halaman).
  static ConversationPage? tryParse(JsonMap json) {
    final conversation = json['conversation'];
    final raw = json['messages'];
    if (conversation is! JsonMap || raw is! List<Object?>) {
      return null;
    }
    final label = conversation['label'];
    final messages = <ChatMessage>[];
    for (final item in raw) {
      final message = ChatMessage.tryParse(item);
      if (message == null) {
        return null;
      }
      messages.add(message);
    }
    final cursor = json['next_cursor'];
    return ConversationPage(
      label: label is String ? label : '',
      hasCrisis: conversation['has_crisis'] == true,
      messages: messages,
      nextCursor: cursor is String && cursor.isNotEmpty ? cursor : null,
    );
  }
}
