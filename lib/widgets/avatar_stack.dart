import 'package:flutter/material.dart';

/// Avatar stack as specified in PRD §3.3.
/// Custom Stack + ClipOval + offset positioning – no third‑party widget.
/// Three visible avatars with 20 px overflow, “+N more” badge when >3.
class AvatarStack extends StatelessWidget {
  final int totalPlayers; // total number of registered players
  final List<String>? initials; // optional list of initials; if null, generate generic ones

  const AvatarStack({super.key, required this.totalPlayers, this.initials})
      : assert(initials == null || initials.length >= 3, 'Need at least 3 initials if provided');

  @override
  Widget build(BuildContext context) {
    // Determine how many avatars to show (max 3)
    final showCount = totalPlayers <= 3 ? totalPlayers : 3;
    final remaining = totalPlayers > 3 ? totalPlayers - 3 : 0;

    // Generate initials list if not provided
    final List<String> names = initials ??
        List.generate(showCount, (i) => String.fromCharCode(65 + i)); // A, B, C ...

    return Container(
      // Height matches avatar diameter (40 px per spec)
      height: 40,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Draw avatars from left to right with 20 px overlap (each avatar radius 20)
          for (int i = 0; i < showCount; i++)
            Positioned(
              left: i * -20, // negative overlap
              child: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      names[i],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // If there are remaining players, show a badge on top of the third avatar
          if (remaining > 0)
            Positioned(
              left: -20 * 2, // same x as third avatar
              child: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // gray-100 bg
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+${remaining}',
                      style: TextStyle(
                        fontSize: 11, // 11 px caption
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper widget to embed avatar stack with additional styling.
// Not required; use AvatarStack directly.
