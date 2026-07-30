import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_typography.dart';
import '../../../core/theme/golfie_radii.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showConfirmWarning = false;

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
    final auth = context.read<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
        child: Container(
          color: GolfieColors.white,
          padding: const EdgeInsets.all(24),
          child: Form(key: _formKey, child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create your Golfie account', style: GoogleFonts.lora(fontSize: 46, color: GolfieColors.ink)),
              const SizedBox(height: 8),
              Text('Join the local golf community', style: GoogleFonts.inter(color: GolfieColors.graphite)),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ash)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ink, width: 1.5)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: const BorderSide(color: Color(0xFFDD6B6B))),
                  hintText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value!.length < 6) return 'Password must be at least 6 chars';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ash)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ink, width: 1.5)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: const BorderSide(color: Color(0xFFDD6B6B))),
                  hintText: 'Confirm Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirm password';
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
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Text('Passwords must match', style: GoogleFonts.inter(color: Color(0xFF8A2525), fontSize: 13)),
                ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GolfieRadii.pill)),
                  backgroundColor: GolfieColors.ink,
                  foregroundColor: GolfieColors.white,
                ),
                onPressed: auth.loading || !_formKey.currentState!.validate() || _showConfirmWarning
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() && !_showConfirmWarning) {
                          await auth.signUp(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                          if (!auth.hasError && auth.isAuthenticated) {
                            // Email verification handled by Supabase — user should check inbox
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Check email for verification link'), backgroundColor: GolfieColors.mint),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(auth.errorMessage ?? 'Signup failed'), backgroundColor: GolfieColors.marigold),
                            );
                          }
                        }
                      },
                child: auth.loading
                    ? const CircularProgressIndicator(color: GolfieColors.white)
                    : const Text('Get Started'),
              ),
            ],
          )),
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