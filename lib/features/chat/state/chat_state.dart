import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/chat/data/chat_day.dart';
import 'package:relaxmate/features/chat/data/chat_limits.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// Keadaan layar chat harian (SCR-M08).
sealed class ChatState {
  const ChatState();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Aliran hari ini belum bisa dimuat (offline, timeout, galat server).
class ChatLoadFailed extends ChatState {
  const ChatLoadFailed(this.error);

  final ApiException error;
}

class ChatReady extends ChatState {
  const ChatReady({
    required this.conversationId,
    required this.messages,
    required this.limits,
    required this.unanswered,
    this.sending = false,
    this.error,
  });

  factory ChatReady.fromDay(ChatDay day, {String? error}) {
    return ChatReady(
      conversationId: day.conversationId,
      messages: day.messages,
      limits: day.limits,
      unanswered: day.unanswered,
      error: error,
    );
  }

  final String conversationId;

  /// Urut lama ke baru. Pesan tertunda (`isPending`) paling akhir bila ada.
  final List<ChatMessage> messages;
  final ChatLimits limits;

  /// Pesan terakhir pengguna belum dijawab: galat disertai "Coba lagi".
  final bool unanswered;

  /// Permintaan kirim atau ulang sedang berjalan (indikator "sedang menulis").
  final bool sending;

  /// Pesan galat ramah (aman ditampilkan); `null` bila tidak ada.
  final String? error;

  bool get limitReached => limits.remainingToday <= 0;

  ChatReady copyWith({
    List<ChatMessage>? messages,
    ChatLimits? limits,
    bool? unanswered,
    bool? sending,
    String? error,
    bool clearError = false,
  }) {
    return ChatReady(
      conversationId: conversationId,
      messages: messages ?? this.messages,
      limits: limits ?? this.limits,
      unanswered: unanswered ?? this.unanswered,
      sending: sending ?? this.sending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
