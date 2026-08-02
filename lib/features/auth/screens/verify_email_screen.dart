import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_typography.dart';
import '../../../features/onboarding/screens/onboarding_welcome_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

/// Shown after a successful email/password signup.
///
/// The account exists but the email is not confirmed yet, so there is no
/// session. This screen tells the user to check their inbox and polls the
/// server in the background — as soon as the confirmation link is clicked
/// (in a browser or on another device) the session becomes available and we
/// auto-navigate to onboarding.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _pollTimer;
  bool _sentAgain = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.refreshSessionSilently();
      if (auth.isAuthenticated && mounted) {
        _pollTimer?.cancel();
        _goToOnboarding();
      }
    });
  }

  void _goToOnboarding() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingWelcomeScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.mark_email_read_outlined,
                  size: 64, color: GolfieColors.mint),
              const SizedBox(height: 24),
              Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: GolfieTypography.textTheme.displaySmall!.copyWith(
                  color: GolfieColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to\n${widget.email}',
                textAlign: TextAlign.center,
                style: GolfieTypography.textTheme.bodyLarge!.copyWith(
                  color: GolfieColors.graphite,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Click the link in your email — we\'ll sign you in '
                'and continue automatically.',
                textAlign: TextAlign.center,
                style: GolfieTypography.textTheme.bodyMedium!.copyWith(
                  color: GolfieColors.graphite,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: GolfieColors.mint,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Waiting for verification…',
                    style: GolfieTypography.textTheme.bodyMedium!.copyWith(
                      color: GolfieColors.graphite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return TextButton(
                    onPressed: auth.loading
                        ? null
                        : () async {
                            await auth.sendVerificationEmailAgain(
                              widget.email,
                            );
                            if (!context.mounted) return;
                            if (auth.hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    auth.errorMessage ??
                                        'Failed to resend. Try again.',
                                  ),
                                  backgroundColor: GolfieColors.marigold,
                                ),
                              );
                            } else {
                              setState(() => _sentAgain = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Verification email resent',
                                  ),
                                  backgroundColor: GolfieColors.mint,
                                ),
                              );
                            }
                          },
                    child: Text(
                      _sentAgain ? 'Resent — check your inbox' : 'Resend verification email',
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
