import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/progress_indicator.dart';
import '../../../tournament/models/skill_level.dart';

/// Skill screen — lets user select their golf skill level from predefined options.
class OnboardingSkillScreen extends StatelessWidget {
  const OnboardingSkillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboard = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Card container with shadow
              Container(
                decoration: BoxDecoration(
                  color: GolfieColors.white,
                  borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
                  boxShadow: [
                    BoxShadow(color: const Color(0x00000001), blurRadius: 50, offset: const Offset(50, 40)),
                    BoxShadow(color: const Color(0x00000002), blurRadius: 50, offset: const Offset(50, 40)),
                    BoxShadow(color: const Color(0x00000005), blurRadius: 20, offset: const Offset(20, 40)),
                    BoxShadow(color: const Color(0x08000008), blurRadius: 3, offset: const Offset(3, 10)),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator at top (step 2 of 4)
                      ProgressIndicator(currentStep: onboard.currentStep, totalSteps: 4),
                      const SizedBox(height: 16),

                      // Subheading
                      Text(
                        "What's your skill level?",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.72,
                          color: GolfieColors.ink,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Skill selection grid — 3 cards in a row (responsive)
                      _buildSkillGrid(context, onboard),
                      const Spacer(),

                      // Next button — enabled only when a skill is selected
                      Consumer<OnboardingProvider>(
                        builder: (context, onboardChild, _) {
                          final hasSelection = onboardChild.skillLevel != null;

                          return SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(GolfieRadii.pill),
                                ),
                                backgroundColor: hasSelection ? GolfieColors.ink : GolfieColors.stone,
                                foregroundColor: hasSelection ? GolfieColors.white : GolfieColors.ink,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.24,
                                ),
                              ),
                              onPressed: hasSelection ? () => _handleNext(onboardChild) : null,
                              child: const Text('Next'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillGrid(BuildContext context, OnboardingProvider onboard) {
    final selectedSkill = onboard.skillLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: SkillLevel.values.length,
        itemBuilder: (context, index) {
          final skill = SkillLevel.values[index];
          final isSelected = selectedSkill == skill;

          return GestureDetector(
            onTap: () => _selectSkill(skill, onboard),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? GolfieColors.mint.withValues(alpha: 0.1)
                    : GolfieColors.white,
                borderRadius: BorderRadius.circular(GolfieRadii.lg),
                border: Border.all(
                  color: isSelected ? GolfieColors.mint : GolfieColors.ash,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: GolfieColors.mint.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji/icon for skill level
                  Icon(
                    _getSkillIcon(skill),
                    size: 40,
                    color: isSelected ? GolfieColors.mint : GolfieColors.graphite,
                  ),
                  const SizedBox(height: 8),
                  // Label
                  Text(
                    _getSkillLabel(skill),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: GolfieColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getSkillIcon(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Icons.golf_course;
      case SkillLevel.casual:
        return Icons.flag;
      case SkillLevel.competitive:
        return Icons.sentiment_very_satisfied;
      case SkillLevel.pro:
        return Icons.star;
    }
  }

  String _getSkillLabel(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.casual:
        return 'Casual';
      case SkillLevel.competitive:
        return 'Competitive';
      case SkillLevel.pro:
        return 'Pro';
    }
  }

  void _selectSkill(SkillLevel skill, OnboardingProvider onboard) {
    onboard.setProfileInfo(name: onboard.userName ?? '', level: skill);
  }

  void _handleNext(OnboardingProvider onboard) {
    // Already handled via setProfileInfo calling nextStep() internally
  }
}