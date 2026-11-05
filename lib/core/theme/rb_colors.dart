import 'package:flutter/material.dart';

/// Token warna RelaxMate. Sumber nilai: `resources/css/app.css` di website
/// (Design-M bagian 2, RULE-M050). Satu-satunya tempat nilai warna ditulis.
@immutable
class RbColors extends ThemeExtension<RbColors> {
  const RbColors({
    required this.primary,
    required this.onPrimary,
    required this.pageBg,
    required this.card,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.inputBorder,
    required this.surfaceAlt,
    required this.softLavender,
    required this.brandSoft,
    required this.mood1,
    required this.mood2,
    required this.mood3,
    required this.mood4,
    required this.mood5,
    required this.success,
    required this.warning,
    required this.danger,
    required this.crisisBg,
    required this.crisisText,
    required this.navHover,
    required this.gradientTop,
    required this.gradientMid,
    required this.gradientBottom,
  });

  /// Mode terang saja untuk rilis pertama (A-D1).
  static const RbColors standard = RbColors(
    primary: Color(0xFF0A2244),
    onPrimary: Color(0xFFFFFFFF),
    pageBg: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF42506A),
    textMuted: Color(0xFF555B72),
    border: Color(0xFFD5DCE8),
    inputBorder: Color(0xFF76819A),
    surfaceAlt: Color(0xFFEEF2F8),
    softLavender: Color(0xFFDED4FF),
    brandSoft: Color(0xFFC3B1FF),
    mood1: Color(0xFFA98BFF),
    mood2: Color(0xFF9CCBF2),
    mood3: Color(0xFFFFB997),
    mood4: Color(0xFFABEAA2),
    mood5: Color(0xFFFCE46F),
    success: Color(0xFF047857),
    warning: Color(0xFFB45309),
    danger: Color(0xFFDC2626),
    crisisBg: Color(0xFFFEF2F2),
    crisisText: Color(0xFF991B1B),
    navHover: Color(0xFF163A6B),
    // [Assumption] A-D2: perkiraan dari gambar latar; final di Task tema.
    gradientTop: Color(0xFFFCFCFD),
    gradientMid: Color(0xFFB9D0FF),
    gradientBottom: Color(0xFFBFADFF),
  );

  /// Teks utama sama dengan `primary` (Design-M bagian 2).
  Color get text => primary;

  /// Alias ke lavender sampai website mengubah nilainya (keputusan founder 2026-11-05).
  Color get softSky => softLavender;
  Color get softMint => softLavender;
  Color get softPeach => softLavender;

  final Color primary;
  final Color onPrimary;
  final Color pageBg;
  final Color card;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color inputBorder;
  final Color surfaceAlt;
  final Color softLavender;
  final Color brandSoft;
  final Color mood1;
  final Color mood2;
  final Color mood3;
  final Color mood4;
  final Color mood5;
  final Color success;
  final Color warning;
  final Color danger;
  final Color crisisBg;
  final Color crisisText;
  final Color navHover;
  final Color gradientTop;
  final Color gradientMid;
  final Color gradientBottom;

  @override
  RbColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? pageBg,
    Color? card,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? inputBorder,
    Color? surfaceAlt,
    Color? softLavender,
    Color? brandSoft,
    Color? mood1,
    Color? mood2,
    Color? mood3,
    Color? mood4,
    Color? mood5,
    Color? success,
    Color? warning,
    Color? danger,
    Color? crisisBg,
    Color? crisisText,
    Color? navHover,
    Color? gradientTop,
    Color? gradientMid,
    Color? gradientBottom,
  }) {
    return RbColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      pageBg: pageBg ?? this.pageBg,
      card: card ?? this.card,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      inputBorder: inputBorder ?? this.inputBorder,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      softLavender: softLavender ?? this.softLavender,
      brandSoft: brandSoft ?? this.brandSoft,
      mood1: mood1 ?? this.mood1,
      mood2: mood2 ?? this.mood2,
      mood3: mood3 ?? this.mood3,
      mood4: mood4 ?? this.mood4,
      mood5: mood5 ?? this.mood5,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      crisisBg: crisisBg ?? this.crisisBg,
      crisisText: crisisText ?? this.crisisText,
      navHover: navHover ?? this.navHover,
      gradientTop: gradientTop ?? this.gradientTop,
      gradientMid: gradientMid ?? this.gradientMid,
      gradientBottom: gradientBottom ?? this.gradientBottom,
    );
  }

  /// Hanya ada satu palet (mode terang), jadi tidak ada interpolasi per warna.
  @override
  RbColors lerp(ThemeExtension<RbColors>? other, double t) {
    if (other is! RbColors) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
