import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../tournament/providers/changes_notifier_tournament_provider.dart';
import '../tournament/models/tournament.dart';
import '../tournament/models/tournament_status.dart';
import '../core/theme/golfie_colors.dart';
import '../widgets/golfie/golfie_index.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  final Set<String> _processedIds = {};

  void _approve(Tournament tournament) {
    setState(() => _processedIds.add(tournament.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved ${tournament.name}'), backgroundColor: GolfieColors.mint),
    );
  }

  void _reject(Tournament tournament) {
    setState(() => _processedIds.add(tournament.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected ${tournament.name}'), backgroundColor: GolfieColors.papaya),
    );
  }

  Widget _buildPendingCard(Tournament tournament) {
    final textTheme = Theme.of(context).textTheme;
    return GolfieCollageCard(
      accentCorner: GolfieAccentCorner.topRight,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tournament.name, style: textTheme.titleLarge?.copyWith(color: GolfieColors.ink)),
          const SizedBox(height: 4),
          Text(tournament.courseLocation, style: textTheme.bodyMedium?.copyWith(color: GolfieColors.stone)),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('d MMM yyyy').format(tournament.startDate.toLocal())} – ${DateFormat('d MMM yyyy').format(tournament.endDate.toLocal())}',
            style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GolfiePillButton(
                  label: 'Approve',
                  icon: Icons.check_circle_outline,
                  onPressed: () => _approve(tournament),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GolfieGhostButton(
                  label: 'Reject',
                  icon: Icons.close,
                  onPressed: () => _reject(tournament),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChangesNotifierTournamentProvider>(context);
    final pending = provider.tournaments
        .where((t) => t.status == TournamentStatus.pending && !_processedIds.contains(t.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Moderation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear processed',
            onPressed: () {
              setState(() => _processedIds.clear());
            },
          ),
        ],
      ),
      body: pending.isEmpty
          ? const GolfieEmptyState(icon: Icons.inbox, title: 'No tournaments pending')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (ctx, i) => _buildPendingCard(pending[i]),
            ),
    );
  }
}
