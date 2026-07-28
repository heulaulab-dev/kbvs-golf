import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tournament.dart';
import '../models/tournament_format.dart';
import '../models/skill_level.dart';
import '../models/tournament_status.dart';
import '../providers/changes_notifier_tournament_provider.dart';
import 'tournament_detail_screen.dart';

/// List of tournaments with search bar.
/// Polished UI: skeleton loaders, animated error states, network awareness.
class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChangesNotifierTournamentProvider>().loadFirstPage();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          Consumer<ChangesNotifierTournamentProvider>(
            builder: (context, provider, child) => IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => provider.refresh(),
            ),
          ),
          _buildNetworkStatusIndicator(),
        ],
      ),
      body: Consumer<ChangesNotifierTournamentProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search tournaments',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => provider.updateSearchQuery(value),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: _buildBody(provider),
                ),
              ),
              if (provider.hasNextPage)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton.icon(
                          onPressed: provider.loadNextPage,
                          icon: const Icon(Icons.plus),
                          label: const Text('Load More'),
                        ),
                ),
            ],
          ),
        },
      ),
    );
  }

  Widget _buildNetworkStatusIndicator() {
    // Simple connectivity indicator - shows as online unless there's an error
    // In production, integrate with connectivity_plus for real detection
    return IconButton(
      icon: const Icon(
        Icons.signal_cellular_alt_outlined,
        size: 24,
        color: Colors.grey.shade500,
      ),
      tooltip: 'Online',
      onPressed: () {},
      splashRadius: 24,
    );
  }

  Widget _buildBody(ChangesNotifierTournamentProvider provider) {
    // Show skeleton cards while initial loading
    if (provider.isLoading && provider.tournaments.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [_SkeletonCard(), _SkeletonCard(), _SkeletonCard()],
          ),
        ),
      );
    }

    if (provider.errorText.isNotEmpty) {
      return _PolishedErrorState(
        message: provider.errorText,
        onRetry: () => provider.loadFirstPage(),
        hasNetworkIssue: provider.errorText.toLowerCase().contains('network') ||
            provider.errorText.toLowerCase().contains('connection') ||
            provider.errorText.toLowerCase().contains('timeout'),
      );
    }

    if (provider.tournaments.isEmpty) {
      return _EmptyState(isSearchResult: provider.searchQuery.isNotEmpty);
    }

    return ListView.separated(
      itemCount: provider.tournaments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _TournamentCard(
        tournament: provider.tournaments[index],
      ),
    );
  }
}

// Simple skeleton card placeholder (no shimmer for stability)
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.only(bottom: 8),
            ),
            // Subtitle placeholder
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            // Date/format row placeholders
            Row(
              children: [
                Icon(Icons.event, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.sports_golf, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price placeholder
            Container(
              width: 60,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty state (unchanged)
class _EmptyState extends StatelessWidget {
  final bool isSearchResult;
  const _EmptyState({required this.isSearchResult});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.golf_course, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isSearchResult ? 'No tournaments match your search' : 'No tournaments yet',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// Polished error state with entrance animation
class _PolishedErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool hasNetworkIssue;

  const _PolishedErrorState({
    required this.message,
    required this.onRetry,
    this.hasNetworkIssue = false,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(
          parent: AnimationController(
            vsync: TickerProviderSeamless(),
            duration: const Duration(milliseconds: 200),
          ),
          curve: Curves.easeOut,
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: AnimationController(
              vsync: TickerProviderSeamless(),
              duration: const Duration(milliseconds: 200),
            ),
            curve: Curves.easeOut,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (hasNetworkIssue)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'Check your connection',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tournament card (unchanged, but made resilient to theme)
class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM yyyy');
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TournamentDetailScreen(),
            settings: RouteSettings(arguments: tournament),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tournament.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${tournament.courseName} • ${tournament.courseLocation}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    dateFmt.format(tournament.startDate.toLocal()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.sports_golf, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatLabel(tournament.format),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${tournament.maxFeeIdr.toString()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLabel(TournamentFormat fmt) {
    switch (fmt) {
      case TournamentFormat.matchPlay: return 'Match Play';
      case TournamentFormat.stableford: return 'Stableford';
      case TournamentFormat.scramble: return 'Scramble';
      case TournamentFormat.bestBall: return 'Best Ball';
      case TournamentFormat.championship: return 'Championship';
      default: return '';
    }
  }
}