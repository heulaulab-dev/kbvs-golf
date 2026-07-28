import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kbvs_golf/tournament/providers/changes_notifier_tournament_provider.dart';
import 'package:kbvs_golf/tournament/models/tournament.dart';
import 'package:kbvs_golf/tournament/models/skill_level.dart';
import 'package:kbvs_golf/tournament/models/tournament_format.dart';
import 'package:kbvs_golf/tournament/models/tournament_status.dart';
import 'package:kbvs_golf/tournament/screens/tournament_detail_screen.dart';

void main() {
  Tournament _t(String name) => Tournament(
        id: 'test-123',
        name: name,
        courseName: 'Green Valley',
        courseLocation: 'Bandung',
        format: TournamentFormat.scramble,
        minSkill: SkillLevel.casual,
        maxFeeIdr: 150000,
        startDate: DateTime.utc(2026, 9, 1),
        endDate: DateTime.utc(2026, 9, 1, 14),
        status: TournamentStatus.approved,
        registeredCount: 3,
        maxCapacity: 16,
        isFeatured: false,
      );

  Future<void> pumpDetailScreen(
    WidgetTester tester,
    Tournament tournament,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TournamentDetailScreen(),
        ),
      ),
    );
    // Manually provide the tournament via route settings
    final navigator = find.byType(Navigator);
    // Actually we need to pump with the route that has arguments
    // Better approach: wrap in a Material page with pushed route
    // Let's use a different pattern: push the screen manually after initial pump
    await tester.pump();
  }

  testWidgets('displays tournament name', (tester) async {
    final tournament = _t('Pro Scramble Open');
    await tester.pumpWidget(
      Material(
        child: TournamentDetailScreen(),
      ),
    );
    // Simulate route with arguments
    tester.ensureActiveContext();
    // Push the screen with arguments using Navigator
    await tester.showPage(
      TournamentDetailScreen(),
      arguments: tournament,
    );
    expect(find.text('Pro Scramble Open'), findsOneWidget);
  });

  testWidgets('displays course name and location', (tester) async {
    final tournament = _t('Course Challenge');
    await tester.showPage(TournamentDetailScreen(), arguments: tournament);
    expect(find.text('Green Valley'), findsOneWidget);
    expect(find.text('Bandung'), findsOneWidget);
  });

  testWidgets('displays fee label', (tester) async {
    final tournament = _t('Cheap One');
    await tester.showPage(TournamentDetailScreen(), arguments: tournament);
    expect(find.text('Rp 150000'), findsOneWidget);
  });

  testWidgets('displays format as formatted string', (tester) async {
    final tournament = _t('Format Test');
    await tester.showPage(TournamentDetailScreen(), arguments: tournament);
    expect(find.text('Scramble'), findsOneWidget);
  });

  testWidgets('displays skill level as formatted string', (tester) async {
    final tournament = _t('Skill Test');
    await tester.showPage(TournamentDetailScreen(), arguments: tournament);
    expect(find.text('Casual'), findsOneWidget);
  });

  testWidgets('displays registration info', (tester) async {
    final tournament = _t('Reg Test');
    await tester.showPage(TournamentDetailScreen(), arguments: tournament);
    expect(find.text('3 / 16'), findsOneWidget);
    expect(find.text('Registered'), findsOneWidget);
  });
}
