import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'caddy_tips_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KBVS Golf'),
        actions: [
          Consumer<AppState>(
            builder: (context, app, child) => IconButton(
              icon: app.caddyTipsEnabled ? const Icon(Icons.star) : const Icon(Icons.star_border),
              tooltip: 'Caddy Tips',
              onPressed: () {
                // Navigate to Caddy Tips screen when star is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaddyTipsScreen(),
                  ),
                );
              },
            ),
          ),
          Consumer<AppState>(
            builder: (context, app, child) => PopupMenuButton<bool>(
              onSelected: (value) {
                app.toggleCaddyTips();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: true,
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, size: 18, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Enable Caddy Tips'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: false,
                  child: Row(
                    children: [
                      Icon(Icons.star_border, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Disable Caddy Tips'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'KBVS Golf v1.0',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Select a course to begin',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
