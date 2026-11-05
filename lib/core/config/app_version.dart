/// Perbandingan versi `mayor.minor.patch` (akhiran `+build` diabaikan).
abstract final class AppVersion {
  /// Negatif bila [a] lebih lama dari [b], nol bila sama, positif bila lebih baru.
  static int compare(String a, String b) {
    final left = _parts(a);
    final right = _parts(b);
    final length = left.length > right.length ? left.length : right.length;

    for (var i = 0; i < length; i++) {
      final x = i < left.length ? left[i] : 0;
      final y = i < right.length ? right[i] : 0;
      if (x != y) {
        return x < y ? -1 : 1;
      }
    }
    return 0;
  }

  static bool isOlder(String installed, String minimum) {
    return compare(installed, minimum) < 0;
  }

  static List<int> _parts(String version) {
    return version
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList();
  }
}
