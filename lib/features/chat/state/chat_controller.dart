import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/chat/data/chat_day.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';
import 'package:relaxmate/features/chat/data/chat_repository.dart';
import 'package:relaxmate/features/chat/data/send_result.dart';
import 'package:relaxmate/features/chat/state/chat_state.dart';
import 'package:relaxmate/features/chat/state/send_outcome.dart';
import 'package:relaxmate/features/consent/state/consent_controller.dart';

/// Pemilik keadaan chat harian (FR-M004, M006, M007). Tidak memuat isi pesan ke log dan tidak
/// mengulang otomatis: "Coba lagi" selalu atas aksi pengguna (RULE-M044).
///
/// Provider dibuang saat layar ditutup, jadi keadaan tidak terbawa antar pengguna.
class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    // Dijalankan setelah `build` selesai agar `state` sudah terpasang.
    unawaited(Future<void>.microtask(load));
    return const ChatLoading();
  }

  ChatRepository get _repository => ref.read(chatRepositoryProvider);

  /// Memuat aliran hari ini. Juga dipakai tombol "Coba lagi" saat gagal dimuat.
  Future<void> load() async {
    state = const ChatLoading();
    try {
      final day = await _repository.today();
      if (!ref.mounted) {
        return;
      }
      state = ChatReady.fromDay(day);
    } on ApiException catch (error) {
      if (!ref.mounted || _needsConsent(error)) {
        return;
      }
      state = ChatLoadFailed(error);
    }
  }

  /// Mengirim pesan. Pesan langsung tampil (tertunda) sambil menunggu balasan.
  Future<SendOutcome> send(String text) async {
    final current = state;
    final content = text.trim();
    if (current is! ChatReady || current.sending || content.isEmpty) {
      return SendOutcome.rejected;
    }

    state = current.copyWith(
      messages: <ChatMessage>[
        ...current.messages,
        ChatMessage.pending(content)
      ],
      sending: true,
      clearError: true,
    );

    try {
      final result = await _repository.send(current.conversationId, content);
      if (ref.mounted) {
        _applyReply(result);
      }
      return SendOutcome.accepted;
    } on ApiException catch (error) {
      if (!ref.mounted || _needsConsent(error)) {
        return SendOutcome.rejected;
      }
      return _afterSendFailure(error, content);
    }
  }

  /// Memanggil ulang balasan untuk pesan pengguna terakhir yang belum dijawab.
  Future<void> retry() async {
    final current = state;
    if (current is! ChatReady || current.sending) {
      return;
    }

    state = current.copyWith(sending: true, clearError: true);

    try {
      final result = await _repository.retry(current.conversationId);
      if (ref.mounted) {
        _applyReply(result);
      }
    } on ApiException catch (error) {
      if (!ref.mounted || _needsConsent(error)) {
        return;
      }
      final stale = error.hasCode('nothing_to_retry') ||
          error.hasCode('conversation_closed');
      if (stale && await _resync(error.message) != null) {
        return;
      }
      final now = state;
      if (ref.mounted && now is ChatReady) {
        state = now.copyWith(sending: false, error: error.message);
      }
    }
  }

  void _applyReply(SendResult result) {
    final now = state;
    if (now is! ChatReady) {
      return;
    }
    final kept = now.messages.where(
      (m) =>
          !m.isPending &&
          m.id != result.userMessage.id &&
          m.id != result.assistantMessage.id,
    );
    state = now.copyWith(
      messages: <ChatMessage>[
        ...kept,
        result.userMessage,
        result.assistantMessage,
      ],
      limits: now.limits.withRemaining(result.remainingToday),
      unanswered: false,
      sending: false,
      clearError: true,
    );
  }

  Future<SendOutcome> _afterSendFailure(
    ApiException error,
    String content,
  ) async {
    final closed = error.hasCode('conversation_closed');
    final maybeStored = switch (error.kind) {
      ApiErrorKind.timeout ||
      ApiErrorKind.server ||
      ApiErrorKind.unknown =>
        true,
      _ => false,
    };

    if (closed || maybeStored) {
      // Cocokkan dengan server: pesan mungkin sudah tersimpan walau balasannya gagal.
      final day = await _resync(error.message);
      if (day != null) {
        return !closed && _holds(day, content)
            ? SendOutcome.kept
            : SendOutcome.rejected;
      }
      if (!ref.mounted) {
        return SendOutcome.rejected;
      }
      if (!closed) {
        // Tidak bisa disinkronkan: pesan tetap tampil dengan "Coba lagi".
        final now = state;
        if (now is ChatReady) {
          state = now.copyWith(
            unanswered: true,
            sending: false,
            error: error.message,
          );
        }
        return SendOutcome.kept;
      }
    }

    _dropPending(error);
    return SendOutcome.rejected;
  }

  /// Pesan ditolak sebelum tersimpan: hapus gelembung tertunda dan tampilkan alasannya.
  void _dropPending(ApiException error) {
    final now = state;
    if (now is! ChatReady) {
      return;
    }
    state = now.copyWith(
      messages: now.messages.where((m) => !m.isPending).toList(),
      limits: error.hasCode('daily_limit')
          ? now.limits.withRemaining(0)
          : now.limits,
      sending: false,
      error: error.message,
    );
  }

  /// Memuat ulang hari ini dengan pesan galat. `null` bila gagal.
  Future<ChatDay?> _resync(String message) async {
    try {
      final day = await _repository.today();
      if (!ref.mounted) {
        return null;
      }
      state = ChatReady.fromDay(day, error: message);
      return day;
    } on ApiException catch (error) {
      if (ref.mounted) {
        _needsConsent(error);
      }
      return null;
    }
  }

  /// Pesan pengguna ini ada di dua pesan terakhir menurut server.
  bool _holds(ChatDay day, String content) {
    final tail = day.messages.length > 2
        ? day.messages.sublist(day.messages.length - 2)
        : day.messages;
    return tail.any((m) => m.role == ChatRole.user && m.content == content);
  }

  /// 403 `consent_required`: versi consent dinaikkan saat aplikasi terbuka. Gerbang consent
  /// memeriksa ulang dan menampilkan layar consent.
  bool _needsConsent(ApiException error) {
    if (!error.hasCode('consent_required')) {
      return false;
    }
    ref.invalidate(consentControllerProvider);
    return true;
  }
}

final NotifierProvider<ChatController, ChatState> chatControllerProvider =
    NotifierProvider.autoDispose<ChatController, ChatState>(
  ChatController.new,
);
