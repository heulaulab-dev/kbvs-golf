import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/berita/repositories/http_berita_repository.dart';
import 'package:kbvs_golf/tournament/services/http_client.dart';

class FakeHttpClient implements HttpClient {
  final dynamic Function(String url, Map<String, String>?)? handler;

  FakeHttpClient({this.handler});

  @override
  Future<dynamic> getJson(
    String url, {
    Map<String, String>? queryParameters,
  }) async {
    if (handler != null) return handler!(url, queryParameters);
    return <String, dynamic>{};
  }
}

Map<String, dynamic> _sampleBerita({String id = 'b1', String title = 'Test'}) => {
      'id': id,
      'title': title,
      'source': 'golf.com',
      'url': 'https://example.com/$id',
      'imageUrl': null,
      'snippet': 'snippet',
      'publishedAt': '2026-07-28T08:00:00Z',
    };

void main() {
  group('HttpBeritaRepository.getTrending', () {
    test('maps items[] correctly', () async {
      final fake = FakeHttpClient(
        handler: (url, _) => {
          'items': [_sampleBerita(id: 'a'), _sampleBerita(id: 'b', title: 'B')],
          'cached': false,
          'fetchedAt': '2026-07-29T00:00:00Z',
          'source': 'seed',
        },
      );
      final repo = HttpBeritaRepository.withClient(fake, 'http://api');
      final items = await repo.getTrending();
      expect(items, hasLength(2));
      expect(items[0].id, 'a');
      expect(items[1].title, 'B');
    });

    test('throws FormatException on non-map response', () async {
      final fake = FakeHttpClient(handler: (_, __) => 'not a map');
      final repo = HttpBeritaRepository.withClient(fake, 'http://api');
      expect(repo.getTrending(), throwsA(isA<FormatException>()));
    });

    test('handles empty items[]', () async {
      final fake = FakeHttpClient(
        handler: (_, __) => {
          'items': <dynamic>[],
          'cached': false,
          'fetchedAt': '2026-07-29T00:00:00Z',
          'source': 'seed',
        },
      );
      final repo = HttpBeritaRepository.withClient(fake, 'http://api');
      final items = await repo.getTrending();
      expect(items, isEmpty);
    });
  });

  group('HttpBeritaRepository.search', () {
    test('sends q query parameter', () async {
      String? capturedQuery;
      final fake = FakeHttpClient(
        handler: (url, params) {
          capturedQuery = params?['q'];
          return {
            'query': params?['q'] ?? '',
            'items': [_sampleBerita(id: 's1')],
            'cached': false,
            'fetchedAt': '2026-07-29T00:00:00Z',
            'source': 'seed',
          };
        },
      );
      final repo = HttpBeritaRepository.withClient(fake, 'http://api');
      final items = await repo.search('jakarta');
      expect(capturedQuery, 'jakarta');
      expect(items, hasLength(1));
      expect(items[0].id, 's1');
    });

    test('empty query short-circuits without HTTP call', () async {
      final fake = FakeHttpClient();
      final repo = HttpBeritaRepository.withClient(fake, 'http://api');
      final items = await repo.search('');
      expect(items, isEmpty);
    });
  });
}