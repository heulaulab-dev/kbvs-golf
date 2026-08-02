import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';
import '../../../core/theme/golfie_shadows.dart';
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
                    'Forgot your password?',
                    style: GolfieTypography.textTheme.displaySmall!.copyWith(
                      color: GolfieColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter email to receive reset link',
                    style: GolfieTypography.textTheme.bodyLarge!.copyWith(
                      color: GolfieColors.graphite,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ash)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ink, width: 1.5)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: const BorderSide(color: Color(0xFFDD6B6B))),
                      hintText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter email';
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GolfieRadii.pill)),
                      backgroundColor: GolfieColors.ink,
                      foregroundColor: GolfieColors.white,
                    ),
                    onPressed: auth.loading ? null : () async {
                      debugPrint('🟡 [AUTH] Send Link (forgot password) button tapped');
                      final ctx = context;
                      if (_formKey.currentState!.validate()) {
                        debugPrint('🟡 [AUTH] forgot password form valid — calling auth.forgotPassword()');
                        await auth.forgotPassword(_emailController.text.trim());
                        debugPrint('🟡 [AUTH] forgotPassword() done — hasError: ${auth.hasError}, errorMessage: ${auth.errorMessage}');
                        if (!auth.hasError && ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Reset link sent to your email'), backgroundColor: GolfieColors.mint),
                          );
                          final ctx2 = ctx;
                          Future.delayed(const Duration(seconds: 3), () {
                            if (ctx2.mounted) Navigator.pop(ctx2);
                          });
                        } else if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(auth.errorMessage ?? 'Could not send link'), backgroundColor: GolfieColors.marigold),
                          );
                        }
                      }
                    },
                    child: auth.loading
                        ? const CircularProgressIndicator(color: GolfieColors.white)
                        : const Text('Send Link'),
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
    super.dispose();
  }
}