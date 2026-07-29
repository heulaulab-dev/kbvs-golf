import 'package:flutter/material.dart';
import '../core/theme/golfie_colors.dart';

// Placeholder for future AI caddy tip analysis screen
// This will integrate with shot data, course layout, and AI recommendations

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Shot Analysis')),
      body: Center(
        child: Column(
          children: [
            const Icon(Icons.play_arrow_outlined, size: 64, color: GolfieColors.stone),
            const SizedBox(height: 12),
            Text('AI Shot Suggestions', style: textTheme.titleLarge?.copyWith(color: GolfieColors.ink)),
            const SizedBox(height: 4),
            Text('Coming in v1.1 — select club based on conditions', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.stone)),
          ],
        ),
      ),
    );
  }
}
