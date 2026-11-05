import 'package:flutter/material.dart';

/// Token jarak, basis 4 (Design-M bagian 2): 4, 8, 12, 16, 24, 32, 48.
@immutable
class RbSpace extends ThemeExtension<RbSpace> {
  const RbSpace({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 48,
  });

  static const RbSpace standard = RbSpace();

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  @override
  RbSpace copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return RbSpace(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  RbSpace lerp(ThemeExtension<RbSpace>? other, double t) {
    if (other is! RbSpace) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
