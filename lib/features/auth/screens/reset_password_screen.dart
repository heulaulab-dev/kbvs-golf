import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../core/theme/golfie_shadows.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _token; // Extracted from deep link route arguments in production

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
    final auth = context.read<AuthProvider>();

    // Check if we have a valid token — if not, show error state
    if (_token == null) {
      return Scaffold(
        backgroundColor: GolfieColors.canvas,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset Password',
                              style: GolfieTypography.textTheme.displaySmall!
                                  .copyWith(color: GolfieColors.ink),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Link expired or invalid. Please go back to Forgot Password screen and request a new reset link.',
                              style: GolfieTypography.textTheme.bodyLarge!
                                  .copyWith(color: GolfieColors.stone),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(GolfieRadii.pill),
                                ),
                                backgroundColor: GolfieColors.ink,
                                foregroundColor: GolfieColors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Go Back'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildCard(context, auth)],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AuthProvider auth) {
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
                'Create new password',
                style: GolfieTypography.textTheme.displaySmall!.copyWith(
                  color: GolfieColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set a new secure password below',
                style: GolfieTypography.textTheme.bodyLarge!.copyWith(
                  color: GolfieColors.graphite,
                ),
              ),
              const SizedBox(height: 32),
              AuthPasswordField(
                controller: _passwordController,
                hintText: 'New Password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter new password';
                  }
                  if (value.length < 6) return 'Must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GolfieRadii.pill)),
                  backgroundColor: GolfieColors.ink,
                  foregroundColor: GolfieColors.white,
                ),
                onPressed: auth.loading || !_formKey.currentState!.validate() ? null : () async {
                  if (!_formKey.currentState!.validate()) return;

                  // PRODUCTION IMPLEMENTATION: This is an MVP placeholder.
                  // The real flow requires deep link token extraction and:
                  // 1. await _client.auth.signInWithOtp(token: _token!);
                  // 2. await _client.auth.updateUser(UserAttributes(password: newPassword));
                  //
                  // For now, calling AuthProvider's resetPassword which expects the token.
                  // Note: resetPassword method needs the email as well — you'd typically store it
                  // from the original reset request or include it in the deep link.
                  final ctx = context;
                  await auth.resetPassword(
                    email: _emailController.text, // Placeholder — need to obtain actual email
                    newPassword: _passwordController.text,
                    token: _token!,
                  );

                  if (!auth.hasError && ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Password updated successfully'), backgroundColor: GolfieColors.mint));
                    Navigator.pushReplacement(
                      ctx,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Failed'), backgroundColor: GolfieColors.marigold));
                  }
                },
                child: auth.loading
                    ? const CircularProgressIndicator(color: GolfieColors.white)
                    : const Text('Reset Password'),
              ),
            ],
            )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}