import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../core/theme/golfie_shadows.dart';
import '../../../core/theme/golfie_typography.dart';
import '../../../features/onboarding/providers/onboarding_provider.dart';
import '../../../features/onboarding/screens/onboarding_welcome_screen.dart';
import '../../../screens/home_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_password_field.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildCard(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: GolfieColors.white,
                boxShadow: GolfieShadows.xl,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(key: _formKey, child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: GolfieTypography.textTheme.displaySmall!.copyWith(
                        color: GolfieColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: GolfieTypography.textTheme.bodyLarge!.copyWith(
                        color: GolfieColors.graphite,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(GolfieRadii.xl),
                          borderSide: BorderSide(color: GolfieColors.ash),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(GolfieRadii.xl),
                          borderSide: BorderSide(
                            color: GolfieColors.ink,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(GolfieRadii.xl),
                          borderSide:
                              const BorderSide(color: Color(0xFFDD6B6B)),
                        ),
                        hintText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter email';
                        }
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AuthPasswordField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter password';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          debugPrint('🔴 [AUTH] Forgot password? link tapped');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: GolfieTypography.textTheme.bodyMedium!
                              .copyWith(color: GolfieColors.graphite),
                        ),
                      ),
                    ),
                      if (auth.hasError &&
                          auth.errorMessage != null &&
                          _formKey.currentState!.validate())
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: Text(
                            auth.errorMessage!,
                            style: GolfieTypography.textTheme.bodySmall!
                                .copyWith(color: const Color(0xFF8A2525)),
                          ),
                        ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GolfieRadii.pill),
                        ),
                        backgroundColor: GolfieColors.ink,
                        foregroundColor: GolfieColors.white,
                      ),
                      onPressed: auth.loading ? null : () async {
                        debugPrint('🔴 [AUTH] Sign In button tapped');
                        final ctx = context;
                        if (_formKey.currentState!.validate()) {
                          debugPrint('🔴 [AUTH] Sign In form valid — calling auth.signIn()');
                          await auth.signIn(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                          debugPrint('🔴 [AUTH] signIn() done — hasError: ${auth.hasError}, isAuthenticated: ${auth.isAuthenticated}, errorMessage: ${auth.errorMessage}');
                          if (!auth.hasError &&
                              auth.isAuthenticated &&
                              ctx.mounted) {
                            final onboard = ctx.read<OnboardingProvider>();
                            debugPrint('🔴 [AUTH] login OK — onboarding completed: ${onboard.completed}');
                            Navigator.pushReplacement(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => onboard.completed
                                    ? const HomeScreen()
                                    : const OnboardingWelcomeScreen(),
                              ),
                            );
                          } else if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  auth.errorMessage ?? 'Login failed',
                                ),
                                backgroundColor: GolfieColors.marigold,
                              ),
                            );
                          }
                        }
                      },
                      child: auth.loading
                          ? const CircularProgressIndicator(
                              color: GolfieColors.white,
                            )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GolfieTypography.textTheme.bodyMedium!
                              .copyWith(color: GolfieColors.graphite),
                        ),
                        GestureDetector(
                          onTap: () {
                            debugPrint('🔴 [AUTH] "Create one" link tapped');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Create one',
                            style: GolfieTypography.textTheme.bodyMedium!
                                .copyWith(
                              color: GolfieColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
