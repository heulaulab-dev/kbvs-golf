import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/skill_level.dart';
import '../models/tournament.dart';
import '../models/tournament_format.dart';
import '../models/tournament_status.dart';
import '../providers/changes_notifier_tournament_provider.dart';
import '../widgets/avatar_stack.dart'; // Fixed import

/// Screen showing detailed information about a single tournament.
/// Polished UI: shimmer skeleton for hero image, avatar stack, tabs, collapsible caddy tips, registration flow.
class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({super.key});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  bool _isRegistered = false;
  bool _registrationPending = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildHero(Tournament tournament) {
    // Use network image for hero with shimmer loading fallback
    return Image.network(
      'https://picsum.photos/id/${tournament.id.hashCode % 100}/600/300',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => _HeroSkeleton(),
      errorBuilder: (context, error, stackTrace) => Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );
  }

  Widget _buildRegisterButton(ChangesNotifierTournamentProvider provider, Tournament tournament) {
    if (tournament.isFull) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.people),
          label: const Text('Full Capacity'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade500),
        );
      );
    }

    if (_isRegistered) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: const Text("You're In"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveTo<Color>(Colors.green.shade100),
            foregroundColor: MaterialStateProperty.resolveTo<Color>(Colors.grey.shade900),
          ),
        );
      );
    }

    // Normal active register button
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: FilledButton.icon(
        onPressed: _registrationPending ? null : () async {
          setState(() => _registrationPending = true);
          try {
            await provider.registerToTournament(tournament.id);
            setState(() => _isRegistered = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully registered for ${tournament.name}!'), backgroundColor: Colors.green),
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.red),
              );
            }
          } finally {
            if (mounted) setState(() => _registrationPending = false);
          }
        },
        icon: const Icon(Icons.person_add),
        label: _registrationPending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Register Now'),
        style: ButtonStyle(
          overlay: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) return Colors.blue.withOpacity(0.2);
            return null;
          }),
        ),
      ),
    );
  }

  Widget _buildCaddyTipsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.lightbulb_outline),
        title: const Text('Caddy Tips'),
        subtitle: const Text('Practical advice for your round'),
        children: [
          ListTile(
            title: const Text('Check pin position on hole 7'),
            subtitle: const Text('Avoid the water hazard on the right'),
          ),
          ListTile(
            title: const Text('Wind direction matters today'),
            subtitle: const Text('Club up by one on the long par-4'),
          ),
          ListTile(
            title: const Text('Watch out for the green slope'),
            subtitle: const Text('Ball runs towards the back left'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournament = ModalRoute.of(context)?.settings.arguments as Tournament;
    final provider = Provider.of<ChangesNotifierTournamentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.name),
        actions: [
          if (tournament.isFeatured)
            IconButton(
              icon: const Icon(Icons.star, color: Colors.amber),
              tooltip: 'Featured',
              onPressed: () {},
            )
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hero area
            _buildHero(tournament),
            const SizedBox(height: 16),

            // Tournament name
            Text(tournament.name, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            // Info row
            Row(
              children: [
                Expanded(child: Text('${DateFormat('d MMM yyyy').format(tournament.startDate.toLocal())} – ${DateFormat('d MMM yyyy').format(tournament.endDate.toLocal())}', style: TextStyle(color: Colors.grey.shade600))),
                const SizedBox(width: 16),
                Expanded(child: Text(tournament.courseLocation, style: TextStyle(color: Colors.grey.shade600))),
                const SizedBox(width: 16),
                Expanded(child: Text(_formatFormat(tournament.format), style: TextStyle(color: Colors.grey.shade600))),
                const SizedBox(width: 16),
                Expanded(child: Text('Rp ${tournament.maxFeeIdr.toString()}', style: TextStyle(color: Colors.grey.shade600))),
              ],
            ),
            const SizedBox(height: 16),

            // Avatar stack
            AvatarStack(totalPlayers: tournament.registeredCount),
            const SizedBox(height: 16),

            // CTA button
            _buildRegisterButton(provider, tournament),
            const SizedBox(height: 16),

            // Tabs
            TabBar(
              tabs: const [Tab(text: 'Details'), Tab(text: 'Players'), Tab(text: 'Rules')],
            ),
            SizedBox(height: -16),
            TabBarView(
              children: [
                // Details tab
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('No description available.', style: Theme.of(context).textTheme.bodyMedium),
                ]),
                // Players tab
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Registered Players', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  AvatarStack(totalPlayers: tournament.registeredCount),
                  const SizedBox(height: 8),
                  if (tournament.registeredCount > 0)
                    ListTile(leading: Icon(Icons.person), title: Text('Simulated player list...')),
                ]),
                // Rules tab
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tournament Rules', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Rules will be displayed here.', style: Theme.of(context).textTheme.bodyMedium),
                ],),
              ],
            ),
            const SizedBox(height: 16),

            // Caddy Tips collapsible card
            _buildCaddyTipsCard(),
          ]),
        ),
      ),
    );
  }

  String _formatFormat(TournamentFormat fmt) {
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

// Shimmering skeleton for hero image – animated gradient overlay
class _HeroSkeleton extends StatefulWidget {
  const _HeroSkeleton({super.key});

  @override
  State<Heroskeleton> createState() => _HeroSkeletonState();
}

class _HeroSkeletonState extends State<Heroskeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: _controller, curve: const Cubic(0.4, 0.0, 0.2, 1)));
    _controller.repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = _animation.value;
    return ClipRect(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
            begin: Alignment(offset, 0),
            end: Alignment(offset + 1, 0),
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}