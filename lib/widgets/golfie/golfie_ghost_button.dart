import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golfie/core/theme/golfie_colors.dart';

/// Outlined pill-shaped secondary action button.
///
/// Provides the same scale-and-haptic interaction model as
/// [GolfiePillButton] but renders as a ghost-style outline. Use for actions
/// that should not compete with the primary action on the same surface.
class GolfieGhostButton extends StatefulWidget {
  const GolfieGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.borderColor = GolfieColors.ink,
    this.foregroundColor = GolfieColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color borderColor;
  final Color foregroundColor;

  @override
  State<GolfieGhostButton> createState() => _GolfieGhostButtonState();
}

class _GolfieGhostButtonState extends State<GolfieGhostButton> {
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
              color: GolfieColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: widget.borderColor, width: 1.5),
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
