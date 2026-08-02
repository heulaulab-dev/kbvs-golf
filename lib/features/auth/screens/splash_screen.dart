import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_spacing.dart';
import '../../../widgets/golfie/golfie_index.dart';
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

      // Wait for auth state to stabilize — bounded to 3 seconds so a cold
      // start via deep link has time for the PKCE code exchange to finish,
      // but we never hang the splash forever if the stream stays quiet.
      if (auth.loading) {
        final completer = Completer<void>();
        late VoidCallback listener;
        listener = () {
          if (!auth.loading) {
            auth.removeListener(listener);
            if (!completer.isCompleted) completer.complete();
          }
        };
        auth.addListener(listener);
        await Future.any([
          completer.future,
          Future.delayed(const Duration(seconds: 3)),
        ]);
        auth.removeListener(listener);
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
            GolfieHero(
              title: 'Golfie',
              subtitle: 'Jakarta golf tournaments',
            ),
            const SizedBox(height: GolfieSpacing.s32),
            CircularProgressIndicator(color: GolfieColors.mint),
          ],
        ),
      ),
    );
  }
}