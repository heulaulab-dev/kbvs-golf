import 'package:flutter/material.dart';
import 'package:golfie/core/theme/golfie_colors.dart';

/// Visual style for the corner accent on a [GolfieCollageCard].
enum GolfieAccentCorner {
  /// No accent dot rendered (default).
  none,

  /// Periwinkle dot anchored to the top-right corner.
  topRight,

  /// Periwinkle dot anchored to the bottom-left corner.
  bottomLeft,
}

/// A "torn paper" collage card used for rich content surfaces.
///
/// Wraps a child in a soft white container with a subtle elevation and an
/// optional 8px Periwinkle accent dot in one of the corners. Designed to be
/// used as a base container for hero, entry, and detail surfaces across the
/// Golfie app.
class GolfieCollageCard extends StatelessWidget {
  const GolfieCollageCard({
    super.key,
    required this.child,
    this.accentCorner = GolfieAccentCorner.none,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;

  /// Which corner to render the accent in. [GolfieAccentCorner.none] hides it.
  final GolfieAccentCorner accentCorner;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: GolfieColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: GolfieColors.ink.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          if (accentCorner == GolfieAccentCorner.topRight)
            const Positioned(top: 10, right: 10, child: _AccentDot()),
          if (accentCorner == GolfieAccentCorner.bottomLeft)
            const Positioned(bottom: 10, left: 10, child: _AccentDot()),
        ],
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: GolfieColors.periwinkle,
        shape: BoxShape.circle,
      ),
    );
  }
}
