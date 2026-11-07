import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/consent/state/consent_required_handler.dart';
import 'package:relaxmate/features/history/data/history_day.dart';
import 'package:relaxmate/features/history/data/history_repository.dart';
import 'package:relaxmate/features/history/state/history_state.dart';

/// Pemilik keadaan riwayat (FR-M005). Hanya baca; tidak mengulang otomatis (RULE-M044).
/// Provider dibuang saat layar ditutup, jadi isi riwayat tidak tertinggal di memori
/// (RULE-M031) dan selalu diambil segar dari server saat dibuka lagi.
class HistoryController extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    // Dijalankan setelah `build` selesai agar `state` sudah terpasang.
    unawaited(Future<void>.microtask(load));
    return const HistoryLoading();
  }

  HistoryRepository get _repository => ref.read(historyRepositoryProvider);

  /// Memuat halaman pertama. Juga dipakai tombol "Coba lagi" saat gagal dimuat.
  Future<void> load() async {
    state = const HistoryLoading();
    try {
      final page = await _repository.days();
      if (!ref.mounted) {
        return;
      }
      state = HistoryReady(days: page.days, nextCursor: page.nextCursor);
    } on ApiException catch (error) {
      if (!ref.mounted || invalidateIfConsentRequired(ref, error)) {
        return;
      }
      state = HistoryLoadFailed(error);
    }
  }

  /// Memuat halaman berikutnya (atas aksi pengguna). Gagal: daftar tetap, galat tampil di
  /// bawahnya dengan "Coba lagi".
  Future<void> loadMore() async {
    final current = state;
    final cursor = current is HistoryReady ? current.nextCursor : null;
    if (current is! HistoryReady || cursor == null || current.loadingMore) {
      return;
    }

    state = current.copyWith(loadingMore: true, clearMoreError: true);
    try {
      final page = await _repository.days(cursor: cursor);
      final now = state;
      if (!ref.mounted || now is! HistoryReady) {
        return;
      }
      final known = now.days.map((d) => d.id).toSet();
      final fresh =
          page.days.where((HistoryDay d) => !known.contains(d.id)).toList();
      state = HistoryReady(
        days: <HistoryDay>[...now.days, ...fresh],
        nextCursor: page.nextCursor,
      );
    } on ApiException catch (error) {
      final now = state;
      if (!ref.mounted || invalidateIfConsentRequired(ref, error)) {
        return;
      }
      if (now is HistoryReady) {
        state = now.copyWith(loadingMore: false, moreError: error.message);
      }
    }
  }
}

final NotifierProvider<HistoryController, HistoryState>
    historyControllerProvider =
    NotifierProvider.autoDispose<HistoryController, HistoryState>(
  HistoryController.new,
);
