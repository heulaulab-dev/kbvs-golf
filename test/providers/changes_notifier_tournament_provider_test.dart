import 'package:flutter_test/flutter_test.dart';

import 'package:kbvs_golf/tournament/providers/changes_notifier_tournament_provider.dart';
import 'package:kbvs_golf/tournament/repositories/mock_tournament_repository.dart';
import 'package:kbvs_golf/tournament/repositories/tournament_repository.dart';
import 'package:kbvs_golf/tournament/models/tournament.dart';
import 'package:kbvs_golf/tournament/models/skill_level.dart';
import 'package:kbvs_golf/tournament/models/tournament_format.dart';
import 'package:kbvs_golf/tournament/models/tournament_status.dart';

void main() {
  final sampleTournaments = [
    Tournament(
      id: 't1',
      name: 'Scramble Pro',
      courseName: 'Green Valley',
      courseLocation: 'Bandung',
      format: TournamentFormat.scramble,
      minSkill: SkillLevel.beginner,
      maxFeeIdr: 200000,
      startDate: DateTime.utc(2026, 9, 1),
      endDate: DateTime.utc(2026, 9, 1, 12),
      status: TournamentStatus.approved,
      registeredCount: 5,
      maxCapacity: 16,
      isFeatured: true,
    ),
  ];

  /// Repo that always throws to test error paths.
  TournamentRepository _throwingRepo() {
    final inner = MockTournamentRepository(sampleTournaments);
    return _ThrowingRepository(inner);
  }

  group('ChangesNotifierTournamentProvider', () {
    test('initial state is loading + empty', () {
      final provider = ChangesNotifierTournamentProvider(
        repository: MockTournamentRepository(sampleTournaments),
      );
      expect(provider.tournaments, isEmpty);
      expect(provider.isLoading, isTrue);
      expect(provider.errorText, '');
      expect(provider.hasFirstPage, false);
      expect(provider.hasNextPage, false);
    });

    test('loadFirstPage populates tournaments when repo succeeds', () async {
      final provider = ChangesNotifierTournamentProvider(
        repository: MockTournamentRepository(sampleTournaments),
      );
      await provider.loadFirstPage();
      expect(provider.tournaments, hasLength(1));
      expect(provider.tournaments.first.name, 'Scramble Pro');
      expect(provider.isLoading, false);
      expect(provider.errorText, '');
    });

    test('loadFirstPage captures repo exception into errorText', () async {
      final provider = ChangesNotifierTournamentProvider(
        repository: _throwingRepo(),
      );
      await provider.loadFirstPage();
      expect(provider.isLoading, false);
      expect(provider.errorText, isNotEmpty);
      expect(provider.tournaments, isEmpty);
    });

    test('updateSearchQuery sets searchQuery state', () {
      final provider = ChangesNotifierTournamentProvider(
        repository: MockTournamentRepository(sampleTournaments),
      );
      provider.updateSearchQuery('  Scramble  ');
      expect(provider.searchQuery, 'Scramble');
    });
  });
}

/// Test repo that wraps a Mock repo and rethrows exceptions on every call.
class _ThrowingRepository implements TournamentRepository {
  final MockTournamentRepository _inner;
  _ThrowingRepository(this._inner);

  Never _fail() => throw const FormatException('repo exploded');

  @override
  Future<(List<Tournament>, int, bool)> getFirstPage() {
    _fail();
  }

  @override
  Future<(List<Tournament>, int, bool)> nextPage({String? cursor}) {
    _fail();
  }

  @override
  Future<(List<Tournament>, int, bool)> prevPage({String? cursor}) {
    _fail();
  }

  @override
  Future<Tournament> getById(String id) {
    _fail();
  }

  @override
  Future<(List<Tournament>, int, bool)> search(String query) {
    _fail();
  }
}
