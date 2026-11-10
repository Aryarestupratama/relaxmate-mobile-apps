/// Pengaturan lokal pengguna (FR-M025). Suara dan maskot mengambang menyusul di task
/// fiturnya.
class AppSettings {
  const AppSettings({
    required this.breathingHaptics,
    required this.privacyCover,
  });

  /// Bawaan: getar mati (hemat dan tidak mengejutkan); lapisan privasi nyala (NFR-M01).
  static const AppSettings defaults = AppSettings(
    breathingHaptics: false,
    privacyCover: true,
  );

  /// Getar halus di setiap pergantian tahap latihan napas.
  final bool breathingHaptics;

  /// Layar aplikasi ditutup gambar polos saat aplikasi tidak di depan layar.
  final bool privacyCover;

  AppSettings copyWith({bool? breathingHaptics, bool? privacyCover}) {
    return AppSettings(
      breathingHaptics: breathingHaptics ?? this.breathingHaptics,
      privacyCover: privacyCover ?? this.privacyCover,
    );
  }
}
