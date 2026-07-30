import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/tournament/models/tournament.dart';
import 'package:golfie/tournament/models/skill_level.dart';
import 'package:golfie/tournament/models/tournament_format.dart';
import 'package:golfie/tournament/models/tournament_status.dart';

void main() {
  group('Tournament.fromJson', () {
    test('parses minimal PRD §5 payload correctly', () {
      final json = {
        'id': 'a1b2c3d4-1111-2222-3333-444455556666',
        'name': 'Emeralda Scramble Open',
        'course': {
          'name': 'Emeralda Golf Club',
          'location': 'South Jakarta',
        },
        'format': 'scramble',
        'min_skill': 'beginner',
        'max_fee_idr': 250000,
        'start_date': '2026-08-15T08:00:00Z',
        'end_date': '2026-08-15T17:00:00Z',
        'status': 'APPROVED',
        'registered_count': 12,
        'max_capacity': 20,
        'is_featured': false,
      };

      final t = Tournament.fromJson(json);

      expect(t.id, 'a1b2c3d4-1111-2222-3333-444455556666');
      expect(t.name, 'Emeralda Scramble Open');
      expect(t.courseName, 'Emeralda Golf Club');
      expect(t.courseLocation, 'South Jakarta');
      expect(t.format, TournamentFormat.scramble);
      expect(t.minSkill, SkillLevel.beginner);
      expect(t.maxFeeIdr, 250000);
      expect(t.startDate.year, 2026);
      expect(t.startDate.month, 8);
      expect(t.startDate.day, 15);
      expect(t.status, TournamentStatus.approved);
      expect(t.registeredCount, 12);
      expect(t.maxCapacity, 20);
      expect(t.isFeatured, false);
    });

    test('defaults isFeatured to false when missing', () {
      final json = {
        'id': 'id-1',
        'name': 'Test',
        'course': {'name': 'C', 'location': 'L'},
        'format': 'stableford',
        'min_skill': 'casual',
        'max_fee_idr': 100000,
        'start_date': '2026-09-01T00:00:00Z',
        'end_date': '2026-09-01T08:00:00Z',
        'status': 'PENDING',
        'registered_count': 0,
        'max_capacity': 16,
      };

      final t = Tournament.fromJson(json);

      expect(t.isFeatured, false);
    });

    test('throws FormatException on unknown format enum', () {
      final json = {
        'id': 'id-1',
        'name': 'Test',
        'course': {'name': 'C', 'location': 'L'},
        'format': 'no-such-format',
        'min_skill': 'casual',
        'max_fee_idr': 100000,
        'start_date': '2026-09-01T00:00:00Z',
        'end_date': '2026-09-01T08:00:00Z',
        'status': 'APPROVED',
        'registered_count': 0,
        'max_capacity': 16,
      };

      expect(() => Tournament.fromJson(json), throwsFormatException);
    });

    test('throws FormatException on unknown status enum', () {
      final json = {
        'id': 'id-1',
        'name': 'Test',
        'course': {'name': 'C', 'location': 'L'},
        'format': 'stableford',
        'min_skill': 'casual',
        'max_fee_idr': 100000,
        'start_date': '2026-09-01T00:00:00Z',
        'end_date': '2026-09-01T08:00:00Z',
        'status': 'FROZEN',
        'registered_count': 0,
        'max_capacity': 16,
      };

      expect(() => Tournament.fromJson(json), throwsFormatException);
    });
  });

  group('Tournament.flags', () {
    Tournament sample({required TournamentStatus status, required int registered, required int max}) {
      return Tournament(
        id: 'id',
        name: 'Test',
        courseName: 'C',
        courseLocation: 'L',
        format: TournamentFormat.scramble,
        minSkill: SkillLevel.beginner,
        maxFeeIdr: 100000,
        startDate: DateTime.utc(2026, 9, 1),
        endDate: DateTime.utc(2026, 9, 1, 8),
        status: status,
        registeredCount: registered,
        maxCapacity: max,
        isFeatured: false,
      );
    }

    test('isFull returns true when registered_count == max_capacity', () {
      expect(sample(status: TournamentStatus.approved, registered: 20, max: 20).isFull, true);
    });

    test('isFull returns false when registered_count < max_capacity', () {
      expect(sample(status: TournamentStatus.approved, registered: 12, max: 20).isFull, false);
    });

    test('isVisibleToPublic returns true only for APPROVED', () {
      expect(sample(status: TournamentStatus.approved, registered: 0, max: 16).isVisibleToPublic, true);
      expect(sample(status: TournamentStatus.pending, registered: 0, max: 16).isVisibleToPublic, false);
      expect(sample(status: TournamentStatus.rejected, registered: 0, max: 16).isVisibleToPublic, false);
    });

    test('feeLabel formats IDR with Rp prefix', () {
      final t = sample(status: TournamentStatus.approved, registered: 0, max: 16);
      expect(t.feeLabel, 'Rp 100.000');
    });
  });
}
