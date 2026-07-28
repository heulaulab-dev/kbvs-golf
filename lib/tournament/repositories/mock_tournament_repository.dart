import 'package:flutter/foundation.dart';

import '../models/tournament.dart';
import 'tournament_repository.dart';

/// In-memory [TournamentRepository] implementation for UI testing
/// and offline development. Holds a mutable copy of tournaments that can
/// be modified (e.g., by registering users) without network calls.
class MockTournamentRepository implements TournamentRepository {
  /// The underlying mutable store.
  final List<Tournament> _store;

  MockTournamentRepository(List<Tournament> data)
      : _store = List.from(data); // Make a mutable copy

  @override
  Future<(List<Tournament>, int, bool)> getFirstPage() async {
    return _buildResult(_store.toList());
  }

  @override
  Future<(List<Tournament>, int, bool)> nextPage({String? cursor}) async {
    if (kDebugMode && cursor == null) {
      debugPrint('MockTournamentRepository.nextPage called without cursor');
    }
    return _buildResult(_store.toList());
  }

  @override
  Future<(List<Tournament>, int, bool)> prevPage({String? cursor}) async {
    // No backward pagination token = no previous page.
    if (cursor == null) {
      return (<Tournament>[], 0, false);
    }
    return _buildResult(_store.toList());
  }

  @override
  Future<Tournament> getById(String id) async {
    final candidates = _store.where((t) => t.id == id).toList();
    if (candidates.isEmpty) {
      throw FormatException('Tournament not found: $id');
    }
    // Return a copy to prevent external mutation
    return Tournament.fromJson(
      _store.firstWhere((t) => t.id == id).toJson() as Map<String, dynamic>,
    );
  }

  @override
  Future<(List<Tournament>, int, bool)> search(String query) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) {
      return _buildResult(_store.toList());
    }
    final needle = cleaned.toLowerCase();
    final filtered = _store.where((t) =>
        t.name.toLowerCase().contains(needle) ||
        t.courseLocation.toLowerCase().contains(needle) ||
        t.courseName.toLowerCase().contains(needle))
        .toList();
    return _buildResult(filtered);
  }

  @override
  Future<void> register(String tournamentId) async {
    // Find tournament and increment registered count
    final index = _store.indexWhere((t) => t.id == tournamentId);
    if (index == -1) {
      throw FormatException('Tournament not found: $tournamentId');
    }
    final tournament = _store[index];
    _store[index] = Tournament(
      id: tournament.id,
      name: tournament.name,
      courseName: tournament.courseName,
      courseLocation: tournament.courseLocation,
      format: tournament.format,
      minSkill: tournament.minSkill,
      maxFeeIdr: tournament.maxFeeIdr,
      startDate: tournament.startDate,
      endDate: tournament.endDate,
      status: tournament.status,
      registeredCount: tournament.registeredCount + 1,
      maxCapacity: tournament.maxCapacity,
      isFeatured: tournament.isFeatured,
    );
  }

  (List<Tournament>, int, bool) _buildResult(List<Tournament> source) {
    return (source, source.length, false);
  }
}
