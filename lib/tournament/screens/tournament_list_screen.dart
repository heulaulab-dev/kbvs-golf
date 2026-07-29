import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tournament.dart';
import '../models/tournament_format.dart';
import '../models/skill_level.dart';
import '../providers/changes_notifier_tournament_provider.dart';
import '../../widgets/golfie/golfie_avatar_stack.dart';
import '../../widgets/empty_state.dart';
import 'tournament_detail_screen.dart';

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

  String _formatLabel(TournamentFormat fmt) {
    switch (fmt) {
      case TournamentFormat.matchPlay: return 'Match Play';
      case TournamentFormat.stableford: return 'Stableford';
      case TournamentFormat.scramble: return 'Scramble';
      case TournamentFormat.bestBall: return 'Best Ball';
      case TournamentFormat.championship: return 'Championship';
    }
  }

  // Build filter bar: location dropdown, skill chips, max fee slider, date range picker
  Widget _buildFilterBar(ChangesNotifierTournamentProvider provider) {
    final locations = <String>{... provider.tournaments.map((t) => t.courseLocation)};
    final locationList = locations.toList()..sort();
    locationList.insert(0, '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  items: locationList.map((loc) => DropdownMenuItem<String>(
                    value: loc,
                    child: Text(loc.isEmpty ? 'All' : loc),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedLocation = (val == null || val.isEmpty) ? null : val),
                  isExpanded: true,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: const [
              Expanded(child: Text('Skill Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: SkillLevel.values.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill.toString().split('.').last),
                selected: isSelected,
                onSelected: (selected) => setState(() {
                  if (selected) _selectedSkills.add(skill);
                  else _selectedSkills.remove(skill);
                }),
                selectedColor: Colors.green.shade100,
                backgroundColor: Colors.grey.shade200,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          Row(
            children: const [
              Expanded(child: Text('Max Fee (IDR)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _maxFee != null ? _maxFee!.toDouble() : 500000.0,
            min: 0,
            max: 1000000,
            divisions: 10,
            label: (_maxFee ?? 500000).toString(),
            onChanged: (value) => setState(() => _maxFee = value.round()),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Rp 0', style: TextStyle(color: Colors.grey.shade600, fontSize: 11))),
              Expanded(child: Text('Rp 1,000,000', style: TextStyle(color: Colors.grey.shade600, fontSize: 11))),
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
          if (_dateFrom != null || _dateTo != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_dateFrom != null ? DateFormat('d MMM').format(_dateFrom!) : ''} – ${_dateTo != null ? DateFormat('d MMM').format(_dateTo!) : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  void _showDateRangePicker() async {
    final from = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (!mounted) return;
    final to = await showDatePicker(context: context, initialDate: from ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (from != null && to != null) {
      setState(() {
        _dateFrom = from;
        _dateTo = to;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          Consumer<ChangesNotifierTournamentProvider>(
            builder: (context, provider, child) => IconButton(
              icon: const Icon(Icons.replay),
              tooltip: 'Refresh',
              onPressed: () => provider.refresh(),
            ),
          ),
          _buildNetworkStatusIndicator(),
        ],
      ),
      body: Consumer<ChangesNotifierTournamentProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildFilterBar(provider),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search tournaments',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) => provider.updateSearchQuery(value),
                  ),
                ),
                Builder(
                  builder: (context) {
                    final viewport = MediaQuery.of(context).size.height - kToolbarHeight - 24;
                    return SizedBox(
                      height: viewport,
                      child: _buildBody(provider),
                    );
                  },
                ),
                if (provider.hasNextPage)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : OutlinedButton.icon(
                            onPressed: provider.loadNextPage,
                            icon: const Icon(Icons.add),
                            label: const Text('Load More'),
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkStatusIndicator() {
    return IconButton(
      icon: Icon(Icons.signal_cellular_alt_outlined, size: 24, color: Colors.grey.shade500),
      tooltip: 'Online',
      onPressed: () {},
      splashRadius: 24,
    );
  }

  Widget _buildBody(ChangesNotifierTournamentProvider provider) {
    List<Tournament> filtered = List.from(provider.tournaments);

    if (_selectedLocation != null) {
      filtered = filtered.where((t) => t.courseLocation == _selectedLocation).toList();
    }

    if (_selectedSkills.isNotEmpty) {
      filtered = filtered.where((t) => _selectedSkills.contains(t.minSkill)).toList();
    }

    if (_maxFee != null) {
      filtered = filtered.where((t) => t.maxFeeIdr <= _maxFee!).toList();
    }

    if (_dateFrom != null || _dateTo != null) {
      filtered = filtered.where((t) {
        final dt = t.startDate.toLocal();
        final fromMatch = _dateFrom == null || dt.compareTo(_dateFrom!) >= 0;
        final toMatch = _dateTo == null || dt.compareTo(_dateTo!) <= 0;
        return fromMatch && toMatch;
      }).toList();
    }

    if (provider.isLoading && provider.tournaments.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [_SkeletonCard(), _SkeletonCard(), _SkeletonCard()]),
        ),
      );
    }

    if (provider.errorText.isNotEmpty) {
      return _ErrorState(message: provider.errorText, onRetry: () => provider.loadFirstPage(), hasNetworkIssue: provider.errorText.toLowerCase().contains('network') || provider.errorText.toLowerCase().contains('connection') || provider.errorText.toLowerCase().contains('timeout'));
    }

    if (filtered.isEmpty) {
      final hasQuery = provider.searchQuery.isNotEmpty;
      return EmptyState(
        icon: Icons.golf_course,
        title: hasQuery
            ? 'No tournaments match your search'
            : 'No tournaments yet',
        subtitle: hasQuery
            ? 'Try a different search term or clear the filter.'
            : 'Check back soon — new events drop regularly.',
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _TournamentCard(tournament: filtered[index]),
    );
  }
}

// --- helper widgets (file-level) ---

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({super.key});
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRect(
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
              begin: Alignment(offset, 0),
              end: Alignment(offset + 1, 0),
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 20, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(4)), margin: const EdgeInsets.only(bottom: 8)),
            Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(4)), margin: const EdgeInsets.only(bottom: 16)),
            Row(children: [
              Icon(Icons.event, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 12),
              Icon(Icons.golf_course, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
            ]),
            const SizedBox(height: 16),
            Container(width: 60, height: 16, decoration: BoxDecoration(color: Colors.green.shade200.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
          ]),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool hasNetworkIssue;

  const _ErrorState({super.key, required this.message, required this.onRetry, this.hasNetworkIssue = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 48),
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text('Something went wrong', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (hasNetworkIssue)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Text('Check your connection', style: TextStyle(color: Colors.orange.shade700, fontSize: 14)),
              ],
            ),
          ),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.replay), label: const Text('Retry')),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;

  const _TournamentCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM yyyy');
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TournamentDetailScreen(),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              tournament.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '${tournament.courseName} • ${tournament.courseLocation}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.event, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(dateFmt.format(tournament.startDate.toLocal()), style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(width: 12),
              Icon(Icons.golf_course, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(_formatLabelStatic(tournament.format), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 8),
            Text('Rp ${tournament.maxFeeIdr.toString()}', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade700)),
            const SizedBox(height: 8),
            GolfieAvatarStack(totalPlayers: tournament.registeredCount),
          ]),
        ),
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
