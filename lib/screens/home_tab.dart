import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../berita/screens/berita_list_screen.dart';
import '../core/theme/golfie_colors.dart';
import '../core/theme/golfie_radii.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/onboarding/providers/onboarding_provider.dart';
import '../berita/providers/berita_provider.dart';
import '../tournament/providers/changes_notifier_tournament_provider.dart';
import '../tournament/screens/tournament_detail_screen.dart';
import '../tournament/screens/tournament_list_screen.dart';
import 'submit_tournament_screen.dart';

/// Enhanced home tab — shows greeting, featured tournament, upcoming list,
/// and latest news. Loads data from providers on first frame.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Load data on first frame — providers skip if already loaded
    Future.microtask(() {
      if (!mounted) return;
      final tournamentProvider = context.read<ChangesNotifierTournamentProvider>();
      final beritaProvider = context.read<ChangesNotifierBeritaProvider>();
      if (tournamentProvider.tournaments.isEmpty && !tournamentProvider.isLoading) {
        tournamentProvider.loadFirstPage();
      }
      if (beritaProvider.items.isEmpty) {
        beritaProvider.loadTrending();
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _userName(AuthProvider auth, OnboardingProvider onboard) {
    final name = onboard.userName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final email = auth.user?.email ?? '';
    return email.split('@').first;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatShortDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboard = context.watch<OnboardingProvider>();
    final tournamentProvider = context.watch<ChangesNotifierTournamentProvider>();
    final beritaProvider = context.watch<ChangesNotifierBeritaProvider>();

    return Scaffold(
      backgroundColor: GolfieColors.canvas,
      appBar: AppBar(
        backgroundColor: GolfieColors.canvas,
        elevation: 0,
        title: Text(
          'Golfie',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: GolfieColors.ink),
            tooltip: 'Submit Tournament',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubmitTournamentScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubmitTournamentScreen()),
        ),
        backgroundColor: GolfieColors.ink,
        foregroundColor: GolfieColors.white,
        tooltip: 'Submit New Tournament',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            tournamentProvider.loadFirstPage(),
            beritaProvider.loadTrending(),
          ]);
        },
        color: GolfieColors.ink,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Greeting
              Text(
                '${_greeting()}, ${_userName(auth, onboard)}',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: GolfieColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(DateTime.now()),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: GolfieColors.stone,
                ),
              ),
              const SizedBox(height: 20),

              // Featured tournament hero card
              _FeaturedTournamentCard(
                provider: tournamentProvider,
                onTap: () {
                  final featured = tournamentProvider.tournaments
                      .where((t) => t.isFeatured)
                      .firstOrNull;
                  if (featured != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TournamentDetailScreen(),
                        settings: RouteSettings(arguments: featured),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Upcoming tournaments section
              _buildSectionHeader('Upcoming', onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TournamentListScreen(),
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: _buildUpcomingList(tournamentProvider, context),
              ),
              const SizedBox(height: 28),

              // Latest news section
              _buildSectionHeader('Latest news', onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BeritaListScreen(),
                  ),
                );
              }),
              const SizedBox(height: 12),
              ..._buildNewsCards(beritaProvider, context),

              const SizedBox(height: 100), // Space above FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GolfieColors.ink,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See all',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: GolfieColors.graphite,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingList(
    ChangesNotifierTournamentProvider provider,
    BuildContext context,
  ) {
    if (provider.isLoading && provider.tournaments.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: GolfieColors.ink, strokeWidth: 2),
      );
    }

    final upcoming = provider.tournaments
        .where((t) => t.isVisibleToPublic && !t.isFull)
        .take(5)
        .toList();

    if (upcoming.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GolfieColors.white,
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          border: Border.all(color: GolfieColors.ash),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.golf_course, size: 32, color: GolfieColors.stone),
            const SizedBox(height: 8),
            Text(
              'No upcoming tournaments',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: GolfieColors.stone,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: upcoming.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final tournament = upcoming[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TournamentDetailScreen(),
              settings: RouteSettings(arguments: tournament),
            ),
          ),
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GolfieColors.white,
              borderRadius: BorderRadius.circular(GolfieRadii.xl),
              border: Border.all(color: GolfieColors.ash),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0A000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GolfieColors.marigold.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tournament.format.name.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: GolfieColors.graphite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tournament.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: GolfieColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tournament.courseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: GolfieColors.stone,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: GolfieColors.stone),
                        const SizedBox(width: 4),
                        Text(
                          _formatShortDate(tournament.startDate),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: GolfieColors.graphite,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 12, color: GolfieColors.stone),
                        const SizedBox(width: 4),
                        Text(
                          tournament.capacityLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: GolfieColors.graphite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildNewsCards(
    ChangesNotifierBeritaProvider provider,
    BuildContext context,
  ) {
    if (provider.isLoading && provider.items.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ];
    }

    final latest = provider.items.take(3).toList();

    if (latest.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GolfieColors.white,
            borderRadius: BorderRadius.circular(GolfieRadii.xl),
            border: Border.all(color: GolfieColors.ash),
          ),
          child: Text(
            'No news available',
            style: GoogleFonts.inter(fontSize: 14, color: GolfieColors.stone),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return latest.map((berita) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: GolfieColors.white,
          borderRadius: BorderRadius.circular(GolfieRadii.xl),
          border: Border.all(color: GolfieColors.ash),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GolfieRadii.lg),
                color: GolfieColors.cloud,
              ),
              clipBehavior: Clip.antiAlias,
              child: berita.imageUrl != null && berita.imageUrl!.isNotEmpty
                  ? Image.network(
                      berita.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.article_outlined,
                        size: 28,
                        color: GolfieColors.stone,
                      ),
                    )
                  : Icon(Icons.article_outlined, size: 28, color: GolfieColors.stone),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: GolfieColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    berita.relativeDate,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: GolfieColors.stone,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

/// Featured tournament hero card — sky gradient background, prominent display.
class _FeaturedTournamentCard extends StatelessWidget {
  final ChangesNotifierTournamentProvider provider;
  final VoidCallback onTap;

  const _FeaturedTournamentCard({
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final featured = provider.tournaments
        .where((t) => t.isFeatured && t.isVisibleToPublic)
        .firstOrNull;

    // Fallback: next upcoming tournament
    final featuredOrNext = featured ??
        provider.tournaments
            .where((t) => t.isVisibleToPublic)
            .firstOrNull;

    if (provider.isLoading && featuredOrNext == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (featuredOrNext == null) {
      return Container(
        height: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.golf_course, size: 40, color: GolfieColors.ink),
            const SizedBox(height: 8),
            Text(
              'No tournaments yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: GolfieColors.ink,
              ),
            ),
            Text(
              'Tournaments will appear here once created',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: GolfieColors.graphite,
              ),
            ),
          ],
        ),
      );
    }

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GolfieRadii.xxxl),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9ED4EF), Color(0xFFD1EEF9)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Badge + title
            Row(
              children: [
                if (featuredOrNext.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: GolfieColors.marigold.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'FEATURED',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: GolfieColors.graphite,
                      ),
                    ),
                  ),
                if (featuredOrNext.isFeatured) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    featuredOrNext.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: GolfieColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            // Course + location
            Text(
              '${featuredOrNext.courseName} — ${featuredOrNext.courseLocation}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: GolfieColors.graphite,
              ),
            ),
            // Bottom row: date + fee + capacity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: GolfieColors.ink),
                    const SizedBox(width: 6),
                    Text(
                      '${featuredOrNext.startDate.day} ${months[featuredOrNext.startDate.month - 1]}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GolfieColors.ink,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 14, color: GolfieColors.ink),
                    const SizedBox(width: 6),
                    Text(
                      featuredOrNext.capacityLabel,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GolfieColors.ink,
                      ),
                    ),
                  ],
                ),
                Text(
                  featuredOrNext.feeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: GolfieColors.ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
