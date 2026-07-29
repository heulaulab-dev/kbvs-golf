import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../tournament/screens/tournament_list_screen.dart';
import '../berita/screens/berita_list_screen.dart';
import '../widgets/golfie/golfie_index.dart';
import 'caddy_tips_screen.dart';
import 'admin_moderation_screen.dart';
import 'submit_tournament_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golfie'),
        actions: [
          Consumer<AppState>(
            builder: (context, app, child) => IconButton(
              icon: app.caddyTipsEnabled ? const Icon(Icons.star) : const Icon(Icons.star_border),
              tooltip: 'Caddy Tips',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CaddyTipsScreen()));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.supervised_user_circle),
            tooltip: 'Admin Moderation',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminModerationScreen()));
            },
          ),
          Consumer<AppState>(
            builder: (context, app, child) => PopupMenuButton<bool>(
              onSelected: (value) => app.toggleCaddyTips(),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: true,
                  child: Row(children: [
                    Icon(Icons.star_outline, size: 18, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Enable Caddy Tips'),
                  ]),
                ),
                PopupMenuItem(
                  value: false,
                  child: Row(children: [
                    Icon(Icons.star_border, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Disable Caddy Tips'),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitTournamentScreen()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Submit New Tournament',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GolfieHero(
              title: 'Golfie',
              subtitle: 'Discover local tournaments',
              action: GolfiePillButton(
                label: 'Browse Tournaments',
                icon: Icons.golf_course,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TournamentListScreen()));
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GolfieGhostButton(
                label: 'Golf News',
                icon: Icons.article_outlined,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BeritaListScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}