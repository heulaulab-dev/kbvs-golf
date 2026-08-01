import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tournament.dart';
import '../models/tournament_format.dart';
import '../models/skill_level.dart';
import '../providers/changes_notifier_tournament_provider.dart';
import '../../widgets/golfie/golfie_index.dart';
import '../../core/theme/golfie_colors.dart';
import 'tournament_detail_screen.dart';

/// Skill level label helper — top-level so both screen and filter sheet can use it.
String skillLevelLabel(SkillLevel level) {
  switch (level) {
    case SkillLevel.beginner: return 'Beginner';
    case SkillLevel.casual: return 'Casual';
    case SkillLevel.competitive: return 'Competitive';
    case SkillLevel.pro: return 'Pro';
  }
}

/// List of tournaments with search bar and filter controls.
/// Polished UI: shimmer skeleton loaders, network awareness, filter bar.
class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  late TextEditingController _searchCtrl;

  // Filter state
  String? _selectedLocation;
  Set<SkillLevel> _selectedSkills = {};
  int? _maxFee;
  DateTime? _dateFrom;
  DateTime? _dateTo;

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
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filters',
              onPressed: () => _showFilterSheet(context, provider),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search tournaments',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<ChangesNotifierTournamentProvider>().updateSearchQuery('');
                          setState(() {});
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (query) {
                context.read<ChangesNotifierTournamentProvider>().updateSearchQuery(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<ChangesNotifierTournamentProvider>(
              builder: (context, provider, child) => _buildBody(context, provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChangesNotifierTournamentProvider provider) {
    // Derived state
    final filtered = provider.filteredTournaments;
    final isLoading = provider.isLoading;
    final hasData = filtered.isNotEmpty;

    if (isLoading && !hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorText.isNotEmpty) {
      return _ErrorState(message: provider.errorText, onRetry: () => provider.loadFirstPage(), hasNetworkIssue: provider.errorText.toLowerCase().contains('network') || provider.errorText.toLowerCase().contains('connection') || provider.errorText.toLowerCase().contains('timeout'));
    }

    if (filtered.isEmpty) {
      final hasQuery = provider.searchQuery.isNotEmpty;
      return GolfieEmptyState(
        icon: Icons.golf_course,
        title: hasQuery
            ? 'No tournaments match your search'
            : 'No tournaments yet',
        subtitle: hasQuery
            ? 'Try a different search term or clear the filter.'
            : 'Check back soon — new events drop regularly.',
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: RefreshIndicator(
        key: const ValueKey('content'),
        onRefresh: () => provider.loadFirstPage(),
        child: ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _TournamentCard(tournament: filtered[index]),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ChangesNotifierTournamentProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        selectedLocation: _selectedLocation,
        selectedSkills: _selectedSkills,
        maxFee: _maxFee,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        onChangedLocation: (v) => _selectedLocation = v,
        onChangedSkills: (v) => _selectedSkills = v,
        onChangedMaxFee: (v) => _maxFee = v,
        onChangedDateFrom: (v) => _dateFrom = v,
        onChangedDateTo: (v) => _dateTo = v,
        onApply: () {
          provider.updateFilters(
            location: _selectedLocation,
            skillLevels: _selectedSkills,
            maxFee: _maxFee,
            dateFrom: _dateFrom,
            dateTo: _dateTo,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

// --- Filter bottom sheet ---

class _FilterSheet extends StatefulWidget {
  final String? selectedLocation;
  final Set<SkillLevel> selectedSkills;
  final int? maxFee;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ValueChanged<String?> onChangedLocation;
  final ValueChanged<Set<SkillLevel>> onChangedSkills;
  final ValueChanged<int?> onChangedMaxFee;
  final ValueChanged<DateTime?> onChangedDateFrom;
  final ValueChanged<DateTime?> onChangedDateTo;
  final VoidCallback onApply;

  const _FilterSheet({
    required this.selectedLocation,
    required this.selectedSkills,
    required this.maxFee,
    required this.dateFrom,
    required this.dateTo,
    required this.onChangedLocation,
    required this.onChangedSkills,
    required this.onChangedMaxFee,
    required this.onChangedDateFrom,
    required this.onChangedDateTo,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Skill Level', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SkillLevel.values.map((level) {
                final selected = widget.selectedSkills.contains(level);
                return FilterChip(
                  label: Text(skillLevelLabel(level)),
                  selected: selected,
                  onSelected: (v) {
                    final updated = Set<SkillLevel>.from(widget.selectedSkills);
                    v ? updated.add(level) : updated.remove(level);
                    widget.onChangedSkills(updated);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text('Max Fee (Rp)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Rp 0', style: TextStyle(color: GolfieColors.stone, fontSize: 11))),
                Expanded(child: Text('Rp 1,000,000', style: TextStyle(color: GolfieColors.stone, fontSize: 11))),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(child: Text('Date Range', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _showDateRangePicker(),
                  tooltip: 'Pick dates',
                ),
              ],
            ),
            if (widget.dateFrom != null || widget.dateTo != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${widget.dateFrom != null ? DateFormat('d MMM').format(widget.dateFrom!) : ''} – ${widget.dateTo != null ? DateFormat('d MMM').format(widget.dateTo!) : ''}',
                  style: TextStyle(fontSize: 12, color: GolfieColors.stone),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final from = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (!mounted) return;
    final to = await showDatePicker(context: context, initialDate: from ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (from != null && to != null) {
      widget.onChangedDateFrom(from);
      widget.onChangedDateTo(to);
      setState(() {});
    }
  }
}

// --- helper widgets (still file-level) ---

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard> with SingleTickerProviderStateMixin {
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [GolfieColors.cloud, GolfieColors.linen, GolfieColors.cloud],
          begin: Alignment(offset, 0),
          end: Alignment(offset + 1, 0),
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool hasNetworkIssue;

  const _ErrorState({required this.message, required this.onRetry, this.hasNetworkIssue = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 48),
        const Icon(Icons.error_outline, size: 64, color: GolfieColors.papaya),
        const SizedBox(height: 16),
        Text('Something went wrong', textAlign: TextAlign.center, style: textTheme.titleLarge?.copyWith(color: GolfieColors.ink)),
        const SizedBox(height: 8),
        if (hasNetworkIssue)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 16, color: GolfieColors.marigold),
                const SizedBox(width: 6),
                Text('Check your connection', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.marigold)),
              ],
            ),
          ),
        Text(message, textAlign: TextAlign.center, style: textTheme.bodyMedium?.copyWith(color: GolfieColors.stone)),
        const SizedBox(height: 24),
        Center(
          child: GolfieGhostButton(
            label: 'Retry',
            icon: Icons.replay,
            onPressed: onRetry,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;

  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM yyyy');
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TournamentDetailScreen(),
            settings: RouteSettings(arguments: tournament),
          ),
        );
      },
      child: GolfieCollageCard(
        accentCorner: GolfieAccentCorner.topRight,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Hero(
            tag: 'tournament-${tournament.id}',
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                tournament.name,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: GolfieColors.ink),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${tournament.courseName} • ${tournament.courseLocation}',
            style: textTheme.bodyMedium?.copyWith(color: GolfieColors.stone),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.event, size: 14, color: GolfieColors.stone),
            const SizedBox(width: 4),
            Text(dateFmt.format(tournament.startDate.toLocal()), style: textTheme.bodySmall?.copyWith(color: GolfieColors.graphite)),
            const SizedBox(width: 12),
            Icon(Icons.golf_course, size: 14, color: GolfieColors.stone),
            const SizedBox(width: 4),
            Text(_formatLabelStatic(tournament.format), style: textTheme.bodySmall?.copyWith(color: GolfieColors.stone)),
          ]),
          const SizedBox(height: 8),
          Text('Rp ${tournament.maxFeeIdr.toString()}', style: textTheme.titleMedium?.copyWith(color: GolfieColors.mint)),
          const SizedBox(height: 8),
          GolfieAvatarStack(totalPlayers: tournament.registeredCount),
        ]),
      ),
    );
  }

  static String _formatLabelStatic(TournamentFormat fmt) {
    switch (fmt) {
      case TournamentFormat.matchPlay: return 'Match Play';
      case TournamentFormat.stableford: return 'Stableford';
      case TournamentFormat.scramble: return 'Scramble';
      case TournamentFormat.bestBall: return 'Best Ball';
      case TournamentFormat.championship: return 'Championship';
    }
  }
}
