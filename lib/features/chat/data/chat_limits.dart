import 'package:relaxmate/core/api/json_map.dart';

/// Batas beban dari server (`limits` pada API-M012). Nilainya tidak ditulis di klien
/// (RULE-M026).
class ChatLimits {
  const ChatLimits({
    required this.messageMaxChars,
    required this.perDay,
    required this.remainingToday,
  });

  final int messageMaxChars;
  final int perDay;
  final int remainingToday;

  ChatLimits withRemaining(int remaining) {
    return ChatLimits(
      messageMaxChars: messageMaxChars,
      perDay: perDay,
      remainingToday: remaining < 0 ? 0 : remaining,
    );
  }

  /// `null` bila bentuknya tidak sesuai kontrak.
  static ChatLimits? tryParse(Object? value) {
    if (value is! JsonMap) {
      return null;
    }
    final maxChars = value['message_max_chars'];
    final perDay = value['per_day'];
    final remaining = value['remaining_today'];
    if (maxChars is! int || perDay is! int || remaining is! int) {
      return null;
    }
    return ChatLimits(
      messageMaxChars: maxChars,
      perDay: perDay,
      remainingToday: remaining,
    );
  }
}
