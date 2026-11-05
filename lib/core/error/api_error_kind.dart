/// Jenis galat yang dikenali klien. Kode spesifik dari server (mis. `daily_limit`,
/// `consent_required`, `ai_unavailable`) tetap ada di `ApiException.code`.
enum ApiErrorKind {
  offline,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  rateLimited,
  server,
  unknown,
}
