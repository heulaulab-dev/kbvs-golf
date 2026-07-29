import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/berita/models/berita.dart';
import 'package:golfie/berita/repositories/berita_repository.dart';
import 'package:golfie/berita/screens/berita_list_screen.dart';

class _StubRepo implements BeritaRepository {
  final List<Berita> trending;
  final Map<String, List<Berita>> searchHits;
  Duration delay;
  bool shouldThrow = false;

  _StubRepo({
    this.trending = const [],
    this.searchHits = const {},
    this.delay = Duration.zero,
    this.shouldThrow = false,
  });

  @override
  Future<List<Berita>> getTrending() async {
    await Future.delayed(delay);
    if (shouldThrow) throw Exception('boom');
    return trending;
  }

  @override
  Future<List<Berita>> search(String query) async {
    await Future.delayed(delay);
    if (shouldThrow) throw Exception('boom');
    return searchHits[query] ?? [];
  }
}

Berita _b(String id, String title) => Berita(
      id: id,
      title: title,
      source: 'golf.com',
      url: 'https://example.com/$id',
      imageUrl: null,
      snippet: 'snippet $id',
      publishedAt: DateTime(2026, 7, 28),
    );

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('renders loading spinner then list', (tester) async {
    final repo = _StubRepo(
      trending: [_b('a', 'Asian Tour Update'), _b('b', 'Best Putters')],
      delay: const Duration(milliseconds: 1),
    );
    await tester.pumpWidget(_wrap(BeritaListScreen(repository: repo)));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Asian Tour Update'), findsOneWidget);
    expect(find.text('Best Putters'), findsOneWidget);
  });

  testWidgets('shows error view with retry on failure', (tester) async {
    final repo = _StubRepo(shouldThrow: true);
    await tester.pumpWidget(_wrap(BeritaListScreen(repository: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows empty state when no items', (tester) async {
    final repo = _StubRepo();
    await tester.pumpWidget(_wrap(BeritaListScreen(repository: repo)));
    await tester.pumpAndSettle();
    expect(find.text('No news yet'), findsOneWidget);
  });

  testWidgets('search shows no-results message', (tester) async {
    final repo = _StubRepo(searchHits: {});
    await tester.pumpWidget(_wrap(BeritaListScreen(repository: repo)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'xyzqqq');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.textContaining('No results for'), findsOneWidget);
  });

  testWidgets('search returns matching items', (tester) async {
    final repo = _StubRepo(
      searchHits: {'jakarta': [_b('j', 'Jakarta Rankings')]},
    );
    await tester.pumpWidget(_wrap(BeritaListScreen(repository: repo)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'jakarta');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Jakarta Rankings'), findsOneWidget);
  });
}