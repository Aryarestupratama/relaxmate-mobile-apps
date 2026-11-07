import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/core/config/app_constants.dart';

/// Satu kontak bantuan (objek `contacts[]` API-M011, juga isi aset fallback).
/// `phone` dikirim apa adanya oleh server (mis. `119 ext 8`).
class CrisisContact {
  const CrisisContact({
    required this.name,
    this.phone,
    this.url,
    this.note,
    this.dummy = false,
  });

  /// Awalan ekstensi yang dikenali: `119 ext 8`, `119 ext. 8`, `119 x8`.
  static final RegExp _extension = RegExp(
    r'^(.*?)\s*(?:ext\.?|ekst\.?|x)\s*(\d+)$',
    caseSensitive: false,
  );

  static final RegExp _notDialable = RegExp(r'[^\d+]');

  final String name;
  final String? phone;

  /// Hanya `https` (server sudah menyaring); `null` bila tidak ada.
  final Uri? url;
  final String? note;

  /// Kontak contoh; tidak boleh tampil di build `prod` (RULE-M008, RULE-M048).
  final bool dummy;

  /// Alamat `tel:` untuk tombol telepon langsung. `119 ext 8` menjadi `tel:119,8`
  /// (koma = jeda sebelum ekstensi, OQ-MA9). `null` bila tidak ada nomor yang bisa dipanggil.
  Uri? get telUri {
    final raw = phone?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final match = _extension.firstMatch(raw);
    final number = (match?.group(1) ?? raw).replaceAll(_notDialable, '');
    if (number.isEmpty) {
      return null;
    }
    final extension = match?.group(2);
    final dial = extension == null
        ? number
        : '$number${AppConstants.telExtensionPause}$extension';
    return Uri(scheme: 'tel', path: dial);
  }

  /// `null` bila bentuknya tidak sesuai kontrak.
  static CrisisContact? tryParse(Object? value) {
    if (value is! JsonMap) {
      return null;
    }
    final name = value['name'];
    if (name is! String || name.trim().isEmpty) {
      return null;
    }
    final phone = value['phone'];
    final url = value['url'];
    final note = value['note'];
    final parsedUrl = url is String ? Uri.tryParse(url) : null;

    return CrisisContact(
      name: name,
      phone: phone is String && phone.trim().isNotEmpty ? phone : null,
      url: parsedUrl != null && parsedUrl.scheme == 'https' ? parsedUrl : null,
      note: note is String && note.trim().isNotEmpty ? note : null,
      dummy: value['dummy'] == true,
    );
  }

  JsonMap toJson() => <String, Object?>{
        'name': name,
        'phone': phone,
        'url': url?.toString(),
        'note': note,
        'dummy': dummy,
      };
}
