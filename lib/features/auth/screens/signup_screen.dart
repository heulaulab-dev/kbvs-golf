import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../core/theme/golfie_shadows.dart';
import '../../../core/theme/golfie_typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_password_field.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showConfirmWarning = false;
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
                      'Registration',
                      textAlign: TextAlign.center,
                      style: GolfieTypography.textTheme.displaySmall!.copyWith(
                        color: GolfieColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the fields below to get started',
                      textAlign: TextAlign.center,
                      style: GolfieTypography.textTheme.bodyLarge!.copyWith(
                        color: GolfieColors.graphite,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLabel('Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      decoration: _fieldDecoration('Enter your name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Password'),
                    const SizedBox(height: 8),
                    AuthPasswordField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 chars';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Confirm Password'),
                    const SizedBox(height: 8),
                    AuthPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password';
                        }
                        if (value != _passwordController.text) {
                          _showConfirmWarning = true;
                          return 'Passwords do not match';
                        }
                        _showConfirmWarning = false;
                        return null;
                      },
                    ),
                    if (_showConfirmWarning)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Passwords must match',
                          style: GolfieTypography.textTheme.bodySmall!
                              .copyWith(color: const Color(0xFF8A2525)),
                        ),
                      ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
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
                              onChanged: (value) =>
                                  setState(() => _rememberMe = value ?? false),
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
                      // Validate inside the callback — _formKey.currentState
                      // can be null during the first build.
                      onPressed: auth.loading
                          ? null
                          : () async {
                              debugPrint(
                                  '🔴 [AUTH] Get Started (signup) button tapped');
                              final ctx = context;
                              if (_formKey.currentState!.validate() &&
                                  !_showConfirmWarning) {
                                debugPrint(
                                    '🔴 [AUTH] signup form valid — calling auth.signUp()');
                                await auth.signUp(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );
                                debugPrint(
                                    '🔴 [AUTH] signUp() done — hasError: ${auth.hasError}, isAuthenticated: ${auth.isAuthenticated}, errorMessage: ${auth.errorMessage}');
                                if (!auth.hasError &&
                                    auth.isAuthenticated &&
                                    ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Check email for verification link',
                                      ),
                                      backgroundColor: GolfieColors.mint,
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    ctx,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                } else if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        auth.errorMessage ?? 'Signup failed',
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
                          : const Text('Sign up'),
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
                          'Already have an account? ',
                          style: GolfieTypography.textTheme.bodyMedium!
                              .copyWith(color: GolfieColors.graphite),
                        ),
                        GestureDetector(
                          onTap: () {
                            debugPrint(
                                '🔴 [AUTH] "Sign in" link tapped from signup');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign in',
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
    // TODO: swap Icons.golf_course for the actual brand mark asset.
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: GolfieColors.ink,
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          boxShadow: GolfieShadows.xl,
        ),
        child: const Icon(
          Icons.golf_course,
          color: GolfieColors.white,
          size: 32,
        ),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
