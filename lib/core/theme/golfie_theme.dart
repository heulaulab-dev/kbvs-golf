import 'package:flutter/material.dart';

import 'golfie_colors.dart';
import 'golfie_radii.dart';
import 'golfie_typography.dart';

/// Builds the Golfie ThemeData by wiring token modules into Material 3 slots.
///
/// Source of truth for "how does Golfie look" — every screen inherits from here.
class GolfieTheme {
  const GolfieTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: GolfieColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: GolfieColors.ink,
        onPrimary: GolfieColors.white,
        secondary: GolfieColors.graphite,
        onSecondary: GolfieColors.white,
        surface: GolfieColors.white,
        onSurface: GolfieColors.ink,
        error: GolfieColors.papaya,
        onError: GolfieColors.white,
      ),
      textTheme: GolfieTypography.textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        color: GolfieColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GolfieColors.ink,
          foregroundColor: GolfieColors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GolfieColors.canvas,
        foregroundColor: GolfieColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: GolfieColors.ash,
    );
  }
}