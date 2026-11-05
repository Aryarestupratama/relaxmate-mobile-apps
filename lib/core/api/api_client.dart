import 'package:dio/dio.dart';
import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/error_mapper.dart';

/// Satu-satunya pintu jaringan aplikasi (RULE-M022, RULE-M030). Hanya berbicara ke
/// API `/api/v1` milik sendiri. Repository memanggil kelas ini, widget tidak.
///
/// - Menyisipkan `Authorization: Bearer` dan `X-App-Version`.
/// - Memetakan semua galat menjadi `ApiException`.
/// - Pada 401 untuk permintaan yang membawa token: token dihapus lewat `onUnauthorized`.
/// - Tidak mencatat isi permintaan, respons, atau token (RULE-M040): tanpa `LogInterceptor`.
class ApiClient {
  ApiClient({
    required Uri baseUrl,
    required Future<String?> Function() readToken,
    required Future<String> Function() readAppVersion,
    required Future<void> Function() onUnauthorized,
    Dio? dio,
  })  : _readToken = readToken,
        _readAppVersion = readAppVersion,
        _onUnauthorized = onUnauthorized,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl.toString(),
                connectTimeout: AppConstants.requestTimeout,
                sendTimeout: AppConstants.requestTimeout,
                receiveTimeout: AppConstants.requestTimeout,
                headers: <String, Object>{
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest));
  }

  static const String _versionHeader = 'X-App-Version';
  static const String _authHeader = 'Authorization';
  static const String _noAuthKey = 'no_auth';

  final Dio _dio;
  final Future<String?> Function() _readToken;
  final Future<String> Function() _readAppVersion;
  final Future<void> Function() _onUnauthorized;

  /// `data` dari amplop `{ "data": {...} }`. `authenticated: false` untuk rute publik
  /// (login, register, `/config`): token tidak dikirim.
  Future<JsonMap> get(
    String path, {
    Map<String, Object?>? query,
    bool authenticated = true,
  }) {
    return _send('GET', path, query: query, authenticated: authenticated);
  }

  Future<JsonMap> post(
    String path, {
    JsonMap? body,
    bool authenticated = true,
  }) {
    return _send('POST', path, body: body, authenticated: authenticated);
  }

  Future<JsonMap> delete(
    String path, {
    JsonMap? body,
    bool authenticated = true,
  }) {
    return _send('DELETE', path, body: body, authenticated: authenticated);
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers[_versionHeader] = await _readAppVersion();

    if (options.extra[_noAuthKey] != true) {
      final token = await _readToken();
      if (token != null && token.isNotEmpty) {
        options.headers[_authHeader] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  Future<JsonMap> _send(
    String method,
    String path, {
    required bool authenticated,
    Object? body,
    Map<String, Object?>? query,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          extra: <String, Object?>{_noAuthKey: !authenticated},
        ),
      );
      return _unwrap(response.data);
    } on DioException catch (exception) {
      final error = mapDioException(exception);

      // Login yang salah tidak membawa token, jadi tidak dianggap sesi berakhir.
      if (error.kind == ApiErrorKind.unauthorized &&
          exception.requestOptions.headers.containsKey(_authHeader)) {
        await _onUnauthorized();
      }

      Error.throwWithStackTrace(error, exception.stackTrace);
    }
  }

  JsonMap _unwrap(Object? body) {
    if (body is JsonMap) {
      final data = body['data'];
      if (data is JsonMap) {
        return data;
      }
    }
    return const <String, Object?>{};
  }
}
