/// Hasil kirim ulang email verifikasi (API-M005).
class ResendResult {
  const ResendResult({required this.emailVerified, required this.emailSent});

  /// Benar bila email ternyata sudah terverifikasi (tidak ada yang dikirim).
  final bool emailVerified;
  final bool emailSent;
}
