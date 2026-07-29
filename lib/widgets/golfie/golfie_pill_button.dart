import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golfie/core/theme/golfie_colors.dart';

/// Filled pill-shaped primary action button.
///
/// Tapping plays a brief scale-down animation and a light haptic. When
/// [onPressed] is null the button renders in a disabled state with no
/// interaction available.
class GolfiePillButton extends StatefulWidget {
  const GolfiePillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = GolfieColors.papaya,
    this.foregroundColor = GolfieColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  State<GolfiePillButton> createState() => _GolfiePillButtonState();
}

class _GolfiePillButtonState extends State<GolfiePillButton> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _pressed = true);
  }

  void _onTapEnd(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapEnd,
          onTapCancel: _onTapCancel,
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: widget.foregroundColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.foregroundColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}