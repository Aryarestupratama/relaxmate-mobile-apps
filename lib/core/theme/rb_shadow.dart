import 'package:flutter/widgets.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';

/// Token bayangan: diturunkan dari `primary` (6% kartu, 12% panel/overlay),
/// bukan warna terpisah (Design-M bagian 2).
abstract final class RbShadow {
  static const double _cardAlpha = 0.06;
  static const double _panelAlpha = 0.12;

  static List<BoxShadow> card(RbColors colors) => <BoxShadow>[
        BoxShadow(
          color: colors.primary.withValues(alpha: _cardAlpha),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> panel(RbColors colors) => <BoxShadow>[
        BoxShadow(
          color: colors.primary.withValues(alpha: _panelAlpha),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
