import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/storage/token_storage.dart';

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(FlutterSecureStorage()),
);

/// Versi aplikasi terpasang (mis. `0.1.0`), dikirim sebagai `X-App-Version`.
final FutureProvider<String> appVersionProvider =
    FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokens = ref.watch(tokenStorageProvider);

  return ApiClient(
    baseUrl: config.apiBaseUrl,
    readToken: tokens.read,
    readAppVersion: () => ref.read(appVersionProvider.future),
    // TASK-M022: setelah token dihapus, arahkan pengguna ke layar Masuk.
    onUnauthorized: tokens.clear,
  );
});
