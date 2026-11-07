import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/chat/state/chat_controller.dart';
import 'package:relaxmate/features/chat/state/send_outcome.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/data/mood_repository.dart';
import 'package:relaxmate/features/checkin/state/checkin_state.dart';

/// Pemilik alur Cek Rasa (FR-M013, OQ-M3): jawaban dikirim sebagai pesan chat biasa, lalu
/// dicatat sebagai Mood Entry (API-M018).
///
/// Urutan sengaja pesan dulu: bila pesan ditolak, tidak ada Mood Entry yang tertinggal dan
/// pengguna bisa mencoba lagi tanpa catatan ganda (batas harian entri terbatas). Bila pesan
/// sudah terkirim tetapi Mood Entry gagal, pesan tetap sah dan pengguna diberi tahu lewat
/// [CheckinState.notice]; tidak ada percobaan ulang otomatis (RULE-M044).
class CheckinController extends Notifier<CheckinState> {
  @override
  CheckinState build() => const CheckinState();

  void skip() {
    state = state.copyWith(skipped: true);
  }

  void clearNotice() {
    if (state.notice != null) {
      state = state.copyWith(clearNotice: true);
    }
  }

  Future<void> submit(MoodLevel level) async {
    if (state.submitting) {
      return;
    }
    state = state.copyWith(submitting: true, clearNotice: true);

    final outcome =
        await ref.read(chatControllerProvider.notifier).send(level.chatMessage);
    if (!ref.mounted) {
      return;
    }
    if (outcome == SendOutcome.rejected) {
      // Alasan penolakan sudah tampil di layar chat; kartu muncul lagi karena belum ada pesan.
      state = state.copyWith(submitting: false);
      return;
    }

    final notice = await _record(level);
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(
      submitting: false,
      notice: notice,
      clearNotice: notice == null,
    );
  }

  /// `null` bila tercatat; selain itu pesan untuk pengguna.
  Future<String?> _record(MoodLevel level) async {
    try {
      await ref.read(moodRepositoryProvider).record(level);
      return null;
    } on ApiException catch (error) {
      return error.hasCode('mood_limit_reached')
          ? error.message
          : AppTexts.checkinNotSaved;
    }
  }
}

final NotifierProvider<CheckinController, CheckinState>
    checkinControllerProvider =
    NotifierProvider.autoDispose<CheckinController, CheckinState>(
  CheckinController.new,
);
