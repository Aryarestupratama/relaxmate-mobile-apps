import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/consent/data/consent_prompt.dart';

/// Keadaan gerbang consent sebelum fitur AI (FR-M002).
sealed class ConsentGateState {
  const ConsentGateState();
}

/// Status consent sedang diperiksa ke server.
class ConsentChecking extends ConsentGateState {
  const ConsentChecking();
}

/// Consent belum lengkap: layar SCR-M07 tampil dan fitur AI tertahan.
class ConsentRequired extends ConsentGateState {
  const ConsentRequired(this.prompt);

  final ConsentPrompt prompt;
}

/// Consent AI dan pilihan pelatihan sudah lengkap pada versi terbaru.
class ConsentComplete extends ConsentGateState {
  const ConsentComplete();
}

/// Status consent belum bisa diperiksa (offline, timeout, galat server).
class ConsentCheckFailed extends ConsentGateState {
  const ConsentCheckFailed(this.error);

  final ApiException error;
}
