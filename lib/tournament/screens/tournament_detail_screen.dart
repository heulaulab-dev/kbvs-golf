import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/skill_level.dart';
import '../models/tournament.dart';
import '../models/tournament_format.dart';
import '../models/tournament_status.dart';
import '../providers/changes_notifier_tournament_provider.dart';
import '../../widgets/golfie/golfie_index.dart';
import '../../core/theme/golfie_colors.dart';

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
          color: GolfieColors.linen,
          border: Border.all(color: GolfieColors.ash),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Icon(Icons.broken_image, color: GolfieColors.stone)),
      ),
    );
  }

  Widget _buildRegisterButton(ChangesNotifierTournamentProvider provider, Tournament tournament) {
    if (tournament.isFull) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: GolfiePillButton(
          label: 'Full Capacity',
          icon: Icons.people,
          onPressed: null,
        ),
      );
    }

    if (_isRegistered) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: GolfiePillButton(
          label: "You're In",
          icon: Icons.check,
          onPressed: () {},
          backgroundColor: GolfieColors.mint,
          foregroundColor: GolfieColors.ink,
        ),
      );
    }

    // Normal active register button
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: GolfiePillButton(
        label: _registrationPending ? '' : 'Register Now',
        icon: _registrationPending ? null : Icons.person_add,
        onPressed: _registrationPending ? null : () async {
          setState(() => _registrationPending = true);
          try {
            await provider.registerToTournament(tournament.id);
            if (mounted) {
              setState(() => _isRegistered = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully registered for ${tournament.name}!'), backgroundColor: GolfieColors.mint),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registration failed: $e'), backgroundColor: GolfieColors.papaya),
              );
            }
          } finally {
            if (mounted) setState(() => _registrationPending = false);
          }
        },
      ),
    );
  }

  Widget _buildCaddyTipsCard() {
    final textTheme = Theme.of(context).textTheme;
    return GolfieCollageCard(
      padding: const EdgeInsets.all(0),
      child: ExpansionTile(
        leading: Icon(Icons.lightbulb_outline, color: GolfieColors.marigold),
        title: Text('Caddy Tips', style: textTheme.titleMedium?.copyWith(color: GolfieColors.ink)),
        subtitle: Text('Practical advice for your round', style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone)),
        children: [
          ListTile(
            title: Text('Check pin position on hole 7', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.ink)),
            subtitle: Text('Avoid the water hazard on the right', style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone)),
          ),
          ListTile(
            title: Text('Wind direction matters today', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.ink)),
            subtitle: Text('Club up by one on the long par-4', style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone)),
          ),
          ListTile(
            title: Text('Watch out for the green slope', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.ink)),
            subtitle: Text('Ball runs towards the back left', style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournament = ModalRoute.of(context)?.settings.arguments as Tournament;
    final provider = Provider.of<ChangesNotifierTournamentProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.name),
        actions: [
          if (tournament.isFeatured)
            IconButton(
              icon: const Icon(Icons.star, color: GolfieColors.marigold),
              tooltip: 'Featured',
              onPressed: () {},
            ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Periwinkle accent strip
            Container(
              height: 8,
              decoration: const BoxDecoration(
                color: GolfieColors.periwinkle,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 4),

            // Hero area
            _buildHero(tournament),
            const SizedBox(height: 16),

            // Tournament name (with Hero)
            Hero(
              tag: 'tournament-${tournament.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(tournament.name, style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, color: GolfieColors.ink)),
              ),
            ),
            const SizedBox(height: 8),

            // Info row
            Row(
              children: [
                Expanded(child: Text('${DateFormat('d MMM yyyy').format(tournament.startDate.toLocal())} – ${DateFormat('d MMM yyyy').format(tournament.endDate.toLocal())}', style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone))),
                const SizedBox(width: 16),
                Expanded(child: Text(tournament.courseLocation, style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone))),
                const SizedBox(width: 16),
                Expanded(child: Text(_formatFormat(tournament.format), style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone))),
                const SizedBox(width: 16),
                Expanded(child: Text('Rp ${tournament.maxFeeIdr.toString()}', style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone))),
              ],
            ),
            const SizedBox(height: 16),

            // Avatar stack
            GolfieAvatarStack(totalPlayers: tournament.registeredCount),
            const SizedBox(height: 16),

            // CTA button
            _buildRegisterButton(provider, tournament),
            const SizedBox(height: 16),

            // Tabs
            const TabBar(
              tabs: [Tab(text: 'Details'), Tab(text: 'Players'), Tab(text: 'Rules')],
            ),
            SizedBox(
              height: 200,
              child: TabBarView(
                children: [
                  // Details tab
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Description', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: GolfieColors.ink)),
                    const SizedBox(height: 8),
                    Text('No description available.', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.graphite)),
                  ]),
                  // Players tab
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Registered Players', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: GolfieColors.ink)),
                    const SizedBox(height: 8),
                    GolfieAvatarStack(totalPlayers: tournament.registeredCount),
                    const SizedBox(height: 8),
                    if (tournament.registeredCount > 0)
                      ListTile(leading: Icon(Icons.person, color: GolfieColors.periwinkle), title: Text('Simulated player list...', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.ink))),
                  ]),
                  // Rules tab
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Tournament Rules', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: GolfieColors.ink)),
                    const SizedBox(height: 8),
                    Text('Rules will be displayed here.', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.graphite)),
                  ]),
                ],
              ),
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
    }
  }
}

// Shimmering skeleton for hero image – animated gradient overlay
class _HeroSkeleton extends StatefulWidget {
  const _HeroSkeleton({super.key});

  @override
  State<_HeroSkeleton> createState() => _HeroSkeletonState();
}

class _HeroSkeletonState extends State<_HeroSkeleton> with SingleTickerProviderStateMixin {
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
          border: Border.all(color: GolfieColors.ash),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [GolfieColors.cloud, GolfieColors.linen, GolfieColors.cloud],
            begin: Alignment(offset, 0),
            end: Alignment(offset + 1, 0),
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}
