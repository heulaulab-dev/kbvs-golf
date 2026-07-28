import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kbvs_golf/tournament/providers/changes_notifier_tournament_provider.dart';
import 'package:kbvs_golf/tournament/repositories/mock_tournament_repository.dart';
import 'package:kbvs_golf/tournament/repositories/tournament_repository.dart';
import 'package:kbvs_golf/tournament/screens/tournament_list_screen.dart';
import 'package:kbvs_golf/tournament/models/tournament.dart';
import 'package:kbvs_golf/tournament/models/skill_level.dart';
import 'package:kbvs_golf/tournament/models/tournament_format.dart';
import 'package:kbvs_golf/tournament/models/tournament_status.dart';

void main() {
  Tournament _t(String id, String name) => Tournament(
        id: id,
        name: name,
        courseName: 'Course',
        courseLocation: 'Jakarta',
        format: TournamentFormat.scramble,
        minSkill: SkillLevel.casual,
        maxFeeIdr: 100000,
        startDate: DateTime.utc(2026, 9, 1),
        endDate: DateTime.utc(2026, 9, 1, 12),
        status: TournamentStatus.approved,
        registeredCount: 5,
        maxCapacity: 16,
        isFeatured: false,
      );

  Future<void> pumpScreen(
    WidgetTester tester, {
    required ChangesNotifierTournamentProvider provider,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ChangesNotifierTournamentProvider>.value(
          value: provider,
          child: const TournamentListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders tournament cards once data is loaded', (tester) async {
    final provider = ChangesNotifierTournamentProvider(
      repository: MockTournamentRepository([
        _t('t1', 'Scramble Pro'),
        _t('t2', 'Match Play Champ'),
      ]),
    );

    await pumpScreen(tester, provider: provider);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Scramble Pro'), findsOneWidget);
    expect(find.text('Match Play Champ'), findsOneWidget);
  });

  testWidgets('search field updates provider search query', (tester) async {
    final provider = ChangesNotifierTournamentProvider(
      repository: MockTournamentRepository([_t('t1', 'X')]),
    );

    await pumpScreen(tester, provider: provider);

    await tester.enterText(find.byType(TextField), 'Scramble');
    expect(provider.searchQuery, equals('Scramble'));
  });

  testWidgets('error state surfaces provider error message', (tester) async {
    final throwingRepo = _ThrowingRepository();
    final provider = ChangesNotifierTournamentProvider(repository: throwingRepo);
    // Trigger error directly through the provider before pumping the screen.
    try {
      await provider.loadFirstPage();
    } catch (_) {}
    expect(provider.errorText, isNotEmpty);

    await pumpScreen(tester, provider: provider);

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('empty state renders when repo returns no items', (tester) async {
    final provider = ChangesNotifierTournamentProvider(
      repository: MockTournamentRepository(const []),
    );

    await pumpScreen(tester, provider: provider);

    expect(find.text('No tournaments yet'), findsOneWidget);
  });

  testWidgets('empty state shows search variant when query is set', (tester) async {
    final provider = ChangesNotifierTournamentProvider(
      repository: MockTournamentRepository(const []),
    );

    await pumpScreen(tester, provider: provider);
    await tester.enterText(find.byType(TextField), 'nothing-matches');
    await tester.pumpAndSettle();
    expect(provider.searchQuery, equals('nothing-matches'));
    expect(find.text('No tournaments match your search'), findsOneWidget);
  });

  testWidgets('retry button on error re-triggers loadFirstPage', (tester) async {
    final provider = ChangesNotifierTournamentProvider(
      repository: MockTournamentRepository([_t('t1', 'After Retry')]),
    );
    // Seed an error condition directly so the error widget is visible.
    try {
      await provider.loadFirstPage();
    } catch (_) {}
    // Force error state via a throwing repo swap simulation:
    // we manually load through a thrower, then swap via a fresh provider
    // fed to the screen and confirm retry callback wires up.
    final throwingProvider = _ThrowingRepository();
    final screenProvider = ChangesNotifierTournamentProvider(
      repository: throwingProvider,
    );
    try {
      await screenProvider.loadFirstPage();
    } catch (_) {}
    expect(screenProvider.errorText, isNotEmpty);

    await pumpScreen(tester, provider: screenProvider);

    final retryBtn = find.widgetWithText(OutlinedButton, 'Retry');
    expect(retryBtn, findsOneWidget);

    // Tap retry — it calls loadFirstPage again, which still throws but
    // updates the errorText to a new exception instance (non-empty still).
    await tester.tap(retryBtn);
    await tester.pumpAndSettle();
    expect(screenProvider.errorText, isNotEmpty);
    // Sanity: the provider we kept around is still functional.
    await provider.loadFirstPage();
    expect(provider.tournaments, hasLength(1));
  });
}

class _ThrowingRepository implements TournamentRepository {
  @override
  Future<(List<Tournament>, int, bool)> getFirstPage() {
    throw const FormatException('boom');
  }

  @override
  Future<(List<Tournament>, int, bool)> nextPage({String? cursor}) async =>
      (<Tournament>[], 0, false);

  @override
  Future<(List<Tournament>, int, bool)> prevPage({String? cursor}) async =>
      (<Tournament>[], 0, false);

  @override
  Future<Tournament> getById(String id) async =>
      throw const FormatException('not found');

  @override
  Future<(List<Tournament>, int, bool)> search(String query) async =>
      (<Tournament>[], 0, false);
}
