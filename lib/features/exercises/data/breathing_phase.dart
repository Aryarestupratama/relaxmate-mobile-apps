import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';

/// Tahap dalam satu putaran napas, berurutan: tarik, tahan, embuskan (FR-M014).
enum BreathingPhase {
  inhale(AppTexts.breathingInhale, AppConstants.breathingInhaleSeconds),
  hold(AppTexts.breathingHold, AppConstants.breathingHoldSeconds),
  exhale(AppTexts.breathingExhale, AppConstants.breathingExhaleSeconds);

  const BreathingPhase(this.instruction, this.seconds);

  /// Kalimat panduan yang tampil dan dibacakan pembaca layar.
  final String instruction;
  final int seconds;

  Duration get duration => Duration(seconds: seconds);

  /// Tahap sesudahnya dalam putaran yang sama; `null` setelah embusan (putaran selesai).
  BreathingPhase? get next => switch (this) {
        inhale => hold,
        hold => exhale,
        exhale => null,
      };
}
