import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/models/berita.dart';
import 'package:kbvs_golf/berita/providers/berita_provider.dart';
import 'package:kbvs_golf/berita/repositories/berita_repository.dart';

class _StubRepo implements BeritaRepository {
  final List<Berita> trending;
  final Map<String, List<Berita>> searchHits;
  bool shouldThrow = false;

  _StubRepo({this.trending = const [], this.searchHits = const {}});

  @override
  Future<List<Berita>> getTrending() async {
    if (shouldThrow) throw Exception('boom');
    return trending;
  }

  @override
  Future<List<Berita>> search(String query) async {
    if (shouldThrow) throw Exception('boom');
    return searchHits[query] ?? [];
  }
}

Berita _b(String id, [String title = 't']) => Berita(
      id: id,
      title: title,
      source: 'golf.com',
      url: 'https://example.com/$id',
      imageUrl: null,
      snippet: '',
      publishedAt: DateTime.now(),
    );

void main() {
  group('ChangesNotifierBeritaProvider.loadTrending', () {
    test('sets items on success', () async {
      final repo = _StubRepo(
        trending: [_b('a'), _b('b')],
      );
      final p = ChangesNotifierBeritaProvider(repository: repo);
      await p.loadTrending();
      expect(p.items, hasLength(2));
      expect(p.isLoading, isFalse);
      expect(p.errorText, isEmpty);
      expect(p.hasSearched, isFalse);
      expect(p.searchQuery, isEmpty);
    });

    test('captures error on failure', () async {
      final repo = _StubRepo()..shouldThrow = true;
      final p = ChangesNotifierBeritaProvider(repository: repo);
      await p.loadTrending();
      expect(p.isLoading, isFalse);
      expect(p.errorText, contains('Failed to load news'));
      expect(p.items, isEmpty);
    });
  });

  group('ChangesNotifierBeritaProvider.search', () {
    test('with empty query falls back to trending', () async {
      final repo = _StubRepo(trending: [_b('a')]);
      final p = ChangesNotifierBeritaProvider(repository: repo);
      await p.search('   ');
      expect(p.items, hasLength(1));
      expect(p.searchQuery, isEmpty);
      expect(p.hasSearched, isFalse);
    });

    test('with valid query populates items and sets searchQuery', () async {
      final repo = _StubRepo(searchHits: {'jakarta': [_b('a')]});
      final p = ChangesNotifierBeritaProvider(repository: repo);
      await p.search('jakarta');
      expect(p.items, hasLength(1));
      expect(p.searchQuery, 'jakarta');
      expect(p.hasSearched, isTrue);
    });

    test('empty result is not an error', () async {
      final repo = _StubRepo();
      final p = ChangesNotifierBeritaProvider(repository: repo);
      await p.search('nothing');
      expect(p.items, isEmpty);
      expect(p.errorText, isEmpty);
    });

    test('captures error on failure', () async {
      final repo = _StubRepo()..shouldThrow = true;
      final p = ChangesNotifierBeritaProvider(repository: repo);
      await p.search('x');
      expect(p.errorText, contains('Search failed'));
    });
  });

  group('notifyListeners', () {
    test('fires on loadTrending success', () async {
      final repo = _StubRepo(trending: [_b('a')]);
      final p = ChangesNotifierBeritaProvider(repository: repo);
      var count = 0;
      p.addListener(() => count++);
      await p.loadTrending();
      expect(count, greaterThan(0));
    });

    test('fires on search success', () async {
      final repo = _StubRepo(searchHits: {'q': [_b('a')]});
      final p = ChangesNotifierBeritaProvider(repository: repo);
      var count = 0;
      p.addListener(() => count++);
      await p.search('q');
      expect(count, greaterThan(0));
    });
  });
}