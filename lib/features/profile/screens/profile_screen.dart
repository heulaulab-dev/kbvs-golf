import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/splash_screen.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import 'edit_profile_screen.dart';

/// Combined profile + settings screen. Shows account info from Supabase
/// session, preferences from onboarding, and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _displayName(OnboardingProvider onboard, AuthProvider auth) {
    final name = onboard.userName;
    if (name != null && name.trim().isNotEmpty) return name;
    final email = auth.user?.email ?? '';
    return email.split('@').first;
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboard = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      appBar: AppBar(
        backgroundColor: GolfieColors.canvas,
        elevation: 0,
        title: Text(
          'Profile',
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
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: GolfieColors.mint.withValues(alpha: 0.3),
                    child: Text(
                      _initials(_displayName(onboard, auth)),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: GolfieColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _displayName(onboard, auth),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: GolfieColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: GolfieColors.stone,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACCOUNT section
            _buildSectionLabel('ACCOUNT'),
            const SizedBox(height: 8),
            _buildListItem(
              icon: Icons.edit_outlined,
              label: 'Edit profile',
              trailing: const Icon(Icons.chevron_right,
                  color: GolfieColors.stone),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // PREFERENCES section
            _buildSectionLabel('PREFERENCES'),
            const SizedBox(height: 8),
            _buildToggleItem(
              label: 'Nearby tournaments',
              value: onboard.showNearby,
              onChanged: (v) => onboard.updatePreferences(
                showNearby: v,
                emailNotifications: onboard.emailNotifications,
              ),
            ),
            _buildToggleItem(
              label: 'Email notifications',
              value: onboard.emailNotifications,
              onChanged: (v) => onboard.updatePreferences(
                showNearby: onboard.showNearby,
                emailNotifications: v,
              ),
            ),

            const SizedBox(height: 24),

            // ABOUT section
            _buildSectionLabel('ABOUT'),
            const SizedBox(height: 8),
            _buildListItem(
              icon: Icons.info_outline,
              label: 'App version',
              trailing: Text(
                AppConfig.instance.appVersion,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: GolfieColors.stone,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GolfieColors.white,
                  foregroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GolfieRadii.pill),
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _confirmLogout(context),
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: GolfieColors.stone,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GolfieColors.white,
        borderRadius: BorderRadius.circular(GolfieRadii.xl),
        border: Border.all(color: GolfieColors.ash),
      ),
      child: ListTile(
        leading: Icon(icon, color: GolfieColors.ink),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: GolfieColors.ink,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: GolfieColors.white,
        borderRadius: BorderRadius.circular(GolfieRadii.xl),
        border: Border.all(color: GolfieColors.ash),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: GolfieColors.ink,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: GolfieColors.mint,
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GolfieColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
        ),
        title: Text(
          'Log out?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
        content: Text(
          'You will need to sign in again to access your account.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: GolfieColors.graphite,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const SplashScreen(),
          ),
          (route) => false,
        );
      }
    }
  }
}
