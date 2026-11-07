import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// Hasil `POST /relaxmate/conversations/{id}/messages` (API-M013), juga untuk `retry`.
class SendResult {
  const SendResult({
    required this.userMessage,
    required this.assistantMessage,
    required this.remainingToday,
  });

  final ChatMessage userMessage;
  final ChatMessage assistantMessage;
  final int remainingToday;

  /// `null` bila bentuknya tidak sesuai kontrak.
  static SendResult? tryParse(JsonMap json) {
    final user = ChatMessage.tryParse(json['user_message']);
    final assistant = ChatMessage.tryParse(json['assistant_message']);
    final remaining = json['remaining_today'];
    if (user == null || assistant == null || remaining is! int) {
      return null;
    }
    return SendResult(
      userMessage: user,
      assistantMessage: assistant,
      remainingToday: remaining,
    );
  }
}
