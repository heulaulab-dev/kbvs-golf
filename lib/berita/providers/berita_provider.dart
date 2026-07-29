import 'package:flutter/foundation.dart';

import '../models/berita.dart';
import '../repositories/berita_repository.dart';

/// Immutable view of the berita feed.
@immutable
class BeritaProviderState {
  final List<Berita> items;
  final bool isLoading;
  final String errorText;
  final String searchQuery;
  final bool hasSearched;

  const BeritaProviderState({
    this.items = const [],
    this.isLoading = true,
    this.errorText = '',
    this.searchQuery = '',
    this.hasSearched = false,
  });

  BeritaProviderState copyWith({
    List<Berita>? items,
    bool? isLoading,
    String? errorText,
    String? searchQuery,
    bool? hasSearched,
  }) {
    return BeritaProviderState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText ?? this.errorText,
      searchQuery: searchQuery ?? this.searchQuery,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

/// ChangeNotifier-based provider that fetches berita from a [BeritaRepository].
class ChangesNotifierBeritaProvider extends ChangeNotifier {
  final BeritaRepository repository;

  ChangesNotifierBeritaProvider({required this.repository});

  BeritaProviderState _state = const BeritaProviderState();

  // Convenience getters
  List<Berita> get items => _state.items;
  bool get isLoading => _state.isLoading;
  String get errorText => _state.errorText;
  String get searchQuery => _state.searchQuery;
  bool get hasSearched => _state.hasSearched;

  /// Loads the trending feed. Resets search state.
  Future<void> loadTrending() async {
    _setState(_state.copyWith(
      isLoading: true,
      errorText: '',
      searchQuery: '',
      hasSearched: false,
    ));

    try {
      final items = await repository.getTrending();
      _setState(_state.copyWith(
        items: items,
        isLoading: false,
        errorText: '',
      ));
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        errorText: 'Failed to load news: ${e.toString()}',
      ));
    }
  }

  /// Performs a search. Empty/whitespace query resets to trending.
  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      await loadTrending();
      return;
    }

    _setState(_state.copyWith(
      isLoading: true,
      errorText: '',
      searchQuery: q,
      hasSearched: true,
    ));

    try {
      final items = await repository.search(q);
      _setState(_state.copyWith(
        items: items,
        isLoading: false,
        errorText: items.isEmpty ? '' : '',
      ));
    } catch (e) {
      _setState(_state.copyWith(
        isLoading: false,
        errorText: 'Search failed: ${e.toString()}',
      ));
    }
  }

  void _setState(BeritaProviderState s) {
    _state = s;
    notifyListeners();
  }
}