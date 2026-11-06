import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sinyal dari lapisan jaringan ke lapisan fitur: server menolak token (401).
/// `ApiClient` menghapus token lalu memanggil [fire]; fitur sesi (`AuthController`)
/// mendengarkan dan mengarahkan pengguna ke layar Masuk (RULE-M035). Dengan sinyal
/// ini `core/` tidak perlu mengimpor `features/`.
class SessionExpiredSignal extends ChangeNotifier {
  void fire() => notifyListeners();
}

final Provider<SessionExpiredSignal> sessionExpiredSignalProvider =
    Provider<SessionExpiredSignal>((ref) {
  final signal = SessionExpiredSignal();
  ref.onDispose(signal.dispose);
  return signal;
});
