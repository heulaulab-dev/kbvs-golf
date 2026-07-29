import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for the Golfie design system.
///
/// Sourced 1:1 from docs/DESIGN.md "Tokens — Typography → Type Scale".
/// Serif (Lora) for headlines, sans (Inter) for UI/body.
class GolfieTypography {
  const GolfieTypography._();

  /// Sans family for all UI + body text.
  static TextTheme _sansTextTheme() {
    final TextTheme base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 66,
        height: 1.1,
        letterSpacing: -2.64,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 56,
        height: 1.05,
        letterSpacing: -2.24,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 46,
        height: 1.1,
        letterSpacing: -1.38,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: GoogleFonts.lora().fontFamily,
        fontSize: 36,
        height: 1.2,
        letterSpacing: -0.72,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        height: 1.4,
        letterSpacing: -0.72,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        letterSpacing: -0.24,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.5,
        letterSpacing: 0.14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.5,
        letterSpacing: 0.12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
      ),
    );
  }

  static final TextTheme textTheme = _sansTextTheme();
}