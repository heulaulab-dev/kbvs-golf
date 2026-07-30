import 'package:flutter_test/flutter_test.dart';

import 'package:golfie/tournament/models/tournament.dart';
import 'package:golfie/tournament/repositories/mock_tournament_repository.dart';
import 'package:golfie/tournament/models/skill_level.dart';
import 'package:golfie/tournament/models/tournament_format.dart';
import 'package:golfie/tournament/models/tournament_status.dart';

void main() {
  final _sampleTournaments = [
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
    Tournament(
      id: 't2',
      name: 'Match Play Champ',
      courseName: 'Red Hills',
      courseLocation: 'Surabaya',
      format: TournamentFormat.matchPlay,
      minSkill: SkillLevel.competitive,
      maxFeeIdr: 500000,
      startDate: DateTime.utc(2026, 9, 15),
      endDate: DateTime.utc(2026, 9, 16, 18),
      status: TournamentStatus.approved,
      registeredCount: 14,
      maxCapacity: 16,
      isFeatured: false,
    ),
    Tournament(
      id: 't3',
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

  MockTournamentRepository _createMock([List<Tournament>? data]) {
    return MockTournamentRepository(data ?? _sampleTournaments);
  }

  group('MockTournamentRepository.getFirstPage', () {
    test('returns all tournaments when no filter', () async {
      final repo = _createMock();
      final (tournaments, total, hasNext) = await repo.getFirstPage();

      expect(tournaments, hasLength(3));
      expect(total, 3);
      expect(hasNext, false);
    });

    test('correctly sorts by ID (alphabetical order from list)', () async {
      final repo = _createMock();
      final (tournaments, _, _) = await repo.getFirstPage();

      expect(tournaments[0].id, 't1');
      expect(tournaments[1].id, 't2');
      expect(tournaments[2].id, 't3');
    });

    test('return empty when no data provided', () async {
      final repo = _createMock([]);
      final (tournaments, _, _) = await repo.getFirstPage();
      expect(tournaments, isEmpty);
    });
  });

  group('MockTournamentRepository.search', () {
    test('filters by name case-insensitively', () async {
      final repo = _createMock();
      final (tournaments, _, _) = await repo.search('scramble');

      expect(tournaments, hasLength(1));
      expect(tournaments[0].name, 'Scramble Pro');
    });

    test('search returns empty when no match', () async {
      final repo = _createMock();
      final (tournaments, _, _) = await repo.search('unknown-term');
      expect(tournaments, isEmpty);
    });

    test('trimmed whitespace handled correctly', () async {
      final repo = _createMock();
      final (tournaments, _, _) = await repo.search('  scramble  ');
      expect(tournaments, hasLength(1));
    });

    test('empty query returns all tournaments', () async {
      final repo = _createMock();
      final (tournaments, _, _) = await repo.search('');
      expect(tournaments, hasLength(3));
    });
  });

  group('MockTournamentRepository.nextPage/prevPage', () {
    test('cursors return same set (simplified - no pagination offset)', () async {
      final repo = _createMock();
      final (t1, _, _) = await repo.getFirstPage();
      final (t2, _, _) = await repo.nextPage(cursor: 'any-cursor');

      expect(t2.length, t1.length);
    });

    test('prevPage without cursor returns empty', () async {
      final repo = _createMock();
      final (result, _, _) = await repo.prevPage();
      expect(result, isEmpty);
    });
  });

  group('MockTournamentRepository.getById', () {
    test('returns tournament by matching ID', () async {
      final repo = _createMock();
      final t = await repo.getById('t1');
      expect(t.id, 't1');
      expect(t.name, 'Scramble Pro');
    });

    test('throws FormatException for non-existent ID', () async {
      final repo = _createMock();
      expect(() => repo.getById('fake-id'), throwsA(isA<FormatException>()));
    });
  });

  group('MockTournamentRepository.register', () {
    late MockTournamentRepository repo;

    setUp(() {
      repo = _createMock();
    });

    test('increments registeredCount for specified tournament', () async {
      // Arrange - initial state
      final initial = await repo.getById('t1');
      expect(initial.registeredCount, equals(5));

      // Act
      await repo.register('t1');

      // Assert
      final updated = await repo.getById('t1');
      expect(updated.registeredCount, equals(6));
    });

    test('registering same tournament twice increments twice', () async {
      // Initial: count is 5
      await repo.register('t1');
      final after1 = await repo.getById('t1');
      expect(after1.registeredCount, equals(6));

      await repo.register('t1');
      final after2 = await repo.getById('t1');
      expect(after2.registeredCount, equals(7));
    });

    test('throws FormatException when tournament not found', () async {
      // Act & Assert
      await expectLater(
        () => repo.register('non-existent-id'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
