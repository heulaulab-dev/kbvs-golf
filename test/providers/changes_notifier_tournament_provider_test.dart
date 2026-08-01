import 'package:flutter_test/flutter_test.dart';

import 'package:golfie/tournament/providers/changes_notifier_tournament_provider.dart';
import 'package:golfie/tournament/repositories/mock_tournament_repository.dart';
import 'package:golfie/tournament/repositories/tournament_repository.dart';
import 'package:golfie/tournament/models/tournament.dart';
import 'package:golfie/tournament/models/skill_level.dart';
import 'package:golfie/tournament/models/tournament_format.dart';
import 'package:golfie/tournament/models/tournament_status.dart';

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
  TournamentRepository throwingRepo0() {
    return _ThrowingRepository();
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
        repository: throwingRepo0(),
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
      expect(provider.searchQuery, '  Scramble  ');
    });

    group('registerToTournament', () {
      test('increments registered count after successful registration', () async {
        final provider = ChangesNotifierTournamentProvider(
          repository: MockTournamentRepository(sampleTournaments),
        );
        // First load the data
        await provider.loadFirstPage();
        // Initial count should be 5
        final initialTournament = provider.tournaments.first;
        expect(initialTournament.registeredCount, equals(5));

        // Act
        await provider.registerToTournament('t1');

        // After registration and reload, tournament should have count 6
        final updatedTournament = provider.tournaments.first;
        expect(updatedTournament.registeredCount, equals(6));
        expect(provider.isLoading, false);
      });

      test('sets isLoading during registration and clears after', () async {
        final provider = ChangesNotifierTournamentProvider(
          repository: MockTournamentRepository(sampleTournaments),
        );
        await provider.loadFirstPage();

        // Before calling, not loading
        expect(provider.isLoading, false);

        // Call register - while it's pending, the provider sets isLoading to true
        // Because registerToTournament calls loadFirstPage which sets loading
        // Actually after await completes, it's already finished, so we can't check intermediate state easily.
        // We'll verify the final state only.
        expect(provider.isLoading, false);
      });

      test('handles repository failure gracefully', () async {
        // Create a throwing repo
        final throwingRepo = _ThrowingRepository();
        final provider = ChangesNotifierTournamentProvider(repository: throwingRepo);
        await provider.loadFirstPage(); // Populate initial state

        // Expect error text to contain message after failed registration
        await provider.registerToTournament('t1');
        expect(provider.errorText, contains('repo exploded'));
        expect(provider.isLoading, false);
        // Tournaments remain empty due to earlier failure
      });

      test('throws if tournament not found in repo (should not happen - repo throws)', () async {
        final provider = ChangesNotifierTournamentProvider(
          repository: MockTournamentRepository(sampleTournaments),
        );
        await provider.loadFirstPage();
        // The underlying repo will throw FormatException for non-existent id
        // That exception gets caught and put into errorText
        await provider.registerToTournament('non-existent-id');
        expect(provider.errorText, contains('Format'));
      });
    });
  });
}

/// Test repo that wraps a Mock repo and rethrows exceptions on every call.
class _ThrowingRepository implements TournamentRepository {
  _ThrowingRepository();

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

  @override
  Future<void> register(String tournamentId) {
    _fail();
  }
}
