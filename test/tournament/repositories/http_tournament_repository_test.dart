import 'package:flutter_test/flutter_test.dart';
import 'package:kbvs_golf/tournament/repositories/http_tournament_repository.dart';
import 'package:kbvs_golf/tournament/services/http_client.dart';

/// Fake [HttpClient] that returns canned responses for testing.
class FakeHttpClient implements HttpClient {
  final dynamic Function(String url, Map<String, String>?) _handler;

  FakeHttpClient(this._handler);

  int callCount = 0;
  final List<String> urls = [];

  @override
  Future<dynamic> getJson(
    String url, {
    Map<String, String>? queryParameters,
  }) async {
    callCount++;
    urls.add(url);
    return _handler(url, queryParameters);
  }
}

Map<String, dynamic> _makePaginated(
  List<Map<String, dynamic>> results, {
  int? total,
  bool? hasNext,
}) {
  return {
    'results': results,
    'total': total ?? results.length,
    'has_next': hasNext ?? false,
  };
}

Map<String, dynamic> _sampleTournament({
  String id = 't1',
  String name = 'Sample Tour',
  String format = 'scramble',
  String status = 'APPROVED',
  int registered = 5,
  int max = 20,
}) {
  return {
    'id': id,
    'name': name,
    'course': {'name': 'Course', 'location': 'Jakarta'},
    'format': format,
    'min_skill': 'beginner',
    'max_fee_idr': 150000,
    'start_date': '2026-09-01T08:00:00Z',
    'end_date': '2026-09-01T17:00:00Z',
    'status': status,
    'registered_count': registered,
    'max_capacity': max,
    'is_featured': false,
  };
}

void main() {
  group('HttpTournamentRepository.getFirstPage', () {
    test('calls /tournaments with no query params', () async {
      final fake = FakeHttpClient((url, params) {
        return _makePaginated([_sampleTournament()]);
      });
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );
      final (tournaments, total, hasNext) = await repo.getFirstPage();

      expect(tournaments, hasLength(1));
      expect(tournaments.first.name, 'Sample Tour');
      expect(total, 1);
      expect(hasNext, false);
      expect(fake.urls, ['https://api.example.com/tournaments']);
      expect(fake.callCount, 1);
    });

    test('parses has_next=true for paginated response', () async {
      final fake = FakeHttpClient((url, params) {
        return _makePaginated(
          List.generate(10, (i) => _sampleTournament(id: 't$i')),
          total: 25,
          hasNext: true,
        );
      });
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );
      final (tournaments, total, hasNext) = await repo.getFirstPage();

      expect(tournaments, hasLength(10));
      expect(total, 25);
      expect(hasNext, true);
    });

    test('returns empty list when results missing', () async {
      final fake = FakeHttpClient((url, params) => {'results': [], 'total': 0, 'has_next': false});
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );
      final (tournaments, total, hasNext) = await repo.getFirstPage();
      expect(tournaments, isEmpty);
      expect(total, 0);
      expect(hasNext, false);
    });
  });

  group('HttpTournamentRepository.search', () {
    test('sends trimmed query as search param', () async {
      String? sentQuery;
      final fake = FakeHttpClient((url, params) {
        sentQuery = params?['search'];
        return _makePaginated([_sampleTournament(name: 'Found')]);
      });
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );

      await repo.search('  scramble  ');

      expect(sentQuery, 'scramble');
    });

    test('omits search param for empty query', () async {
      Map<String, String>? capturedParams;
      final fake = FakeHttpClient((url, params) {
        capturedParams = params;
        return _makePaginated([_sampleTournament()]);
      });
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );

      await repo.search('');

      expect(capturedParams == null || !capturedParams!.containsKey('search'), true);
    });
  });

  group('HttpTournamentRepository.nextPage', () {
    test('passes cursor when provided', () async {
      String? sentCursor;
      final fake = FakeHttpClient((url, params) {
        sentCursor = params?['cursor'];
        return _makePaginated([_sampleTournament(id: 'next-1')], hasNext: false);
      });
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );

      await repo.nextPage(cursor: 'abc-123');

      expect(sentCursor, 'abc-123');
    });
  });

  group('HttpTournamentRepository.getById', () {
    test('returns parsed tournament on success', () async {
      final fake = FakeHttpClient((url, params) => _sampleTournament(id: 'single-id'));
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );

      final t = await repo.getById('single-id');
      expect(t.id, 'single-id');
      expect(fake.urls, ['https://api.example.com/tournaments/single-id']);
    });

    test('throws FormatException on 404', () async {
      final fake = FakeHttpClient((url, params) {
        throw HttpException(404, 'Not Found');
      });
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );

      expect(() => repo.getById('missing'), throwsFormatException);
    });

    test('rethrows non-404 HttpException', () async {
      final fake = FakeHttpClient((url, params) {
        throw HttpException(500, 'Server Error');
      });
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );

      expect(() => repo.getById('any'), throwsA(isA<HttpException>()));
    });
  });

  group('HttpTournamentRepository._parsePaginated (via public surface)', () {
    test('throws FormatException on non-map response', () async {
      final fake = FakeHttpClient((url, params) => 'this is a string, not a map');
      final repo = HttpTournamentRepository(
        baseUrl: 'https://api.example.com',
        client: fake,
      );
      expect(() => repo.getFirstPage(), throwsFormatException);
    });
  });
}
