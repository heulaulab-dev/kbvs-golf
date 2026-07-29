import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/berita/models/berita.dart';

void main() {
  group('Berita.fromJson', () {
    test('parses all fields', () {
      final json = {
        'id': 'x1',
        'title': 'Hello',
        'source': 'golf.com',
        'url': 'https://golf.com/x',
        'imageUrl': 'https://img/x.jpg',
        'snippet': 'A snippet',
        'publishedAt': '2026-07-28T08:00:00Z',
      };
      final b = Berita.fromJson(json);
      expect(b.id, 'x1');
      expect(b.title, 'Hello');
      expect(b.source, 'golf.com');
      expect(b.url, 'https://golf.com/x');
      expect(b.imageUrl, 'https://img/x.jpg');
      expect(b.snippet, 'A snippet');
      expect(b.publishedAt.toUtc(), DateTime.utc(2026, 7, 28, 8, 0, 0));
    });

    test('null imageUrl and missing fields handled gracefully', () {
      final json = {
        'id': 'x2',
        'title': 'No image',
        'url': 'https://example.com',
        'snippet': '',
        'publishedAt': 'not-a-date',
      };
      final b = Berita.fromJson(json);
      expect(b.imageUrl, isNull);
      expect(b.source, '');
      expect(b.snippet, '');
      expect(b.publishedAt, isNotNull); // falls back to DateTime.now()
    });
  });

  group('Berita.toJson', () {
    test('round-trips', () {
      final b = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'https://e.com',
        imageUrl: null,
        snippet: 'sn',
        publishedAt: DateTime.utc(2026, 1, 2),
      );
      final back = Berita.fromJson(b.toJson());
      expect(back, b);
    });
  });

  group('Berita.relativeDate', () {
    test('Just now for sub-minute', () {
      final b = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: '',
        publishedAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      expect(b.relativeDate, 'Just now');
    });

    test('minutes ago', () {
      final b = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: '',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(b.relativeDate, '5m ago');
    });

    test('hours ago', () {
      final b = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: '',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(b.relativeDate, '3h ago');
    });

    test('days ago', () {
      final b = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: '',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(b.relativeDate, '2d ago');
    });

    test('older than a week shows formatted date', () {
      final b = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: '',
        publishedAt: DateTime(2026, 1, 2),
      );
      expect(b.relativeDate, matches(r'Jan 2, 2026'));
    });
  });

  group('equality', () {
    test('two Berita with same id/title/url are equal', () {
      final a = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: 'x',
        publishedAt: DateTime(2026, 1, 1),
      );
      final b = Berita(
        id: 'a',
        title: 't',
        source: 'different',
        url: 'u',
        imageUrl: 'https://e.com',
        snippet: 'y',
        publishedAt: DateTime(2026, 1, 2),
      );
      expect(a, b);
    });

    test('different id not equal', () {
      final a = Berita(
        id: 'a',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: 'x',
        publishedAt: DateTime(2026, 1, 1),
      );
      final b = Berita(
        id: 'b',
        title: 't',
        source: 's',
        url: 'u',
        imageUrl: null,
        snippet: 'x',
        publishedAt: DateTime(2026, 1, 1),
      );
      expect(a, isNot(b));
    });
  });
}