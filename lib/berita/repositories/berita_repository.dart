import '../models/berita.dart';

/// Abstract repository for news / berita content.
///
/// Implementations: [MockBeritaRepository] (in-memory), [HttpBeritaRepository]
/// (talks to golfie-api via the existing [HttpClient] abstraction).
abstract class BeritaRepository {
  /// Fetches the current trending list.
  Future<List<Berita>> getTrending();

  /// Searches by free-text query. Returns `[]` for empty/whitespace query.
  Future<List<Berita>> search(String query);
}