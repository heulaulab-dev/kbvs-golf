import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:golfie/tournament/providers/changes_notifier_tournament_provider.dart';
import 'package:golfie/tournament/models/tournament.dart';
import 'package:golfie/tournament/models/skill_level.dart';
import 'package:golfie/tournament/models/tournament_format.dart';
import 'package:golfie/tournament/models/tournament_status.dart';
import 'package:golfie/tournament/repositories/mock_tournament_repository.dart';
import 'package:golfie/tournament/screens/tournament_detail_screen.dart';

void main() {
  Tournament t(String name) => Tournament(
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

  Future<void> pumpDetail(
    WidgetTester tester,
    Tournament tournament,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ChangesNotifierTournamentProvider>(
            create: (_) => ChangesNotifierTournamentProvider(
              repository: MockTournamentRepository([tournament]),
            ),
          ),
        ],
        child: MaterialApp(
          home: const _SentinelHome(),
        ),
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const TournamentDetailScreen(),
        settings: RouteSettings(arguments: tournament),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('displays tournament name in appbar and body', (tester) async {
    await pumpDetail(tester, t('Pro Scramble Open'));
    expect(find.text('Pro Scramble Open'), findsAtLeastNWidgets(1));
  });

  testWidgets('displays course location', (tester) async {
    await pumpDetail(tester, t('Course Challenge'));
    expect(find.text('Bandung'), findsOneWidget);
  });

  testWidgets('displays fee label', (tester) async {
    await pumpDetail(tester, t('Cheap One'));
    expect(find.text('Rp 150000'), findsOneWidget);
  });

  testWidgets('displays format as formatted string', (tester) async {
    await pumpDetail(tester, t('Format Test'));
    expect(find.text('Scramble'), findsOneWidget);
  });

  testWidgets('renders details, players, and rules tabs', (tester) async {
    await pumpDetail(tester, t('Tab Test'));
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Players'), findsOneWidget);
    expect(find.text('Rules'), findsOneWidget);
  });

  testWidgets('displays register CTA', (tester) async {
    await pumpDetail(tester, t('Reg Test'));
    expect(find.text('Register Now'), findsOneWidget);
  });
}

class _SentinelHome extends StatelessWidget {
  const _SentinelHome();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
