import 'package:flutter/widgets.dart';

/// Token radius (Design-M bagian 2).
abstract final class RbRadius {
  static const double input = 8;
  static const double card = 12;
  static const double bubble = 20;
  static const double bubbleTail = 6;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius inputBorder =
      BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardBorder =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius bubbleBorder =
      BorderRadius.all(Radius.circular(bubble));
  static const BorderRadius sheetBorder =
      BorderRadius.all(Radius.circular(sheet));
  static const BorderRadius pillBorder =
      BorderRadius.all(Radius.circular(pill));
}
