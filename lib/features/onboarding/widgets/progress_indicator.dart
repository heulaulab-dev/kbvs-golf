import 'package:flutter/material.dart';
import '../../../core/theme/golfie_colors.dart';

/// Horizontal stepper indicator for onboarding screens.
///
/// Shows circular dots representing each step in the onboarding flow.
/// Completed steps show in mint (#9bd8a9), current step in ink (#030302),
/// pending steps in ash (#e1e1e1). Uses simple unobtrusive design per Golfie spec.
class ProgressIndicator extends StatelessWidget {
  final int currentStep; // 0-indexed
  final int totalSteps;

  const ProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          bool isCompleted = index < currentStep;
          bool isCurrent = index == currentStep;

          Color dotColor;
          if (isCurrent) {
            dotColor = GolfieColors.ink; // Ink black for current
          } else if (isCompleted) {
            dotColor = GolfieColors.mint; // Mint green for completed
          } else {
            dotColor = GolfieColors.ash; // Ash gray for pending
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
