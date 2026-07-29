import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../tournament/screens/tournament_list_screen.dart';
import '../berita/screens/berita_list_screen.dart';
import 'caddy_tips_screen.dart';
import 'admin_moderation_screen.dart';
import 'submit_tournament_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golfie'),
        actions: [
          Consumer<AppState>(
            builder: (context, app, child) => IconButton(
              icon: app.caddyTipsEnabled ? const Icon(Icons.star) : const Icon(Icons.star_border),
              tooltip: 'Caddy Tips',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CaddyTipsScreen(),
                  ),
                );
              },
            ),
          ),
          // Admin moderation entry point
          IconButton(
            icon: const Icon(Icons.supervised_user_circle),
            tooltip: 'Admin Moderation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminModerationScreen(),
                ),
              );
            },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitTournamentScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Submit New Tournament',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Golfie v1.0',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a course to begin',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TournamentListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.golf_course),
              label: const Text('Browse Tournaments'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BeritaListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.article_outlined),
              label: const Text('Golf News'),
            ),
          ],
        ),
      ),
    );
  }
}