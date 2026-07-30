import 'package:flutter/material.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/core/theme/golfie_typography.dart';

/// Section header + body container styled as a "torn paper" entry.
///
/// The eyebrow acts as a small uppercase label above the title. The body
/// sits directly underneath with no explicit card chrome — use when content
/// needs visual breathing room without a full collage card.
class GolfieTornPaperSection extends StatelessWidget {
  const GolfieTornPaperSection({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: GolfieTypography.textTheme.bodyMedium!.copyWith(
              color: GolfieColors.periwinkle,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GolfieTypography.textTheme.titleLarge!.copyWith(
              color: GolfieColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}