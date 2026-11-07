/// Nasib pesan yang baru dikirim dari kolom isian.
enum SendOutcome {
  /// Balasan diterima.
  accepted,

  /// Pesan tersimpan di percakapan tetapi balasan gagal: tampil dengan "Coba lagi".
  kept,

  /// Pesan tidak tersimpan (ditolak atau tidak sampai): isian dikembalikan ke kolom teks.
  rejected,
}
