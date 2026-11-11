import 'package:relaxmate/features/settings/data/chat_view_mode.dart';

/// Pengaturan lokal pengguna (FR-M025). Suara menyusul di task fiturnya.
class AppSettings {
  const AppSettings({
    required this.breathingHaptics,
    required this.privacyCover,
    required this.overlayEnabled,
    required this.chatViewMode,
  });

  /// Bawaan: getar mati (hemat dan tidak mengejutkan); lapisan privasi nyala (NFR-M01).
  static const AppSettings defaults = AppSettings(
    breathingHaptics: false,
    privacyCover: true,
    overlayEnabled: false,
    chatViewMode: ChatViewMode.mascot,
  );

  /// Getar halus di setiap pergantian tahap latihan napas.
  final bool breathingHaptics;

  /// Layar aplikasi ditutup gambar polos saat aplikasi tidak di depan layar.
  final bool privacyCover;

  /// Pengguna ingin maskot mengambang tampil (FR-M022); bawaan mati. Efektif hanya bila izin
  /// overlay juga aktif.
  final bool overlayEnabled;

  /// Tampilan chat harian (FR-M027); bawaan maskot.
  final ChatViewMode chatViewMode;

  AppSettings copyWith({
    bool? breathingHaptics,
    bool? privacyCover,
    bool? overlayEnabled,
    ChatViewMode? chatViewMode,
  }) {
    return AppSettings(
      breathingHaptics: breathingHaptics ?? this.breathingHaptics,
      privacyCover: privacyCover ?? this.privacyCover,
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      chatViewMode: chatViewMode ?? this.chatViewMode,
    );
  }
}
