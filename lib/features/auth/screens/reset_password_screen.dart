import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_typography.dart';
import '../../../core/theme/golfie_radii.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [_buildCard()]),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Padding(padding: const EdgeInsets.only(bottom: 24), child: ClipRRect(
      borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
      child: Container(color: GolfieColors.white, padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset your password', style: GoogleFonts.lora(fontSize: 46, color: GolfieColors.ink)),
          const SizedBox(height: 8),
          TextFormField(controller: _passwordController, obscureText: true, decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ash)))),
          const SizedBox(height: 20),
          TextFormField(controller: _confirmPasswordController, obscureText: true, decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(GolfieRadii.xl), borderSide: BorderSide(color: GolfieColors.ash)))),
          const SizedBox(height: 28),
          ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GolfieRadii.pill)), backgroundColor: GolfieColors.ink), onPressed: () {}, child: const Text('Reset Password')),
        ],
      ))),
    ));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
