import 'package:relaxmate/core/texts/app_texts.dart';

/// Lima langkah grounding 5-4-3-2-1 (FR-M014), satu indra per langkah, urut dari lima sampai
/// satu. `count` adalah angka besar di layar; `instruction` melanjutkan kalimat dari angka itu
/// ("Sebutkan" / 5 / "hal yang bisa kamu lihat") sehingga jumlahnya tidak diulang di teks.
/// `hint` satu kalimat lembut khusus langkah itu.
enum GroundingStep {
  see(5, AppTexts.groundingSee, AppTexts.groundingSeeHint),
  touch(4, AppTexts.groundingTouch, AppTexts.groundingTouchHint),
  hear(3, AppTexts.groundingHear, AppTexts.groundingHearHint),
  smell(2, AppTexts.groundingSmell, AppTexts.groundingSmellHint),
  taste(1, AppTexts.groundingTaste, AppTexts.groundingTasteHint);

  const GroundingStep(this.count, this.instruction, this.hint);

  final int count;
  final String instruction;
  final String hint;
}
