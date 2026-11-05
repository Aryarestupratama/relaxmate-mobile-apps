import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/features/startup/data/server_config.dart';

/// API-M007: `GET /config` (publik, tanpa token).
class ServerConfigRepository {
  const ServerConfigRepository(this._api);

  final ApiClient _api;

  Future<ServerConfig> fetch() async {
    final json = await _api.get('/config', authenticated: false);
    return ServerConfig.fromJson(json);
  }
}

final Provider<ServerConfigRepository> serverConfigRepositoryProvider =
    Provider<ServerConfigRepository>(
  (ref) => ServerConfigRepository(ref.watch(apiClientProvider)),
);
