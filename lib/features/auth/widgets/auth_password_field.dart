import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/golfie_colors.dart';
import '../../../core/theme/golfie_radii.dart';

/// Password input with an inline visibility toggle.
///
/// Shared by login, signup, and reset-password screens so the field
/// styling and toggle behavior stay consistent. Exposes [validator]
/// for [Form] integration.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.hintText = 'Password',
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(GolfieRadii.xl),
      borderSide: BorderSide(color: GolfieColors.ash),
    );
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          borderSide: BorderSide(color: GolfieColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          borderSide: const BorderSide(color: Color(0xFFDD6B6B)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: GolfieColors.stone,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _obscure = !_obscure);
          },
        ),
      ),
    );
  }
}