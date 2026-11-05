import 'dart:io';

import 'package:dio/dio.dart';
import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';

/// Mengubah `DioException` menjadi `ApiException` (Architecture-M bagian 5 dan 11).
/// Format galat server: `{ "error": { "code": "...", "message": "..." } }`; bentuk
/// validasi Laravel `{ "errors": { "kolom": ["..."] } }` juga dikenali.
ApiException mapDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const ApiException(
        kind: ApiErrorKind.timeout,
        message: AppTexts.errorTimeout,
      );
    case DioExceptionType.connectionError:
      return const ApiException(
        kind: ApiErrorKind.offline,
        message: AppTexts.errorOffline,
      );
    case DioExceptionType.badResponse:
      return _fromResponse(exception.response);
    default:
      if (exception.error is SocketException) {
        return const ApiException(
          kind: ApiErrorKind.offline,
          message: AppTexts.errorOffline,
        );
      }
      return const ApiException(
        kind: ApiErrorKind.unknown,
        message: AppTexts.errorGeneric,
      );
  }
}

ApiException _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  final body = response?.data;

  String? code;
  String? message;
  final fields = <String, String>{};

  if (body is JsonMap) {
    final error = body['error'];
    if (error is JsonMap) {
      code = _text(error['code']);
      message = _text(error['message']);
    }

    final errors = body['errors'];
    if (errors is JsonMap) {
      for (final entry in errors.entries) {
        final value = entry.value;
        final first = value is List<Object?> && value.isNotEmpty
            ? _text(value.first)
            : _text(value);
        if (first != null) {
          fields[entry.key] = first;
        }
      }
    }
  }

  final kind = _kindFor(status);
  final retryAfter = int.tryParse(response?.headers.value('retry-after') ?? '');

  return ApiException(
    kind: kind,
    code: code,
    statusCode: status,
    retryAfterSeconds: retryAfter,
    fieldErrors: fields,
    message: message ??
        (fields.isNotEmpty ? fields.values.first : null) ??
        _defaultMessage(kind, retryAfter),
  );
}

ApiErrorKind _kindFor(int? status) {
  if (status == null) {
    return ApiErrorKind.unknown;
  }
  if (status >= 500) {
    return ApiErrorKind.server;
  }
  return switch (status) {
    401 => ApiErrorKind.unauthorized,
    403 => ApiErrorKind.forbidden,
    404 => ApiErrorKind.notFound,
    409 => ApiErrorKind.conflict,
    422 => ApiErrorKind.validation,
    429 => ApiErrorKind.rateLimited,
    _ => ApiErrorKind.unknown,
  };
}

String _defaultMessage(ApiErrorKind kind, int? retryAfter) {
  return switch (kind) {
    ApiErrorKind.offline => AppTexts.errorOffline,
    ApiErrorKind.timeout => AppTexts.errorTimeout,
    ApiErrorKind.unauthorized => AppTexts.errorUnauthorized,
    ApiErrorKind.forbidden => AppTexts.errorForbidden,
    ApiErrorKind.notFound => AppTexts.errorNotFound,
    ApiErrorKind.conflict => AppTexts.errorConflict,
    ApiErrorKind.validation => AppTexts.errorValidation,
    ApiErrorKind.rateLimited => retryAfter != null
        ? AppTexts.rateLimitedIn(retryAfter)
        : AppTexts.errorRateLimited,
    ApiErrorKind.server => AppTexts.errorServer,
    ApiErrorKind.unknown => AppTexts.errorGeneric,
  };
}

String? _text(Object? value) {
  return value is String && value.trim().isNotEmpty ? value.trim() : null;
}
