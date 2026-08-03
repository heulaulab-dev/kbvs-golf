import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../widgets/golfie/golfie_index.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/progress_indicator.dart';
import 'onboarding_profile_screen.dart';

/// Welcome screen — first step of onboarding flow.
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboard = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Hero / background section
            Expanded(
              flex: 2,
              child: _buildHeroSection(),
            ),

            // Content area with card
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
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
                    child: _buildContent(context, onboard),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        // Sky gradient background texture per DESIGN.md
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
            ),
          ),
        ),

        // Mint pastel collage shape overlay (decorative element per DESIGN.md)
        Positioned(
          top: -40,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: GolfieColors.mint.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // GolfieHero component for brand presentation
        Positioned(
          bottom: 40,
          left: 40,
          right: 40,
          child: GolfieHero(
            title: 'Play like a pro',
            subtitle: '',
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, OnboardingProvider onboard) {
    // IntrinsicHeight + ConstrainedBox keeps the button pinned to the bottom
    // when the card is tall enough, and makes the content scrollable when the
    // card is short (small screens) — prevents RenderFlex overflow.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subheading + description
                  const SizedBox(height: 8),
                  Text(
                    'Discover and join local golf tournaments in Jakarta',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: GolfieColors.graphite,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Share your journey, meet fellow golfers in your area, and level up your game.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: GolfieColors.stone,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),

                  // Get Started button — ink filled pill with haptic feedback
                  Consumer<OnboardingProvider>(
                    builder: (context, onboardChild, _) {
                      return SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(GolfieRadii.pill),
                            ),
                            backgroundColor: GolfieColors.ink,
                            foregroundColor: GolfieColors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.24,
                            ),
                          ),
                          onPressed: () {
                            debugPrint('🟢 [ONBOARD] Get Started button tapped — step: ${onboardChild.currentStep}, completed: ${onboardChild.completed}');
                            onboardChild.nextStep();
                            debugPrint('🟢 [ONBOARD] after nextStep() — step: ${onboardChild.currentStep}');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OnboardingProfileScreen(),
                              ),
                            );
                          },
                          child: const Text('Get Started'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Progress indicator at bottom
                  ProgressIndicator(currentStep: onboard.currentStep, totalSteps: onboard.totalSteps),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
