import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';
import 'package:relaxmate/features/consent/state/consent_required_handler.dart';
import 'package:relaxmate/features/history/data/history_repository.dart';
import 'package:relaxmate/features/history/state/conversation_state.dart';

/// Pemilik keadaan detail satu hari (FR-M005), hanya baca. Satu instance per Percakapan;
/// dibuang saat layar ditutup sehingga isi pesan tidak tertinggal di memori (RULE-M031).
class ConversationController extends Notifier<ConversationState> {
  ConversationController(this.conversationId);

  final String conversationId;

  @override
  ConversationState build() {
    // Dijalankan setelah `build` selesai agar `state` sudah terpasang.
    unawaited(Future<void>.microtask(load));
    return const ConversationLoading();
  }

  HistoryRepository get _repository => ref.read(historyRepositoryProvider);

  /// Memuat halaman pertama. Juga dipakai tombol "Coba lagi" saat gagal dimuat.
  Future<void> load() async {
    state = const ConversationLoading();
    try {
      final page = await _repository.messages(conversationId);
      if (!ref.mounted) {
        return;
      }
      state = ConversationReady(
        label: page.label,
        hasCrisis: page.hasCrisis,
        messages: page.messages,
        nextCursor: page.nextCursor,
      );
    } on ApiException catch (error) {
      if (!ref.mounted || invalidateIfConsentRequired(ref, error)) {
        return;
      }
      state = ConversationLoadFailed(error);
    }
  }

  /// Memuat pesan berikutnya (atas aksi pengguna). Gagal: pesan tetap, galat tampil di
  /// bawahnya dengan "Coba lagi".
  Future<void> loadMore() async {
    final current = state;
    final cursor = current is ConversationReady ? current.nextCursor : null;
    if (current is! ConversationReady ||
        cursor == null ||
        current.loadingMore) {
      return;
    }

    state = current.copyWith(loadingMore: true, clearMoreError: true);
    try {
      final page = await _repository.messages(conversationId, cursor: cursor);
      final now = state;
      if (!ref.mounted || now is! ConversationReady) {
        return;
      }
      final known = now.messages.map((m) => m.id).toSet();
      final fresh =
          page.messages.where((ChatMessage m) => !known.contains(m.id));
      state = ConversationReady(
        label: now.label,
        hasCrisis: now.hasCrisis || page.hasCrisis,
        messages: <ChatMessage>[...now.messages, ...fresh],
        nextCursor: page.nextCursor,
      );
    } on ApiException catch (error) {
      final now = state;
      if (!ref.mounted || invalidateIfConsentRequired(ref, error)) {
        return;
      }
      if (now is ConversationReady) {
        state = now.copyWith(loadingMore: false, moreError: error.message);
      }
    }
  }
}

final conversationControllerProvider = NotifierProvider.autoDispose
    .family<ConversationController, ConversationState, String>(
  ConversationController.new,
);
