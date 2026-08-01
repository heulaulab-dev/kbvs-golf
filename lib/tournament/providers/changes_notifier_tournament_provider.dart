import 'package:flutter/foundation.dart';

import '../models/tournament.dart';
import '../models/skill_level.dart';
import '../repositories/tournament_repository.dart';

/// State for the [ChangesNotifierTournamentProvider].
///
/// `TournamentProviderState` is the immutable view of the provider so
/// consumers (screens, widgets) can hold a snapshot for UI without
/// listening to a stream of updates.
@immutable
class TournamentProviderState {
  final List<Tournament> tournaments;
  final bool isLoading;
  final String errorText;
  final bool hasFirstPage;
  final bool hasNextPage;
  final String searchQuery;

  // Client-side filter state (applied in-memory after fetch)
  final String? filterLocation;
  final Set<SkillLevel> filterSkillLevels;
  final int? filterMaxFee;
  final DateTime? filterDateFrom;
  final DateTime? filterDateTo;

  const TournamentProviderState({
    this.tournaments = const [],
    this.isLoading = true,
    this.errorText = '',
    this.hasFirstPage = false,
    this.hasNextPage = false,
    this.searchQuery = '',
    this.filterLocation,
    this.filterSkillLevels = const {},
    this.filterMaxFee,
    this.filterDateFrom,
    this.filterDateTo,
  });

  TournamentProviderState copyWith({
    List<Tournament>? tournaments,
    bool? isLoading,
    String? errorText,
    bool? hasFirstPage,
    bool? hasNextPage,
    String? searchQuery,
    String? filterLocation,
    bool clearFilterLocation = false,
    Set<SkillLevel>? filterSkillLevels,
    int? filterMaxFee,
    bool clearFilterMaxFee = false,
    DateTime? filterDateFrom,
    bool clearFilterDateFrom = false,
    DateTime? filterDateTo,
    bool clearFilterDateTo = false,
  }) {
    return TournamentProviderState(
      tournaments: tournaments ?? this.tournaments,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText ?? this.errorText,
      hasFirstPage: hasFirstPage ?? this.hasFirstPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterLocation: clearFilterLocation ? null : (filterLocation ?? this.filterLocation),
      filterSkillLevels: filterSkillLevels ?? this.filterSkillLevels,
      filterMaxFee: clearFilterMaxFee ? null : (filterMaxFee ?? this.filterMaxFee),
      filterDateFrom: clearFilterDateFrom ? null : (filterDateFrom ?? this.filterDateFrom),
      filterDateTo: clearFilterDateTo ? null : (filterDateTo ?? this.filterDateTo),
    );
  }
}

/// ChangeNotifier-based provider that fetches tournaments from a
/// [TournamentRepository]. Mirrors the Phase 2 caddy-tips AppState
/// pattern: in-memory list of items, listeners updated via
/// `notifyListeners()`.
class ChangesNotifierTournamentProvider extends ChangeNotifier {
  final TournamentRepository repository;
  TournamentProviderState _state = const TournamentProviderState();

  ChangesNotifierTournamentProvider({required this.repository});

  // Convenience getters
  List<Tournament> get tournaments => _state.tournaments;
  bool get isLoading => _state.isLoading;
  String get errorText => _state.errorText;
  bool get hasFirstPage => _state.hasFirstPage;
  bool get hasNextPage => _state.hasNextPage;
  String get searchQuery => _state.searchQuery;

  /// Client-side filtered view of the current tournament list.
  List<Tournament> get filteredTournaments {
    var result = List<Tournament>.from(_state.tournaments);

    // Filter by skill level
    if (_state.filterSkillLevels.isNotEmpty) {
      result = result.where((t) => _state.filterSkillLevels.contains(t.minSkill)).toList();
    }

    // Filter by max fee
    if (_state.filterMaxFee != null) {
      result = result.where((t) => t.maxFeeIdr <= _state.filterMaxFee!).toList();
    }

    // Filter by date range
    if (_state.filterDateFrom != null) {
      result = result.where((t) => !t.startDate.isBefore(_state.filterDateFrom!)).toList();
    }
    if (_state.filterDateTo != null) {
      result = result.where((t) => !t.startDate.isAfter(_state.filterDateTo!)).toList();
    }

    // Filter by location (case-insensitive contains in courseName or courseLocation)
    if (_state.filterLocation != null && _state.filterLocation!.isNotEmpty) {
      final query = _state.filterLocation!.toLowerCase();
      result = result.where((t) =>
        t.courseName.toLowerCase().contains(query) ||
        t.courseLocation.toLowerCase().contains(query)
      ).toList();
    }

    return result;
  }

  /// Pull current page from the repository. On exception, the
  /// [errorText] field is populated and [tournaments] is cleared.
  Future<void> loadFirstPage() async {
    _setState(_state.copyWith(isLoading: true, errorText: ''));

    try {
      List<Tournament> items;
      bool hasNext = false;

      if (_state.searchQuery.isNotEmpty) {
        final result = await repository.search(_state.searchQuery);
        items = result.$1;
        hasNext = result.$3;
      } else {
        final (itemsFull, _, hasNextFull) = await repository.getFirstPage();
        items = itemsFull;
        hasNext = hasNextFull;
      }

      _setState(_state.copyWith(
        tournaments: items,
        isLoading: false,
        errorText: '',
        hasNextPage: hasNext,
        hasFirstPage: !hasNext,
      ));
    } catch (e) {
      _setState(_state.copyWith(
        tournaments: const [],
        isLoading: false,
        errorText: '$e',
      ));
    }
  }

  /// Load next page of tournaments (appends to existing list).
  /// Only available when there is a next page and not currently loading.
  Future<void> loadNextPage() async {
    if (!_state.hasNextPage || _state.isLoading) return;

    _setState(_state.copyWith(isLoading: true));

    try {
      // Since we don't store cursor in state yet, use the repo's nextPage without cursor
      // (the backend returns continuation token in response; for now simple approach)
      final (items, total, hasNext) = await repository.nextPage();
      // Append new items to existing list
      final updatedTournaments = List<Tournament>.from(_state.tournaments)..addAll(items);
      _setState(_state.copyWith(
        tournaments: updatedTournaments,
        isLoading: false,
        hasNextPage: hasNext,
      ));
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        errorText: 'Failed to load more: $e',
      ));
    }
  }

  /// Refresh the first page (clears current list and reloads).
  Future<void> refresh() async {
    _setState(_state.copyWith(tournaments: const [], isLoading: true, errorText: ''));
    await loadFirstPage();
  }

  /// Update the search query and trigger a reload.
  Future<void> updateSearchQuery(String query) async {
    _setState(_state.copyWith(searchQuery: query));
    await loadFirstPage();
  }

  /// Apply client-side filters to the current tournament list.
  /// Filters are applied in-memory after fetch; no server call needed.
  void updateFilters({
    String? location,
    Set<SkillLevel>? skillLevels,
    int? maxFee,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    _setState(_state.copyWith(
      filterLocation: location,
      filterSkillLevels: skillLevels ?? _state.filterSkillLevels,
      filterMaxFee: maxFee,
      filterDateFrom: dateFrom,
      filterDateTo: dateTo,
    ));
  }

  void _setState(TournamentProviderState next) {
    _state = next;
    notifyListeners();
  }

  /// Registers the user for the tournament with [tournamentId].
  /// After registration, reloads the first page to reflect the change.
  Future<void> registerToTournament(String tournamentId) async {
    _setState(_state.copyWith(isLoading: true, errorText: ''));
    try {
      await repository.register(tournamentId);
      // Reload to show updated registered counts
      await loadFirstPage();
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        errorText: 'Failed to register: $e',
      ));
    }
  }
}
