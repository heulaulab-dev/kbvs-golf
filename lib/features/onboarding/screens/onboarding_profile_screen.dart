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

/// Profile screen — collects user's name and profile picture.
class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProgressIndicator(currentStep: onboard.currentStep, totalSteps: 4),
                        const SizedBox(height: 16),
                        _buildAvatarSection(onboard),
                        const SizedBox(height: 24),
                        _buildNameField(context),
                        const SizedBox(height: 28),
                        Consumer<OnboardingProvider>(
                          builder: (context, onboardChild, _) {
                            final canProceed = _nameController.text.trim().length >= 2;
                            return SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(GolfieRadii.pill),
                                  ),
                                  backgroundColor: canProceed ? GolfieColors.ink : GolfieColors.stone,
                                  foregroundColor: canProceed ? GolfieColors.white : GolfieColors.ink,
                                ),
                                onPressed: canProceed
                                    ? () {
                                        debugPrint('🟢 [ONBOARD] Profile Next — step: ${onboardChild.currentStep}');
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide: BorderSide(color: GolfieColors.ash),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide: BorderSide(color: GolfieColors.ink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide: const BorderSide(color: Color(0xFFDD6B6B)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              borderSide: const BorderSide(color: Color(0xFFDD6B6B), width: 2),
            ),
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: GolfieColors.stone,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            if (context.mounted) {}
          },
        ),
        SizedBox(
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_nameController.text.isNotEmpty && _nameController.text.length < 2)
                Text(
                  'Minimum 2 characters',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Color(0xFF8A2525),
                  ),
                ),
              if (_nameController.text.length >= 2)
                Icon(
                  Icons.check_circle,
                  color: GolfieColors.mint,
                  size: 16,
                ),
            ],
          ),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}