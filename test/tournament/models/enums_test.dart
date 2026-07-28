import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/tournament/models/skill_level.dart';
import 'package:kbvs_golf/tournament/models/tournament_format.dart';
import 'package:kbvs_golf/tournament/models/tournament_status.dart';

void main() {
  group('SkillLevel', () {
    test('parses all PRD values', () {
      expect(SkillLevel.fromApi('beginner'), SkillLevel.beginner);
      expect(SkillLevel.fromApi('casual'), SkillLevel.casual);
      expect(SkillLevel.fromApi('competitive'), SkillLevel.competitive);
      expect(SkillLevel.fromApi('pro'), SkillLevel.pro);
    });

    test('throws on unknown value', () {
      expect(() => SkillLevel.fromApi('legend'), throwsFormatException);
    });
  });

  group('TournamentFormat', () {
    test('parses all PRD enum values', () {
      expect(TournamentFormat.fromApi('match-play'), TournamentFormat.matchPlay);
      expect(TournamentFormat.fromApi('stableford'), TournamentFormat.stableford);
      expect(TournamentFormat.fromApi('scramble'), TournamentFormat.scramble);
      expect(TournamentFormat.fromApi('best-ball'), TournamentFormat.bestBall);
      expect(TournamentFormat.fromApi('championship'), TournamentFormat.championship);
    });

    test('throws on unknown value', () {
      expect(() => TournamentFormat.fromApi('skins'), throwsFormatException);
    });
  });

  group('TournamentStatus', () {
    test('parses all PRD states', () {
      expect(TournamentStatus.fromApi('PENDING'), TournamentStatus.pending);
      expect(TournamentStatus.fromApi('APPROVED'), TournamentStatus.approved);
      expect(TournamentStatus.fromApi('REJECTED'), TournamentStatus.rejected);
      expect(TournamentStatus.fromApi('FULL'), TournamentStatus.full);
    });

    test('throws on unknown value', () {
      expect(() => TournamentStatus.fromApi('CANCELLED'), throwsFormatException);
    });
  });
}
