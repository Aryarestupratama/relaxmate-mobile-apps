import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/history/data/history_day.dart';

/// Keadaan layar riwayat (SCR-M14).
sealed class HistoryState {
  const HistoryState();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Halaman pertama belum bisa dimuat (offline, timeout, galat server).
class HistoryLoadFailed extends HistoryState {
  const HistoryLoadFailed(this.error);

  final ApiException error;
}

class HistoryReady extends HistoryState {
  const HistoryReady({
    required this.days,
    required this.nextCursor,
    this.loadingMore = false,
    this.moreError,
  });

  /// Terbaru dulu, sesuai urutan server.
  final List<HistoryDay> days;

  /// `null` bila seluruh riwayat sudah dimuat.
  final String? nextCursor;

  /// Halaman berikutnya sedang dimuat.
  final bool loadingMore;

  /// Pesan galat ramah saat halaman berikutnya gagal; daftar yang sudah ada tetap tampil.
  final String? moreError;

  bool get hasMore => nextCursor != null;

  HistoryReady copyWith({
    List<HistoryDay>? days,
    String? nextCursor,
    bool? loadingMore,
    String? moreError,
    bool clearMoreError = false,
  }) {
    return HistoryReady(
      days: days ?? this.days,
      nextCursor: nextCursor ?? this.nextCursor,
      loadingMore: loadingMore ?? this.loadingMore,
      moreError: clearMoreError ? null : (moreError ?? this.moreError),
    );
  }
}
