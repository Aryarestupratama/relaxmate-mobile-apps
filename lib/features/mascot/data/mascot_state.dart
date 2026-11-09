import 'package:relaxmate/core/config/app_assets.dart';
import 'package:relaxmate/core/texts/app_texts.dart';

/// Keadaan maskot dalam aplikasi (Design-M bagian 9, FR-M015). Nama berkas animasi sama
/// dengan nama keadaan.
enum MascotState {
  /// Diam / bernapas: sambutan chat dan Temani saja.
  idle,

  /// Menyimak: mode suara saat mendengarkan (dipakai di TASK-M034).
  listening,

  /// Berpikir: menunggu balasan.
  thinking,

  /// Bicara: balasan terbaca atau klip diputar.
  speaking;

  String get asset => AppAssets.mascotAnim(name);

  /// Label untuk pembaca layar.
  String get label => switch (this) {
        MascotState.idle => AppTexts.mascotStateIdle,
        MascotState.listening => AppTexts.mascotStateListening,
        MascotState.thinking => AppTexts.mascotStateThinking,
        MascotState.speaking => AppTexts.mascotStateSpeaking,
      };
}
