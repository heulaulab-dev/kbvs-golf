import 'package:flutter/foundation.dart';

import '../models/tournament.dart';
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

  const TournamentProviderState({
    this.tournaments = const [],
    this.isLoading = true,
    this.errorText = '',
    this.hasFirstPage = false,
    this.hasNextPage = false,
    this.searchQuery = '',
  });

  TournamentProviderState copyWith({
    List<Tournament>? tournaments,
    bool? isLoading,
    String? errorText,
    bool? hasFirstPage,
    bool? hasNextPage,
    String? searchQuery,
  }) {
    return TournamentProviderState(
      tournaments: tournaments ?? this.tournaments,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText ?? this.errorText,
      hasFirstPage: hasFirstPage ?? this.hasFirstPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      searchQuery: searchQuery ?? this.searchQuery,
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

  /// Pull current page from the repository. On exception, the
  /// [errorText] field is populated and [tournaments] is cleared.
  Future<void> loadFirstPage() async {
    _setState(_state.copyWith(isLoading: true, errorText: ''));

    try {
      List<Tournament> items;
      int total = 0;
      bool hasNext = false;

      if (_state.searchQuery.isNotEmpty) {
        final result = await repository.search(_state.searchQuery);
        items = result.$1;
        total = result.$2;
        hasNext = result.$3;
      } else {
        final (itemsFull, totalFull, hasNextFull) = await repository.getFirstPage();
        items = itemsFull;
        total = totalFull;
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
