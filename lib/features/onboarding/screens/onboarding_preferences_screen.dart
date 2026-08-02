import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../screens/home_screen.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/progress_indicator.dart';

/// Preferences screen — collects location and notification preferences.
class OnboardingPreferencesScreen extends StatefulWidget {
  const OnboardingPreferencesScreen({super.key});

  @override
  State<OnboardingPreferencesScreen> createState() => _OnboardingPreferencesScreenState();
}

class _OnboardingPreferencesScreenState extends State<OnboardingPreferencesScreen> {
  // Form state
  final TextEditingController _locationController = TextEditingController();

  // Toggle states (synced with provider)
  bool _showNearby = true;
  bool _emailNotifications = true;

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
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator at top (step 3 of 4)
                        ProgressIndicator(currentStep: onboard.currentStep, totalSteps: 4),
                        const SizedBox(height: 16),

                        // Subheading
                        Text(
                          'Tell us about your preferences',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.72,
                            color: GolfieColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Help us recommend tournaments near you',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: GolfieColors.stone,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Location search field
                        _buildLocationField(context),
                        const SizedBox(height: 28),

                        // Preference toggles
                        _buildPreferenceToggle('Show me nearby tournaments', _showNearby, (value) => _toggleNearby(value, onboard)),
                        const SizedBox(height: 16),
                        _buildPreferenceToggle('Email notifications for new tournaments', _emailNotifications, (value) => _toggleEmail(value, onboard)),
                        const SizedBox(height: 28),

                        // Finish button — ink filled pill
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
                                onPressed: () => _handleFinish(onboardChild),
                                child: const Text('Finish Setup'),
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

  Widget _buildLocationField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your location (area or club name)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GolfieColors.ink,
          ),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: _locationController,
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
            hintText: 'e.g., Senayan, Kemang, Bintaro',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: GolfieColors.stone,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: const Icon(
              Icons.search,
              color: GolfieColors.graphite,
            ),
          ),
          onChanged: (value) {
            // Live update — no validation required, just store the value
          },
        ),
      ],
    );
  }

  Widget _buildPreferenceToggle(String label, bool isChecked, void Function(bool) onChanged) {
    return Row(
      children: [
        // Label text
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: GolfieColors.ink,
            ),
          ),
        ),
        // Toggle switch
        Switch(
          value: isChecked,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _toggleNearby(bool value, OnboardingProvider onboard) {
    setState(() {
      _showNearby = value;
    });
  }

  void _toggleEmail(bool value, OnboardingProvider onboard) {
    setState(() {
      _emailNotifications = value;
    });
  }

  // Handle finish — complete onboarding and navigate to HomeScreen
  void _handleFinish(OnboardingProvider onboard) {
    // Collect final values
    final location = _locationController.text.trim();

    // Save all preferences BEFORE completing onboarding
    onboard.setLocationAndPreferences(
      location: location,
      showNearby: _showNearby,
      emailNotifications: _emailNotifications,
    );
    onboard.finishOnboarding();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Setup complete! Welcome to Golfie!'),
          backgroundColor: GolfieColors.mint,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to home screen after brief delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}