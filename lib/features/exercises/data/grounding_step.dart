import 'package:relaxmate/core/texts/app_texts.dart';

/// Lima langkah grounding 5-4-3-2-1 (FR-M014), satu indra per langkah, urut dari lima sampai
/// satu. `count` adalah angka besar yang tampil di layar.
enum GroundingStep {
  see(5, AppTexts.groundingSee),
  touch(4, AppTexts.groundingTouch),
  hear(3, AppTexts.groundingHear),
  smell(2, AppTexts.groundingSmell),
  taste(1, AppTexts.groundingTaste);

  const GroundingStep(this.count, this.instruction);

  final int count;
  final String instruction;
}
