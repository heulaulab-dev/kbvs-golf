import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../tournament/models/skill_level.dart';
import '../../onboarding/providers/onboarding_provider.dart';

/// Edit name, skill level, and location. Saves to OnboardingProvider.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  SkillLevel? _skillLevel;

  @override
  void initState() {
    super.initState();
    final onboard = context.read<OnboardingProvider>();
    _nameController = TextEditingController(text: onboard.userName ?? '');
    _locationController = TextEditingController(text: onboard.location ?? '');
    _skillLevel = onboard.skillLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboard = context.watch<OnboardingProvider>();
    final canSave = _nameController.text.trim().length >= 2;

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      appBar: AppBar(
        backgroundColor: GolfieColors.canvas,
        elevation: 0,
        title: Text(
          'Edit profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            Text(
              'Name',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Skill level
            Text(
              'Skill level',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: SkillLevel.values.length,
              itemBuilder: (context, index) {
                final skill = SkillLevel.values[index];
                final selected = _skillLevel == skill;
                return GestureDetector(
                  onTap: () => setState(() => _skillLevel = skill),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? GolfieColors.mint.withValues(alpha: 0.2)
                          : GolfieColors.white,
                      borderRadius: BorderRadius.circular(GolfieRadii.lg),
                      border: Border.all(
                        color: selected ? GolfieColors.mint : GolfieColors.ash,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _skillIcon(skill),
                          color: selected
                              ? GolfieColors.mint
                              : GolfieColors.graphite,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _skillLabel(skill),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: GolfieColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Location field
            Text(
              'Home course or area',
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
                filled: true,
                fillColor: GolfieColors.white,
                hintText: 'e.g. Pondok Indah, Jakarta',
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canSave ? GolfieColors.ink : GolfieColors.stone,
                  foregroundColor: canSave ? GolfieColors.white : GolfieColors.ink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GolfieRadii.pill),
                  ),
                ),
                onPressed: canSave ? () => _save(onboard) : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _skillIcon(SkillLevel level) {
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

  String _skillLabel(SkillLevel level) {
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

  void _save(OnboardingProvider onboard) {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();

    onboard.setProfileInfo(
      name: name,
      level: _skillLevel ?? SkillLevel.beginner,
    );
    onboard.setLocationAndPreferences(
      location: location,
      showNearby: onboard.showNearby,
      emailNotifications: onboard.emailNotifications,
    );

    if (mounted) Navigator.pop(context);
  }
}
