import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';

/// Token tipografi (Design-M bagian 2). Plus Jakarta Sans dibundel sebagai aset.
/// Ukuran dalam sp sehingga mengikuti skala teks pengguna.
@immutable
class RbText extends ThemeExtension<RbText> {
  const RbText({
    required this.body,
    required this.small,
    required this.caption,
    required this.h3,
    required this.h2,
    required this.h1,
    required this.button,
  });

  factory RbText.fromColors(RbColors colors) {
    TextStyle style(double size, FontWeight weight, double height) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: colors.text,
      );
    }

    return RbText(
      body: style(16, FontWeight.w500, 1.5),
      small: style(14, FontWeight.w400, 1.5),
      caption: style(12, FontWeight.w400, 1.4),
      h3: style(18, FontWeight.w600, 1.4),
      h2: style(22, FontWeight.w700, 1.3),
      h1: style(28, FontWeight.w800, 1.2),
      button: style(16, FontWeight.w700, 1.2),
    );
  }

  static const String fontFamily = 'PlusJakartaSans';

  /// Teks isi dan pesan chat.
  final TextStyle body;
  final TextStyle small;
  final TextStyle caption;
  final TextStyle h3;
  final TextStyle h2;
  final TextStyle h1;
  final TextStyle button;

  @override
  RbText copyWith({
    TextStyle? body,
    TextStyle? small,
    TextStyle? caption,
    TextStyle? h3,
    TextStyle? h2,
    TextStyle? h1,
    TextStyle? button,
  }) {
    return RbText(
      body: body ?? this.body,
      small: small ?? this.small,
      caption: caption ?? this.caption,
      h3: h3 ?? this.h3,
      h2: h2 ?? this.h2,
      h1: h1 ?? this.h1,
      button: button ?? this.button,
    );
  }

  @override
  RbText lerp(ThemeExtension<RbText>? other, double t) {
    if (other is! RbText) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
