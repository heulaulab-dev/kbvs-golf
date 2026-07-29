import '../models/berita.dart';
import 'berita_repository.dart';

/// In-memory mock repository. Used by tests and previews.
class MockBeritaRepository implements BeritaRepository {
  final List<Berita> _trending;
  final List<Berita> _searchIndex;

  MockBeritaRepository({
    List<Berita>? trending,
    List<Berita>? searchIndex,
  })  : _trending = trending ?? _defaultTrending,
        _searchIndex = searchIndex ?? (trending ?? _defaultTrending);

  static final List<Berita> _defaultTrending = [
    Berita(
      id: 'seed-001',
      title: 'Indonesian Open 2026: Schedule, Players, and Where to Watch',
      source: 'golf.co.id',
      url: 'https://example.com/news/indonesian-open-2026',
      imageUrl: 'https://picsum.photos/seed/indo-open/800/450',
      snippet:
          'The Indonesian Open returns to Royale Jakarta Golf Club this November with a record \$1.5M purse and a field led by three top-50 players.',
      publishedAt: DateTime.parse('2026-07-28T08:00:00Z'),
    ),
    Berita(
      id: 'seed-002',
      title: 'Jakarta Golf Course Rankings: Top 10 for 2026',
      source: 'golfdigest.co.id',
      url: 'https://example.com/news/jakarta-rankings-2026',
      imageUrl: 'https://picsum.photos/seed/jkt-rank/800/450',
      snippet:
          'From Royale Jakarta to Damai Indah, here are the ten courses Jakarta golfers are talking about this year.',
      publishedAt: DateTime.parse('2026-07-26T10:30:00Z'),
    ),
    Berita(
      id: 'seed-003',
      title: 'How to Lower Your Handicap by 5 Strokes in 6 Months',
      source: 'golf.com',
      url: 'https://example.com/news/lower-handicap-5',
      imageUrl: 'https://picsum.photos/seed/handicap/800/450',
      snippet:
          'A practical guide to breaking through the mid-handicap plateau.',
      publishedAt: DateTime.parse('2026-07-25T14:00:00Z'),
    ),
    Berita(
      id: 'seed-004',
      title: 'PGA Tour announces new Asia swing for 2027 season',
      source: 'pgatour.com',
      url: 'https://example.com/news/pga-asia-swing-2027',
      imageUrl: 'https://picsum.photos/seed/pga-asia/800/450',
      snippet:
          'Three new events in Tokyo, Seoul, and Singapore will join the FedEx Cup schedule.',
      publishedAt: DateTime.parse('2026-07-24T09:15:00Z'),
    ),
    Berita(
      id: 'seed-005',
      title: 'Best Golf Apps for Tracking Stats in 2026',
      source: 'mygolfspy.com',
      url: 'https://example.com/news/best-golf-apps-2026',
      imageUrl: 'https://picsum.photos/seed/golf-apps/800/450',
      snippet:
          'Arccos, ShotScope, and the new kid on the block.',
      publishedAt: DateTime.parse('2026-07-22T11:00:00Z'),
    ),
  ];

  @override
  Future<List<Berita>> getTrending() async {
    final sorted = [..._trending]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return sorted;
  }

  @override
  Future<List<Berita>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _searchIndex.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.snippet.toLowerCase().contains(q) ||
          b.source.toLowerCase().contains(q);
    }).toList();
  }
}
