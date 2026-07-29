import '../../tournament/services/dio_http_client.dart';
import '../../tournament/services/http_client.dart';
import '../models/berita.dart';
import 'berita_repository.dart';

/// HTTP repository backed by golfie-api.
class HttpBeritaRepository implements BeritaRepository {
  final HttpClient _client;
  final String _baseUrl;

  HttpBeritaRepository({
    HttpClient? client,
    String baseUrl = 'http://10.0.2.2:3001', // android emulator -> host
  })  : _client = client ?? DioHttpClient(),
        _baseUrl = baseUrl;

  factory HttpBeritaRepository.withClient(HttpClient client, String baseUrl) {
    return HttpBeritaRepository(client: client, baseUrl: baseUrl);
  }

  @override
  Future<List<Berita>> getTrending() async {
    final resp = await _client.getJson('$_baseUrl/news/trending');
    if (resp is! Map<String, dynamic>) {
      throw FormatException('Expected map response, got ${resp.runtimeType}');
    }
    final List<dynamic> items = (resp['items'] ?? []) as List;
    return items
        .whereType<Map<String, dynamic>>()
        .map(Berita.fromJson)
        .toList();
  }

  @override
  Future<List<Berita>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final resp = await _client.getJson(
      '$_baseUrl/news/search',
      queryParameters: <String, String>{'q': q},
    );
    if (resp is! Map<String, dynamic>) {
      throw FormatException('Expected map response, got ${resp.runtimeType}');
    }
    final List<dynamic> items = (resp['items'] ?? []) as List;
    return items
        .whereType<Map<String, dynamic>>()
        .map(Berita.fromJson)
        .toList();
  }
}