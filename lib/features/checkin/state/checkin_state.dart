/// Keadaan Cek Rasa di layar chat (SCR-M09). Hanya di memori.
class CheckinState {
  const CheckinState({
    this.skipped = false,
    this.submitting = false,
    this.notice,
  });

  /// Pengguna menekan "Lewati": kartu tidak ditawarkan lagi selama layar chat terbuka.
  final bool skipped;

  /// Jawaban sedang dikirim (tombol dinonaktifkan).
  final bool submitting;

  /// Pesan ramah satu kali, mis. mood belum tercatat padahal pesan sudah terkirim.
  final String? notice;

  CheckinState copyWith({
    bool? skipped,
    bool? submitting,
    String? notice,
    bool clearNotice = false,
  }) {
    return CheckinState(
      skipped: skipped ?? this.skipped,
      submitting: submitting ?? this.submitting,
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}
