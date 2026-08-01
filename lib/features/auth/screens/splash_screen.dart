import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../providers/auth_provider.dart';
import '../../../features/onboarding/providers/onboarding_provider.dart';
import '../../../features/onboarding/screens/onboarding_welcome_screen.dart';
import '../../../screens/home_screen.dart';
import '../screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthAndOnboarding());
  }

  Future<void> _checkAuthAndOnboarding() async {
    if (!mounted) return;

    try {
      final auth = context.read<AuthProvider>();
      final onboard = context.read<OnboardingProvider>();

      // Wait for auth state to stabilize
      while (auth.loading && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!mounted) return;

      // Minimum 1 second splash duration
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      if (auth.isAuthenticated) {
        // User is logged in — check onboarding status
        if (onboard.completed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingWelcomeScreen()),
          );
        }
      } else {
        // Not authenticated — go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: GolfieColors.mint),
          ],
        ),
      ),
    );
  }
}