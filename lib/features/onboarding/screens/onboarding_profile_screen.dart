import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../widgets/golfie/golfie_index.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/progress_indicator.dart';
import '../../../tournament/models/skill_level.dart';
import 'onboarding_skill_screen.dart';

/// Profile screen — collects user's name.
///
/// Features:
/// - Live validation (min 2 chars) with real-time Next button enable
/// - Clean form UX with proper state handling
/// - Golfie design system: ink pill CTA, mint accent, ash error
class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // If provider already has name (back navigation), populate field
    final onboard = context.read<OnboardingProvider>();
    if (onboard.userName != null && onboard.userName!.isNotEmpty) {
      _nameController.text = onboard.userName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                    BoxShadow(
                        color: const Color(0x00000001),
                        blurRadius: 50,
                        offset: const Offset(50, 40)),
                    BoxShadow(
                        color: const Color(0x00000002),
                        blurRadius: 50,
                        offset: const Offset(50, 40)),
                    BoxShadow(
                        color: const Color(0x00000005),
                        blurRadius: 20,
                        offset: const Offset(20, 40)),
                    BoxShadow(
                        color: const Color(0x08000008),
                        blurRadius: 3,
                        offset: const Offset(3, 10)),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProgressIndicator(
                            currentStep: onboard.currentStep, totalSteps: 4),
                        const SizedBox(height: 16),
                        _buildAvatarSection(onboard),
                        const SizedBox(height: 24),
                        _buildNameField(context),
                        const SizedBox(height: 28),
                        Consumer<OnboardingProvider>(
                          builder: (context, onboardChild, _) {
                            final canProceed =
                                _nameController.text.trim().length >= 2;
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(GolfieRadii.pill),
                                  ),
                                  backgroundColor:
                                      canProceed ? GolfieColors.ink : GolfieColors.stone,
                                  foregroundColor:
                                      canProceed ? GolfieColors.white : GolfieColors.ink,
                                  elevation: 0,
                                ),
                                onPressed: canProceed
                                    ? () {
                                        debugPrint(
                                            '🟢 [ONBOARD] Profile Next — step: ${onboardChild.currentStep}');
                                        onboardChild.setProfileInfo(
                                          name: _nameController.text.trim(),
                                          level: SkillLevel.beginner,
                                        );
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const OnboardingSkillScreen(),
                                          ),
                                        );
                                      }
                                    : null,
                                child: const Text('Next'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(OnboardingProvider onboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your profile picture',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GolfieColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        GolfieAvatarStack(
          initials: [],
          totalPlayers: 1,
        ),
        const SizedBox(height: 8),
        Text(
          'Optional but recommended',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: GolfieColors.stone,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your name',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GolfieColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: GolfieColors.white,
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: GolfieColors.stone,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide: BorderSide(color: GolfieColors.ash),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide:
                  const BorderSide(color: GolfieColors.ink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide: const BorderSide(color: Color(0xFFDD6B6B)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide:
                  const BorderSide(color: Color(0xFFDD6B6B), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().length < 2) {
              return 'Minimum 2 characters';
            }
            return null;
          },
          onChanged: (value) {
            // Trigger rebuild of Consumer button when text length crosses threshold
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _nameController.text.isNotEmpty &&
                  _nameController.text.trim().length < 2
              ? Row(
                  key: const ValueKey('error'),
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: const Color(0xFFDD6B6B)),
                    const SizedBox(width: 4),
                    Text(
                      'Minimum 2 characters',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFDD6B6B),
                      ),
                    ),
                  ],
                )
              : _nameController.text.trim().length >= 2
                  ? Row(
                      key: const ValueKey('success'),
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: GolfieColors.mint),
                        const SizedBox(width: 4),
                        Text(
                          'Looks good',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: GolfieColors.mint,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}