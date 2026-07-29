import 'package:flutter/material.dart';
import 'package:golfie/core/theme/golfie_colors.dart';

/// Stack of overlapping avatar circles with an overflow counter.
///
/// Renders up to three initial circles. When the player count exceeds the
/// number of initials supplied, an additional overflow circle shows the
/// `+N` remainder. Uses Golfie's Midnight + Periwinkle palette so it sits
/// naturally inside GolfieCollageCard surfaces.
class GolfieAvatarStack extends StatelessWidget {
  const GolfieAvatarStack({
    super.key,
    required this.totalPlayers,
    this.initials,
  });

  /// Total number of players. Used to compute the overflow count.
  final int totalPlayers;

  /// Optional list of up to three initials to render. When fewer are given
  /// or the total exceeds the list length, an overflow circle fills in.
  final List<String>? initials;

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final provided = initials ?? const [];
    final visibleCount = provided.length.clamp(0, _maxVisible);
    final overflow = totalPlayers - visibleCount;
    final children = <Widget>[];

    for (var i = 0; i < visibleCount; i++) {
      children.add(_AvatarCircle(label: provided[i], color: GolfieColors.ink));
    }
    if (overflow > 0) {
      children.add(_AvatarCircle(
        label: '+$overflow',
        color: GolfieColors.periwinkle,
      ));
    }

    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          for (var i = 0; i < children.length; i++)
            Positioned(
              left: i * 22.0,
              child: children[i],
            ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: GolfieColors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: GolfieColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}