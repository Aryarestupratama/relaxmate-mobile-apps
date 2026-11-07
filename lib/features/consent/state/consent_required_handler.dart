import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/consent/state/consent_controller.dart';

/// 403 `consent_required`: versi consent dinaikkan saat aplikasi terbuka. Gerbang consent
/// memeriksa ulang dan menampilkan layar consent. Mengembalikan `true` bila [error] adalah
/// galat itu (pemanggil berhenti tanpa menampilkan galat).
bool invalidateIfConsentRequired(Ref ref, ApiException error) {
  if (!error.hasCode('consent_required')) {
    return false;
  }
  ref.invalidate(consentControllerProvider);
  return true;
}
