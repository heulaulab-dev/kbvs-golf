import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../berita/screens/berita_list_screen.dart';
import '../core/theme/golfie_colors.dart';
import '../features/profile/screens/profile_screen.dart';
import '../providers/app_state.dart';
import '../tournament/screens/tournament_list_screen.dart';
import '../widgets/golfie/golfie_index.dart';
import 'admin_moderation_screen.dart';
import 'caddy_tips_screen.dart';
import 'submit_tournament_screen.dart';

/// Root shell with 4 tabs: Home, News, Tournaments, Profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _HomeTab(),
          BeritaListScreen(),
          TournamentListScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        backgroundColor: GolfieColors.white,
        indicatorColor: GolfieColors.mint.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.golf_course_outlined),
            selectedIcon: Icon(Icons.golf_course),
            label: 'Tournaments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// The original HomeScreen content, extracted as the Home tab.
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golfie'),
        actions: [
          Consumer<AppState>(
            builder: (context, app, child) => IconButton(
              icon: app.caddyTipsEnabled
                  ? const Icon(Icons.star)
                  : const Icon(Icons.star_border),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubmitTournamentScreen(),
            ),
          );
        },
        tooltip: 'Submit New Tournament',
        child: const Icon(Icons.add),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TournamentListScreen(),
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BeritaListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
