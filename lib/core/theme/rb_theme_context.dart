import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/core/theme/rb_space.dart';
import 'package:relaxmate/core/theme/rb_text.dart';

/// Akses token dari `BuildContext`. Widget tidak menulis nilai sendiri (RULE-M050).
extension RbThemeContext on BuildContext {
  RbColors get rbColors =>
      Theme.of(this).extension<RbColors>() ?? RbColors.standard;

  RbText get rbText =>
      Theme.of(this).extension<RbText>() ??
      RbText.fromColors(RbColors.standard);

  RbSpace get rbSpace =>
      Theme.of(this).extension<RbSpace>() ?? RbSpace.standard;
}
