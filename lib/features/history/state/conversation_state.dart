import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// Keadaan layar detail hari (SCR-M15).
sealed class ConversationState {
  const ConversationState();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

/// Halaman pertama belum bisa dimuat (offline, timeout, tidak ditemukan, galat server).
class ConversationLoadFailed extends ConversationState {
  const ConversationLoadFailed(this.error);

  final ApiException error;
}

class ConversationReady extends ConversationState {
  const ConversationReady({
    required this.label,
    required this.hasCrisis,
    required this.messages,
    required this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  /// "6 November 2026, 14.30 WIB" dari server; kosong bila server tidak mengirimnya.
  final String label;
  final bool hasCrisis;

  /// Urut lama ke baru.
  final List<ChatMessage> messages;

  /// `null` bila seluruh percakapan sudah dimuat.
  final String? nextCursor;
  final bool loadingMore;

  /// Pesan galat ramah saat halaman berikutnya gagal; pesan yang sudah ada tetap tampil.
  final String? moreError;

  bool get hasMore => nextCursor != null;

  ConversationReady copyWith({
    List<ChatMessage>? messages,
    String? nextCursor,
    bool? loadingMore,
    String? moreError,
    bool clearMoreError = false,
  }) {
    return ConversationReady(
      label: label,
      hasCrisis: hasCrisis,
      messages: messages ?? this.messages,
      nextCursor: nextCursor ?? this.nextCursor,
      loadingMore: loadingMore ?? this.loadingMore,
      moreError: clearMoreError ? null : (moreError ?? this.moreError),
    );
  }
}
