import 'package:flutter/material.dart';
import 'package:golfie/core/theme/golfie_colors.dart';
import 'package:golfie/core/theme/golfie_typography.dart';

/// Centered empty-state placeholder used when a list or section has no data.
///
/// Displays a large icon, a title, and an optional subtitle. Golfie-styled.
class GolfieEmptyState extends StatelessWidget {
  const GolfieEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: GolfieColors.periwinkle),
          const SizedBox(height: 16),
          Text(title, style: GolfieTypography.textTheme.bodyMedium!.copyWith(
            color: GolfieColors.ink,
            fontWeight: FontWeight.w700,
          )),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: GolfieTypography.textTheme.bodySmall!.copyWith(
              color: GolfieColors.ink.withValues(alpha: 0.6),
            )),
          ],
        ],
      ),
    );
  }
}