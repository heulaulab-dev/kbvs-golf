import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildLogo(),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome back!',
                      textAlign: TextAlign.center,
                      style: GolfieTypography.textTheme.displaySmall!.copyWith(
                        color: GolfieColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      textAlign: TextAlign.center,
                      style: GolfieTypography.textTheme.bodyLarge!.copyWith(
                        color: GolfieColors.graphite,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration('Enter your email'),
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
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _rememberMe = !_rememberMe),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: GolfieColors.ink,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (value) => setState(
                                    () => _rememberMe = value ?? false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remember me',
                                style: GolfieTypography.textTheme.bodyMedium!
                                    .copyWith(color: GolfieColors.graphite),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            debugPrint(
                                '🔴 [AUTH] Forgot password? link tapped');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style:
                                GolfieTypography.textTheme.bodyMedium!.copyWith(
                              color: GolfieColors.marigold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GolfieRadii.pill),
                        ),
                        backgroundColor: GolfieColors.marigold,
                        foregroundColor: GolfieColors.white,
                        elevation: 0,
                      ),
                      onPressed: auth.loading
                          ? null
                          : () async {
                              debugPrint('🔴 [AUTH] Sign In button tapped');
                              final ctx = context;
                              if (_formKey.currentState!.validate()) {
                                debugPrint(
                                    '🔴 [AUTH] Sign In form valid — calling auth.signIn()');
                                await auth.signIn(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );
                                debugPrint(
                                    '🔴 [AUTH] signIn() done — hasError: ${auth.hasError}, isAuthenticated: ${auth.isAuthenticated}, errorMessage: ${auth.errorMessage}');
                                if (!auth.hasError &&
                                    auth.isAuthenticated &&
                                    ctx.mounted) {
                                  final onboard =
                                      ctx.read<OnboardingProvider>();
                                  debugPrint(
                                      '🔴 [AUTH] login OK — onboarding completed: ${onboard.completed}');
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
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: GolfieColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildSocialRow(),
                    const SizedBox(height: 28),
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
                            style:
                                GolfieTypography.textTheme.bodyMedium!.copyWith(
                              color: GolfieColors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: SvgPicture.asset(
        'assets/images/golfie-icon-only.svg',
        width: 72,
        height: 72,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GolfieTypography.textTheme.bodyMedium!.copyWith(
        color: GolfieColors.ink,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: GolfieColors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GolfieRadii.xl),
        borderSide: BorderSide(color: GolfieColors.ash),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GolfieRadii.xl),
        borderSide: const BorderSide(color: GolfieColors.ink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GolfieRadii.xl),
        borderSide: const BorderSide(color: Color(0xFFDD6B6B)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: GolfieColors.ash)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Or continue with',
            style: GolfieTypography.textTheme.bodySmall!.copyWith(
              color: GolfieColors.graphite,
            ),
          ),
        ),
        Expanded(child: Divider(color: GolfieColors.ash)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(
            icon: Icons.g_mobiledata,
            onTap: () {
              debugPrint('🔴 [AUTH] Continue with Google tapped');
              // TODO: wire up Google sign-in.
            }),
        const SizedBox(width: 16),
        _socialButton(
            icon: Icons.apple,
            onTap: () {
              debugPrint('🔴 [AUTH] Continue with Apple tapped');
              // TODO: wire up Apple sign-in.
            }),
        const SizedBox(width: 16),
        _socialButton(
            icon: Icons.facebook,
            onTap: () {
              debugPrint('🔴 [AUTH] Continue with Facebook tapped');
              // TODO: wire up Facebook sign-in.
            }),
      ],
    );
  }

  Widget _socialButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GolfieRadii.pill),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GolfieColors.white,
          border: Border.all(color: GolfieColors.ash),
        ),
        child: Icon(icon, color: GolfieColors.ink),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
