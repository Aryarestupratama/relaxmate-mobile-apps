/// Pilihan persetujuan pelatihan (API-M010). Tidak punya nilai awal: pengguna harus memilih
/// sendiri (FR-M002, RULE-071 web).
enum TrainingChoice {
  granted('granted'),
  denied('denied');

  const TrainingChoice(this.wireValue);

  /// Nilai yang dikirim ke server pada kolom `choice`.
  final String wireValue;

  /// `null` bila belum dijawab atau nilainya tidak dikenal.
  static TrainingChoice? fromWire(Object? value) {
    for (final choice in TrainingChoice.values) {
      if (choice.wireValue == value) {
        return choice;
      }
    }
    return null;
  }
}
