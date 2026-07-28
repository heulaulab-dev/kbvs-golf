import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tournament.dart';
import '../models/tournament_format.dart';
import '../providers/changes_notifier_tournament_provider.dart';

/// List of tournaments with a search bar at the top.
///
/// Reads state from [ChangesNotifierTournamentProvider] via Provider and
/// renders one of: loading spinner, error widget, empty state, or the
/// list of tournament cards.
class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    // Kick off the first page load once after mount.
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
      appBar: AppBar(title: const Text('Tournaments')),
      body: Consumer<ChangesNotifierTournamentProvider>(
        builder: (context, provider, _) {
          // Search field at top
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
                  onChanged: (value) =>
                      provider.updateSearchQuery(value),
                ),
              ),
              Expanded(child: _buildBody(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ChangesNotifierTournamentProvider provider) {
    if (provider.isLoading && provider.tournaments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorText.isNotEmpty) {
      return _ErrorState(
        message: provider.errorText,
        onRetry: () => provider.loadFirstPage(),
      );
    }
    if (provider.tournaments.isEmpty) {
      return _EmptyState(isSearchResult: provider.searchQuery.isNotEmpty);
    }
    return ListView.separated(
      itemCount: provider.tournaments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _TournamentCard(tournament: provider.tournaments[index]),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM yyyy');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.sports_golf, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatLabel(tournament.format),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${tournament.maxFeeIdr.toString()}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(TournamentFormat fmt) {
    switch (fmt) {
      case TournamentFormat.matchPlay:
        return 'Match Play';
      case TournamentFormat.stableford:
        return 'Stableford';
      case TournamentFormat.scramble:
        return 'Scramble';
      case TournamentFormat.bestBall:
        return 'Best Ball';
      case TournamentFormat.championship:
        return 'Championship';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearchResult;
  const _EmptyState({required this.isSearchResult});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.golf_course, size: 64, color: Colors.grey.shade400),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorState({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text('Something went wrong'),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
