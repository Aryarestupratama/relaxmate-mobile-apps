import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:relaxmate/core/config/app_constants.dart';

/// Token Sanctum, hanya di Keystore Android lewat `flutter_secure_storage`
/// (RULE-M031). Dihapus saat logout, 401, atau hapus akun.
class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> read() async {
    try {
      return await _storage.read(key: AppConstants.tokenStorageKey);
    } on PlatformException {
      // Data tidak terbaca (mis. kunci Keystore berubah): anggap belum masuk.
      return null;
    }
  }

  Future<void> write(String token) {
    return _storage.write(key: AppConstants.tokenStorageKey, value: token);
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: AppConstants.tokenStorageKey);
    } on PlatformException {
      return;
    }
  }
}
