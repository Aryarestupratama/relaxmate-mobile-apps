/// Cara chat harian ditampilkan (FR-M027). Isi percakapan sama; hanya tampilannya berbeda.
enum ChatViewMode {
  /// Maskot di tengah atas, balasan terakhir di bawahnya. Bawaan.
  mascot,

  /// Daftar gelembung seperti aplikasi pesan biasa.
  conversation;

  /// Nilai yang disimpan di `shared_preferences`.
  String get storageValue => name;

  /// Nilai tak dikenal atau kosong jatuh ke [fallback].
  static ChatViewMode parse(String? value, {required ChatViewMode fallback}) {
    for (final mode in ChatViewMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }
    return fallback;
  }
}
