import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/api/api_client.dart';
import 'package:relaxmate/core/api/api_providers.dart';
import 'package:relaxmate/core/api/json_map.dart';
import 'package:relaxmate/core/error/api_error_kind.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/features/chat/data/chat_day.dart';
import 'package:relaxmate/features/chat/data/send_result.dart';

/// API-M012 dan M013: aliran harian, kirim pesan, dan ulang balasan. Semua panggilan lewat
/// `ApiClient` (RULE-M022). Validasi dan batas sebenarnya di server (RULE-M023).
class ChatRepository {
  const ChatRepository(this._api);

  final ApiClient _api;

  /// Mengambil atau membuat Percakapan hari ini (hari WIB berjalan, batas 04.00).
  Future<ChatDay> today() async {
    final json = await _api.get('/relaxmate/today');
    final day = ChatDay.tryParse(json);
    if (day == null) {
      throw _malformed();
    }
    return day;
  }

  Future<SendResult> send(String conversationId, String content) {
    return _post(conversationId, <String, Object?>{'content': content});
  }

  /// Memanggil ulang balasan untuk pesan pengguna terakhir yang belum dijawab; tidak menambah
  /// hitungan harian dan tidak mengirim pesan baru.
  Future<SendResult> retry(String conversationId) {
    return _post(conversationId, <String, Object?>{'retry': true});
  }

  Future<SendResult> _post(String conversationId, JsonMap body) async {
    final json = await _api.post(
      '/relaxmate/conversations/$conversationId/messages',
      body: body,
    );
    final result = SendResult.tryParse(json);
    if (result == null) {
      throw _malformed();
    }
    return result;
  }

  /// Bentuk balasan tidak sesuai kontrak: tampilkan galat umum, tanpa detail.
  ApiException _malformed() {
    return const ApiException(
      kind: ApiErrorKind.unknown,
      message: AppTexts.errorGeneric,
    );
  }
}

final Provider<ChatRepository> chatRepositoryProvider =
    Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(apiClientProvider)),
);
