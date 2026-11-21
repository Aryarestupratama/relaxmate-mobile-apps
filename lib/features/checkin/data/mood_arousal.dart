import 'package:relaxmate/core/texts/app_texts.dart';

/// Tenaga yang menyertai mood (ENT-006 `arousal_input`, opsional). Nilai `apiValue` sama
/// dengan enum server `ArousalInput`; label sama dengan web (Design-M A-D3).
enum MoodArousal {
  energized('energized', AppTexts.arousalEnergized),
  tired('tired', AppTexts.arousalTired);

  const MoodArousal(this.apiValue, this.label);

  /// Nilai yang dikirim ke API-M018 dan API-M021 (`arousal_input`).
  final String apiValue;
  final String label;
}
