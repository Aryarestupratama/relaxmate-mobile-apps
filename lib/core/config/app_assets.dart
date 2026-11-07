/// Jalur aset yang dibundel. Satu tempat agar tidak ada string jalur di widget.
abstract final class AppAssets {
  static const String mascotAvatar =
      'assets/images/mascot/relaxmate-avatar.webp';
  static const String mascotHalf = 'assets/images/mascot/relaxmate-half.webp';

  /// Blob mood tingkat 1 sampai 5 (Cek Rasa, `MoodBlobRow`); gambar yang sama dengan web.
  static String moodBlob(int level) => 'assets/images/mood/mood-$level.webp';

  /// Kontak bantuan bawaan: tampil bila belum ada salinan dari server (FR-M011).
  static const String crisisContacts = 'assets/crisis/crisis_contacts.json';
}
