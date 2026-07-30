import 'package:flutter/material.dart';

/// Color tokens for the Golfie design system.
///
/// All values are sourced 1:1 from docs/DESIGN.md "Tokens — Colors".
/// Hex literals (no opacity) unless the token itself defines one.
class GolfieColors {
  const GolfieColors._();

  // Surfaces
  static const Color canvas = Color(0xFFFFF3E7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color linen = Color(0xFFF7F7F7);
  static const Color cloud = Color(0xFFEFEFEF);

  // Text + ink
  static const Color ink = Color(0xFF030302);
  static const Color stone = Color(0xFFBEBBBA);
  static const Color graphite = Color(0xFF41413F);

  // Lines + borders
  static const Color ash = Color(0xFFE1E1E1);

  // Brand pastels
  static const Color mint = Color(0xFF9BD8A9);
  static const Color marigold = Color(0xFFFDE99B);
  static const Color periwinkle = Color(0xFFB8CAF5);
  static const Color sky = Color(0xFF9ED4EF);

  // Accents
  static const Color papaya = Color(0xFFFF4500);
  static const Color azure = Color(0xFF0087FF);

  // Sky gradient used for hero textures (DESIGN.md "Tokens — Colors" → Sky)
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
  );
}