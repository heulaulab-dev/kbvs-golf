import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../core/theme/golfie_typography.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
                      'Forgot your password?',
                      textAlign: TextAlign.center,
                      style: GolfieTypography.textTheme.displaySmall!.copyWith(
                        color: GolfieColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter email to receive reset link',
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
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GolfieRadii.pill),
                        ),
                        backgroundColor: GolfieColors.ink,
                        foregroundColor: GolfieColors.white,
                        elevation: 0,
                      ),
                      onPressed: auth.loading
                          ? null
                          : () async {
                              debugPrint(
                                  '🟡 [AUTH] Send Link (forgot password) button tapped');
                              final ctx = context;
                              if (_formKey.currentState!.validate()) {
                                debugPrint(
                                    '🟡 [AUTH] forgot password form valid — calling auth.forgotPassword()');
                                await auth.forgotPassword(
                                    _emailController.text.trim());
                                debugPrint(
                                    '🟡 [AUTH] forgotPassword() done — hasError: ${auth.hasError}, errorMessage: ${auth.errorMessage}');
                                if (!auth.hasError && ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Reset link sent to your email'),
                                      backgroundColor: GolfieColors.mint,
                                    ),
                                  );
                                  final ctx2 = ctx;
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    if (ctx2.mounted) Navigator.pop(ctx2);
                                  });
                                } else if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(auth.errorMessage ??
                                          'Could not send link'),
                                      backgroundColor: GolfieColors.ink,
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
                          : const Text('Send Link'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Back to Sign in',
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
