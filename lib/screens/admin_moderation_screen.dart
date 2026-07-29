import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../tournament/providers/changes_notifier_tournament_provider.dart';
import '../tournament/models/tournament.dart';
import '../tournament/models/tournament_status.dart';
import '../widgets/golfie/golfie_empty_state.dart';

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
      SnackBar(content: Text('Approved ${tournament.name}'), backgroundColor: Colors.green),
    );
  }

  void _reject(Tournament tournament) {
    setState(() => _processedIds.add(tournament.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected ${tournament.name}'), backgroundColor: Colors.red),
    );
  }

  Widget _buildPendingCard(Tournament tournament) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tournament.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(tournament.courseLocation, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('d MMM yyyy').format(tournament.startDate.toLocal())} – ${DateFormat('d MMM yyyy').format(tournament.endDate.toLocal())}',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(tournament),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(tournament),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
