import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../providers/auth_provider.dart';
import '../../features/onboarding/providers/onboarding_provider.dart'; // Correct relative path

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
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      } else {
        // Not authenticated — go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading auth state'), backgroundColor: Colors.red),
        );
        Navigator.pushReplacementNamed(context, '/login');
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