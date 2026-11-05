import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_colors.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_space.dart';
import 'package:relaxmate/core/theme/rb_text.dart';

/// `ThemeData` RelaxMate, dirakit dari token. Mode terang saja (A-D1).
abstract final class RbTheme {
  static ThemeData light() {
    const colors = RbColors.standard;
    const space = RbSpace.standard;
    final text = RbText.fromColors(colors);

    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.softLavender,
      onSecondary: colors.text,
      error: colors.danger,
      onError: colors.onPrimary,
      surface: colors.card,
      onSurface: colors.text,
      surfaceContainerHighest: colors.surfaceAlt,
      outline: colors.inputBorder,
      outlineVariant: colors.border,
    );

    const minTouch = Size(RbSize.minTouch, RbSize.minTouch);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.pageBg,
      fontFamily: RbText.fontFamily,
      textTheme: TextTheme(
        headlineMedium: text.h1,
        titleLarge: text.h2,
        titleMedium: text.h3,
        bodyLarge: text.body,
        bodyMedium: text.small,
        bodySmall: text.caption,
        labelLarge: text.button,
      ),
      extensions: <ThemeExtension<dynamic>>[colors, text, space],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.pageBg,
        foregroundColor: colors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.h3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(minTouch),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
          textStyle: WidgetStatePropertyAll<TextStyle>(text.button),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.surfaceAlt;
            }
            if (states.contains(WidgetState.pressed)) {
              return colors.navHover;
            }
            return colors.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            return states.contains(WidgetState.disabled)
                ? colors.textMuted
                : colors.onPrimary;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(minTouch),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
          textStyle: WidgetStatePropertyAll<TextStyle>(text.button),
          foregroundColor: WidgetStatePropertyAll<Color>(colors.primary),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: colors.primary, width: 2),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(minTouch),
          textStyle: WidgetStatePropertyAll<TextStyle>(text.button),
          foregroundColor: WidgetStatePropertyAll<Color>(colors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        hintStyle: text.small.copyWith(color: colors.textMuted),
        contentPadding: EdgeInsets.symmetric(
          horizontal: space.md,
          vertical: space.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: RbRadius.inputBorder,
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RbRadius.inputBorder,
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RbRadius.inputBorder,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: RbRadius.inputBorder,
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: RbRadius.inputBorder,
          borderSide: BorderSide(color: colors.danger, width: 2),
        ),
        errorStyle: text.caption.copyWith(color: colors.danger),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.primary,
        contentTextStyle: text.small.copyWith(color: colors.onPrimary),
        shape: const RoundedRectangleBorder(borderRadius: RbRadius.cardBorder),
      ),
    );
  }
}
