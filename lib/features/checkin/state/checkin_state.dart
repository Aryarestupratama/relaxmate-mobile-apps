import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/mood/data/mood_today.dart';

/// Keadaan kartu mood di Beranda (SCR-M22, FR-M013). Hanya di memori.
class CheckinState {
  const CheckinState({
    this.submittingLevel,
    this.editing = false,
    this.recorded,
    this.error,
  });

  /// Tingkat yang sedang dikirim (tombol dinonaktifkan, blob tampil terpilih).
  final MoodLevel? submittingLevel;

  /// Pengguna menekan "Ubah": kartu menampilkan pilihan lagi.
  final bool editing;

  /// Catatan yang baru dibuat sesi ini; lebih cepat tampil daripada menunggu deret dimuat ulang.
  final MoodToday? recorded;

  /// Pesan ramah satu kali di kartu, mis. batas harian atau gagal terhubung.
  final String? error;

  bool get submitting => submittingLevel != null;

  CheckinState copyWith({
    MoodLevel? submittingLevel,
    bool clearSubmitting = false,
    bool? editing,
    MoodToday? recorded,
    String? error,
    bool clearError = false,
  }) {
    return CheckinState(
      submittingLevel:
          clearSubmitting ? null : (submittingLevel ?? this.submittingLevel),
      editing: editing ?? this.editing,
      recorded: recorded ?? this.recorded,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
