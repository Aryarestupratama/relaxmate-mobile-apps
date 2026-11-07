import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/chat/data/chat_limits.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// Aliran percakapan hari ini (`GET /relaxmate/today`, API-M012).
class ChatDay {
  const ChatDay({
    required this.conversationId,
    required this.messages,
    required this.unanswered,
    required this.limits,
  });

  final String conversationId;
  final List<ChatMessage> messages;

  /// Pesan terakhir adalah pesan pengguna tanpa balasan (mis. AI gagal): tampilkan "Coba lagi".
  final bool unanswered;
  final ChatLimits limits;

  /// `null` bila bentuknya tidak sesuai kontrak (satu pesan rusak membuat seluruhnya ditolak).
  static ChatDay? tryParse(JsonMap json) {
    final conversation = json['conversation'];
    final rawMessages = json['messages'];
    final limits = ChatLimits.tryParse(json['limits']);
    if (conversation is! JsonMap ||
        rawMessages is! List<Object?> ||
        limits == null) {
      return null;
    }
    final id = conversation['id'];
    if (id is! String || id.isEmpty) {
      return null;
    }

    final messages = <ChatMessage>[];
    for (final raw in rawMessages) {
      final message = ChatMessage.tryParse(raw);
      if (message == null) {
        return null;
      }
      messages.add(message);
    }

    return ChatDay(
      conversationId: id,
      messages: messages,
      unanswered: json['unanswered'] == true,
      limits: limits,
    );
  }
}
