import 'package:flutter/foundation.dart';

import '../models/tournament.dart';
import 'tournament_repository.dart';
import '../../persistence/mock_data_store.dart';

/// In-memory [TournamentRepository] implementation for UI testing
/// and offline development. Holds a mutable copy of tournaments that can
/// be modified (e.g., by registering users) without network calls.
/// 
/// Two modes:
/// - **Test mode** (default constructor): Non-persistent, uses provided seed data.
///   Ideal for unit tests where state needs to be isolated per test.
/// - **Persistent mode** (named constructor `persistent`): Loads data from
///   local storage (Hive) on first access and saves mutations back.
///   Suitable for development/debug where you want data to survive app restarts.
class MockTournamentRepository implements TournamentRepository {
  /// The underlying mutable store.
  final List<Tournament> _store;

  final bool _persistentMode;
  MockDataStore? _dataStore;

  /// Test constructor - non-persistent, uses seed data directly.
  MockTournamentRepository(List<Tournament> data)
      : _store = List.from(data),
        _persistentMode = false,
        _dataStore = null;

  /// Persistent constructor - loads from Hive, saves after mutations.
  MockTournamentRepository.persistent()
      : _store = [],
        _persistentMode = true,
        _dataStore = null;

  Future<void> _init() async {
    if (!_persistentMode || _dataStore != null) return;
    _dataStore = MockDataStore();
    await _dataStore!.init();
    // Load persisted data into store
    final persisted = await _dataStore!.loadAll();
    if (persisted.isNotEmpty) {
      _store.addAll(persisted);
    } else {
      // Empty store - seed with initial data
      final seedData = _buildSeededData();
      _store.addAll(seedData);
      await _dataStore!.saveAll(seedData);
    }
  }

  List<Tournament> _buildSeededData() {
    return [
      Tournament(
        id: 'seed-1',
        name: 'KBVS Scramble Pro',
        courseName: 'Green Valley',
        courseLocation: 'Bandung',
        format: TournamentFormat.scramble,
        minSkill: SkillLevel.beginner,
        maxFeeIdr: 200000,
        startDate: DateTime.utc(2026, 9, 1),
        endDate: DateTime.utc(2026, 9, 1, 12),
        status: TournamentStatus.approved,
        registeredCount: 0,
        maxCapacity: 16,
        isFeatured: true,
      ),
      Tournament(
        id: 'seed-2',
        name: 'Match Play Champ',
        courseName: 'Red Hills',
        courseLocation: 'Surabaya',
        format: TournamentFormat.matchPlay,
        minSkill: SkillLevel.competitive,
        maxFeeIdr: 500000,
        startDate: DateTime.utc(2026, 9, 15),
        endDate: DateTime.utc(2026, 9, 16, 18),
        status: TournamentStatus.approved,
        registeredCount: 0,
        maxCapacity: 16,
        isFeatured: false,
      ),
      Tournament(
        id: 'seed-3',
        name: 'Casual Stableford',
        courseName: 'Coastal Links',
        courseLocation: 'Bali',
        format: TournamentFormat.stableford,
        minSkill: SkillLevel.casual,
        maxFeeIdr: 150000,
        startDate: DateTime.utc(2026, 10, 1),
        endDate: DateTime.utc(2026, 10, 1, 14),
        status: TournamentStatus.pending,
        registeredCount: 0,
        maxCapacity: 18,
        isFeatured: false,
      ),
    ];
  }

  @override
  Future<(List<Tournament>, int, bool)> getFirstPage() async {
    if (_persistentMode) await _init();
    return _buildResult(_store.toList());
  }

  @override
  Future<(List<Tournament>, int, bool)> nextPage({String? cursor}) async {
    if (_persistentMode) await _init();
    if (kDebugMode && cursor == null) {
      debugPrint('MockTournamentRepository.nextPage called without cursor');
    }
    return _buildResult(_store.toList());
  }

  @override
  Future<(List<Tournament>, int, bool)> prevPage({String? cursor}) async {
    if (_persistentMode) await _init();
    if (cursor == null) {
      return (<Tournament>[], 0, false);
    }
    return _buildResult(_store.toList());
  }

  @override
  Future<Tournament> getById(String id) async {
    if (_persistentMode) await _init();
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
    if (_persistentMode) await _init();
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
    if (_persistentMode) await _init();
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
    // Save back to persistent store if in persistent mode
    if (_persistentMode && _dataStore != null) {
      await _dataStore!.saveAll(_store);
    }
  }

  (List<Tournament>, int, bool) _buildResult(List<Tournament> source) {
    return (source, source.length, false);
  }

  /// Close the underlying data store if used in persistent mode.
  Future<void> close() async {
    if (_persistentMode && _dataStore != null) {
      await _dataStore!.close();
    }
  }
}