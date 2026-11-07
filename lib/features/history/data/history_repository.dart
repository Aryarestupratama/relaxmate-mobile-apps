import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/history/data/conversation_page.dart';
import 'package:relaxmate/features/history/data/history_page.dart';

/// API-M015 dan M016: riwayat per Percakapan, hanya baca. Semua panggilan lewat `ApiClient`
/// (RULE-M022). Isi pesan hanya di memori (RULE-M031).
class HistoryRepository {
  const HistoryRepository(this._api);

  final ApiClient _api;

  /// Satu halaman daftar Percakapan, terbaru dulu. [cursor] dari `nextCursor` halaman
  /// sebelumnya; `null` untuk halaman pertama.
  Future<HistoryPage> days({String? cursor}) async {
    final json = await _api.get('/relaxmate/days', query: _query(cursor));
    final page = HistoryPage.tryParse(json);
    if (page == null) {
      throw _malformed();
    }
    return page;
  }

  /// Satu halaman pesan Percakapan [conversationId], urut lama ke baru.
  Future<ConversationPage> messages(
    String conversationId, {
    String? cursor,
  }) async {
    final json = await _api.get(
      '/relaxmate/conversations/$conversationId/messages',
      query: _query(cursor),
    );
    final page = ConversationPage.tryParse(json);
    if (page == null) {
      throw _malformed();
    }
    return page;
  }

  Map<String, Object?>? _query(String? cursor) {
    return cursor == null ? null : <String, Object?>{'cursor': cursor};
  }

  /// Bentuk balasan tidak sesuai kontrak: tampilkan galat umum, tanpa detail.
  ApiException _malformed() {
    return const ApiException(
      kind: ApiErrorKind.unknown,
      message: AppTexts.errorGeneric,
    );
  }
}

final Provider<HistoryRepository> historyRepositoryProvider =
    Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(apiClientProvider)),
);
