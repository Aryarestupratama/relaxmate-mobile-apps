import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/features/crisis/data/crisis_contact.dart';

/// Daftar kontak bantuan beserta versinya (`data` API-M011).
class CrisisContactSet {
  const CrisisContactSet({required this.version, required this.contacts});

  final String version;
  final List<CrisisContact> contacts;

  /// `null` bila bentuknya tidak sesuai kontrak atau daftar kosong. Daftar kosong ditolak
  /// supaya salinan yang baik di perangkat tidak tertimpa daftar kosong.
  static CrisisContactSet? tryParse(Object? value) {
    if (value is! JsonMap) {
      return null;
    }
    final version = value['version'];
    final raw = value['contacts'];
    if (version is! String || version.isEmpty || raw is! List<Object?>) {
      return null;
    }
    final contacts = <CrisisContact>[];
    for (final item in raw) {
      final contact = CrisisContact.tryParse(item);
      if (contact != null) {
        contacts.add(contact);
      }
    }
    if (contacts.isEmpty) {
      return null;
    }
    return CrisisContactSet(version: version, contacts: contacts);
  }

  JsonMap toJson() => <String, Object?>{
        'version': version,
        'contacts': contacts.map((c) => c.toJson()).toList(),
      };
}
