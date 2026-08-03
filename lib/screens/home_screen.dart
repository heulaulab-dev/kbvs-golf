import 'package:flutter/material.dart';

import '../berita/screens/berita_list_screen.dart';
import '../core/theme/golfie_colors.dart';
import '../features/profile/screens/profile_screen.dart';
import '../tournament/screens/tournament_list_screen.dart';
import 'home_tab.dart';

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
          HomeTab(),
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
