import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../core/theme/golfie_typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_password_field.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _token; // Extracted from deep link route arguments in production
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // EXTRACT TOKEN FROM DEEP LINK IN PRODUCTION:
    // final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // _token = args['token'];
    // If _token is null, show instructional UI
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return _buildScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildLogo(),
            const SizedBox(height: 20),
            Text(
              'Reset Password',
              textAlign: TextAlign.center,
              style: GolfieTypography.textTheme.displaySmall!.copyWith(
                  color: GolfieColors.ink, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              'Link expired or invalid. Please go back to Forgot Password '
              'screen and request a new reset link.',
              textAlign: TextAlign.center,
              style: GolfieTypography.textTheme.bodyLarge!
                  .copyWith(color: GolfieColors.stone),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return _buildScaffold(
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
                  'Create new password',
                  textAlign: TextAlign.center,
                  style: GolfieTypography.textTheme.displaySmall!.copyWith(
                    color: GolfieColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set a new secure password below',
                  textAlign: TextAlign.center,
                  style: GolfieTypography.textTheme.bodyLarge!.copyWith(
                    color: GolfieColors.graphite,
                  ),
                ),
                const SizedBox(height: 32),
                _buildLabel('New Password'),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _passwordController,
                  hintText: 'New Password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter new password';
                    }
                    if (value.length < 6) {
                      return 'Must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel('Confirm New Password'),
                const SizedBox(height: 8),
                AuthPasswordField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm New Password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorText!,
                      style: GolfieTypography.textTheme.bodySmall!
                          .copyWith(color: const Color(0xFF8A2525)),
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
                  onPressed: auth.loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _errorText = null);

                          // PRODUCTION IMPLEMENTATION: This is an MVP placeholder.
                          // The real flow requires deep link token extraction and:
                          // 1. await _client.auth.signInWithOtp(token: _token!);
                          // 2. await _client.auth.updateUser(UserAttributes(password: newPassword));
                          //
                          // BUG CARRIED OVER FROM ORIGINAL: auth.resetPassword()
                          // below requires an `email`, but this screen has no
                          // email field or deep-link-supplied email to give it.
                          // Passing an empty string will fail against a real
                          // backend. Fix this by either (a) threading the email
                          // through the reset-link deep link alongside the
                          // token, or (b) dropping `email` from
                          // AuthProvider.resetPassword's signature if the
                          // backend can resolve the user from the token alone.
                          final ctx = context;
                          await auth.resetPassword(
                            email: '', // TODO: see note above — not wired.
                            newPassword: _passwordController.text,
                            token: _token!,
                          );

                          if (!auth.hasError && ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Password updated successfully'),
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
                            setState(() {
                              _errorText = auth.errorMessage ?? 'Failed';
                            });
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
                      : const Text('Reset Password'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScaffold({required Widget child}) {
    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: child,
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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
