import 'package:flutter/animation.dart';

/// Token gerak (Design-M bagian 2). Hormati `MediaQuery.disableAnimations`
/// di tempat pemakaian.
abstract final class RbMotion {
  static const Duration feedback = Duration(milliseconds: 150);
  static const Duration screen = Duration(milliseconds: 250);
  static const Duration mascotBreath = Duration(milliseconds: 3500);
  static const Curve curve = Curves.easeOut;

  /// Lingkaran napas: awal dan akhir yang lembut agar terasa seperti bernapas.
  static const Curve breathCurve = Curves.easeInOut;
}
