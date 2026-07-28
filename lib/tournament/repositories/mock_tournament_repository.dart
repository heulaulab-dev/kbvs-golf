import 'package:flutter/foundation.dart';

import '../models/tournament.dart';
import 'tournament_repository.dart';

/// In-memory [TournamentRepository] implementation for UI testing
/// and offline development. Holds a static list of tournaments
/// and answers queries against that list without network calls.
class MockTournamentRepository implements TournamentRepository {
  final List<Tournament> _store;

  MockTournamentRepository(List<Tournament> data)
      : _store = List<Tournament>.unmodifiable(data);

  @override
  Future<(List<Tournament>, int, bool)> getFirstPage() async {
    return _buildResult(_store);
  }

  @override
  Future<(List<Tournament>, int, bool)> nextPage({String? cursor}) async {
    if (kDebugMode && cursor == null) {
      debugPrint('MockTournamentRepository.nextPage called without cursor');
    }
    return _buildResult(_store);
  }

  @override
  Future<(List<Tournament>, int, bool)> prevPage({String? cursor}) async {
    // No backward pagination token = no previous page.
    if (cursor == null) {
      return (<Tournament>[], 0, false);
    }
    return _buildResult(_store);
  }

  @override
  Future<Tournament> getById(String id) async {
    final candidates = _store.where((t) => t.id == id).toList();
    if (candidates.isEmpty) {
      throw FormatException('Tournament not found: $id');
    }
    return candidates.first;
  }

  @override
  Future<(List<Tournament>, int, bool)> search(String query) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) {
      return _buildResult(_store);
    }
    final needle = cleaned.toLowerCase();
    final filtered = _store.where((t) =>
        t.name.toLowerCase().contains(needle) ||
        t.courseLocation.toLowerCase().contains(needle) ||
        t.courseName.toLowerCase().contains(needle)
    ).toList();
    return _buildResult(filtered);
  }

  (List<Tournament>, int, bool) _buildResult(List<Tournament> source) {
    return (source, source.length, false);
  }
}
