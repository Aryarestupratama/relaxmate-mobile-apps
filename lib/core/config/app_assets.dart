/// Jalur aset yang dibundel. Satu tempat agar tidak ada string jalur di widget.
abstract final class AppAssets {
  static const String mascotAvatar =
      'assets/images/mascot/relaxmate-avatar.webp';
  static const String mascotHalf = 'assets/images/mascot/relaxmate-half.webp';

  /// Animasi maskot per keadaan (WebP beranimasi transparan, 24 fps, dirender dari rig SVG
  /// oleh skrip `tool/mascot`; bukan Rive). Nama berkas = nama `MascotState`.
  static String mascotAnim(String name) =>
      'assets/images/mascot/anim/$name.webp';

  /// Salinan animasi maskot dengan garis tepi gelap (dibuat `tool/mascot/add_outline.py`) untuk
  /// latar terang tempat maskot putih menyatu dengan latar: tampilan maskot chat. `still`
  /// adalah gambar diamnya (gerak dikurangi). Bantalan kiri, kanan, atas: bingkai 376 x 499.
  static String mascotAnimOutlined(String name) =>
      'assets/images/mascot/outlined/$name.webp';
  static const String mascotStillOutlined =
      'assets/images/mascot/outlined/still.webp';

  /// Ilustrasi sambutan (SCR-M02): RelaxMate memegang lima blob mood. PNG persegi 1:1,
  /// latar transparan, dibuat di luar repo (lihat `docs/Welcome-Illustration-Brief.md`).
  static const String welcomeHero = 'assets/images/welcome/welcome-hero.png';

  /// Blob mood tingkat 1 sampai 5 (Cek Rasa, `MoodBlobRow`); gambar yang sama dengan web.
  static String moodBlob(int level) => 'assets/images/mood/mood-$level.webp';

  /// Kontak bantuan bawaan: tampil bila belum ada salinan dari server (FR-M011).
  static const String crisisContacts = 'assets/crisis/crisis_contacts.json';
}
