import 'package:flutter_test/flutter_test.dart';
import 'package:golfie/berita/repositories/mock_berita_repository.dart';

void main() {
  group('MockBeritaRepository', () {
    test('default trending is non-empty', () async {
      final repo = MockBeritaRepository();
      final items = await repo.getTrending();
      expect(items, isNotEmpty);
      expect(items.length, greaterThanOrEqualTo(3));
    });

    test('trending is sorted by publishedAt desc', () async {
      final repo = MockBeritaRepository();
      final items = await repo.getTrending();
      for (var i = 0; i < items.length - 1; i++) {
        expect(
          items[i].publishedAt.isAfter(items[i + 1].publishedAt) ||
              items[i].publishedAt.isAtSameMomentAs(items[i + 1].publishedAt),
          isTrue,
        );
      }
    });

    test('search matches case-insensitively', () async {
      final repo = MockBeritaRepository();
      final hits = await repo.search('INDONESIAN');
      expect(hits, isNotEmpty);
    });

    test('search empty query returns empty', () async {
      final repo = MockBeritaRepository();
      expect(await repo.search(''), isEmpty);
      expect(await repo.search('   '), isEmpty);
    });

    test('search nonsense returns empty', () async {
      final repo = MockBeritaRepository();
      expect(await repo.search('xyzqqq-not-real'), isEmpty);
    });
  });
}