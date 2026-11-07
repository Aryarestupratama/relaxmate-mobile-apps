import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/features/crisis/data/crisis_contact_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kontak bantuan harus tampil tanpa internet dan tanpa masuk (FR-M011, RULE-M034).
/// Urutan sumber: salinan di perangkat (hasil API-M011 terakhir), lalu aset bawaan.
/// Daftar tidak sensitif, jadi boleh di `shared_preferences` (Architecture-M bagian 8).
class CrisisContactsRepository {
  const CrisisContactsRepository(this._api);

  final ApiClient _api;

  /// Salinan di perangkat; bila belum ada atau rusak, aset bawaan.
  Future<CrisisContactSet> loadLocal() async {
    final cached = await _readCache();
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString(AppAssets.crisisContacts);
    final bundled = CrisisContactSet.tryParse(jsonDecode(raw));
    if (bundled == null) {
      throw const FormatException('crisis_contacts_asset_invalid');
    }
    return bundled;
  }

  /// API-M011. Hanya dipanggil saat sudah masuk. `null` bila bentuknya tidak sesuai kontrak.
  Future<CrisisContactSet?> fetchRemote() async {
    final json = await _api.get('/crisis-contacts');
    return CrisisContactSet.tryParse(json);
  }

  Future<void> saveCache(CrisisContactSet set) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.crisisContactsCacheKey,
        jsonEncode(set.toJson()),
      );
    } on Object {
      // Gagal menyimpan salinan tidak boleh mengganggu tampilan; aset bawaan tetap ada.
    }
  }

  Future<CrisisContactSet?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.crisisContactsCacheKey);
      if (raw == null) {
        return null;
      }
      return CrisisContactSet.tryParse(jsonDecode(raw));
    } on Object {
      return null;
    }
  }
}

final Provider<CrisisContactsRepository> crisisContactsRepositoryProvider =
    Provider<CrisisContactsRepository>(
  (ref) => CrisisContactsRepository(ref.watch(apiClientProvider)),
);
