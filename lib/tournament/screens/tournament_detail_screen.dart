import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/skill_level.dart';
import '../models/tournament.dart';
import '../models/tournament_format.dart';
import '../models/tournament_status.dart';
import '../providers/changes_notifier_tournament_provider.dart';

/// Screen showing detailed information about a single tournament.
/// Polished UI: shimmer skeleton for hero image, loading feedback on register button.
class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({super.key});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late final TextEditingController _searchCtrl;
  bool _showSkeleton = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    // Show skeleton briefly to demonstrate loader pattern
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showSkeleton = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Format skill level to readable string.
  String _formatSkill(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner: return 'Beginner';
      case SkillLevel.casual: return 'Casual';
      case SkillLevel.intermediate: return 'Intermediate';
      case SkillLevel.advanced: return 'Advanced';
      case SkillLevel.pro: return 'Professional';
    }
  }

  /// Format tournament format to readable string.
  String _formatFormat(TournamentFormat fmt) {
    switch (fmt) {
      case TournamentFormat.matchPlay: return 'Match Play';
      case TournamentFormat.stableford: return 'Stableford';
      case TournamentFormat.scramble: return 'Scramble';
      case TournamentFormat.bestBall: return 'Best Ball';
      case TournamentFormat.championship: return 'Championship';
    }
  }

  /// Format tournament status to readable string.
  String _formatStatus(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.approved: return 'Approved';
      case TournamentStatus.pending: return 'Pending';
      case TournamentStatus.rejected: return 'Rejected';
      case TournamentStatus.cancelled: return 'Cancelled';
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isSecondary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSecondary ? Colors.grey.shade600 : null,
                    fontWeight: isSecondary ? FontWeight.normal : FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tournament = ModalRoute.of(context)?.settings.arguments as Tournament;
    final provider = Provider.of<ChangesNotifierTournamentProvider>(context);

    // Hero area – shimmer skeleton while loading, then placeholder
    final heroWidget = _showSkeleton
        ? _HeroSkeleton()
        : Container(
            height: 250,
            decoration: BoxDecoration(color: Colors.grey[50]),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                tournament.courseName,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.grey.shade400),
              ),
            ),
          );

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heroWidget,
          const SizedBox(height: 16),
          // Course info card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Name', tournament.courseName),
                  _buildInfoRow('Location', tournament.courseLocation,
                      isSecondary: true),
                ],
              ),
            ),
          ),

          // Details section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tournament Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Format', _formatFormat(tournament.format)),
                  _buildInfoRow('Skill Level', _formatSkill(tournament.minSkill)),
                  _buildInfoRow('Fee', tournament.feeLabel),
                  _buildInfoRow('Start',
                      DateFormat('d MMM yyyy, h:mm a').format(tournament.startDate)),
                  _buildInfoRow('End',
                      DateFormat('d MMM yyyy, h:mm a').format(tournament.endDate)),
                  _buildInfoRow('Status', _formatStatus(tournament.status)),
                ],
              ),
            ),
          ),

          // Participants section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registration',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Registered',
                      '${tournament.registeredCount} / ${tournament.maxCapacity} (${tournament.capacityLabel})'),
                  _buildInfoRow('Full?', tournament.isFull ? 'Yes' : 'No'),
                ],
              ),
            ),
          ),

          // Register button (connected to provider) with loading state
          _buildRegisterButton(provider, tournament),
        ]),
      ),
    );
  }

  Widget _buildRegisterButton(ChangesNotifierTournamentProvider provider,
      Tournament tournament) {
    bool isProcessing = provider.isLoading;
    bool isAvailable = !tournament.isFull && !isProcessing;

    if (tournament.isFull) {
      // Full capacity state
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.people),
          label: const Text('Full Capacity'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade500,
          ),
        ),
      );
    } else if (isAvailable) {
      // Normal active register button
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: FilledButton.icon(
          onPressed: () async {
            try {
              // Show loading feedback via snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registering for ${tournament.name}...'),
                  duration: const Duration(seconds: 3),
                ),
              );
              await provider.registerToTournament(tournament.id);
              // After reload, show success
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully registered for ${tournament.name}!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registration failed: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Register Now'),
        ),
      );
    } else {
      // Loading state – show spinner instead of button
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      );
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
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: const Cubic(0.4, 0.0, 0.2, 1)),
    );
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