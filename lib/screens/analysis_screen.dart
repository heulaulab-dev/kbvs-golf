import 'package:flutter/material.dart';

// Placeholder for future AI caddy tip analysis screen
// This will integrate with shot data, course layout, and AI recommendations

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shot Analysis')),
      body: const Center(
        child: Column(
          children: [
            Icon(Icons.play_arrow_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('AI Shot Suggestions'),
            Text('Coming in v1.1 — select club based on conditions'),
          ],
        ),
      ),
    );
  }
}
