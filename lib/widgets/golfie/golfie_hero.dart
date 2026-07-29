import 'package:flutter/material.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/core/theme/golfie_typography.dart';
import 'package:golfie/widgets/golfie/golfie_collage_card.dart';

/// Hero-style greeting surface for the home screen.
///
/// Shows a large [title] over a [subtitle] and an optional trailing action
/// (typically a CTA button). Uses [GolfieCollageCard] as the visual base
/// so it composes cleanly with the rest of the Golfie widget set.
class GolfieHero extends StatelessWidget {
  const GolfieHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return GolfieCollageCard(
      accentCorner: GolfieAccentCorner.topRight,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GolfieTypography.displaySmall.copyWith(
              color: GolfieColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GolfieTypography.bodyMedium.copyWith(
              color: GolfieColors.ink.withValues(alpha: 0.7),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}