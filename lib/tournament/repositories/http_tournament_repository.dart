import 'dart:async';

import '../models/tournament.dart';
import '../repositories/tournament_repository.dart';
import '../services/dio_http_client.dart';
import '../services/http_client.dart';

class HttpTournamentRepository implements TournamentRepository {
  final HttpClient _client;
  final String _baseUrl;

  HttpTournamentRepository({
    HttpClient? client,
    String baseUrl = 'api-local.kbvalbury.com:9100',
  }) : _client = client ?? DioHttpClient(),
        _baseUrl = baseUrl;

  factory HttpTournamentRepository.withClient(HttpClient client, String baseUrl) {
    return HttpTournamentRepository(client: client, baseUrl: baseUrl);
  }

  @override
  Future<(List<Tournament>, int, bool)> getFirstPage() async {
    final resp = await _client.getJson('$_baseUrl/tournaments');
    if (resp is! Map<String, dynamic>) {
      throw FormatException('Expected map response, got ${resp.runtimeType}');
    }
    final List<dynamic> results = (resp['results'] ?? []) as List;
    final int total = (resp['total'] ?? results.length) as int;
    final bool hasNext = resp['has_next'] as bool;
    final List<Tournament> tournaments = List<Tournament>.from(results.map((r) => Tournament.fromJson(r)));
    return (tournaments, total, hasNext);
  }

  @override
  Future<(List<Tournament>, int, bool)> nextPage({String? cursor}) async {
    final params = cursor != null ? <String, String>{'cursor': cursor} : null;
    final resp = await _client.getJson('$_baseUrl/tournaments', queryParameters: params);
    if (resp is! Map<String, dynamic>) {
      throw FormatException('Expected map response, got ${resp.runtimeType}');
    }
    final List<dynamic> results = (resp['results'] ?? []) as List;
    final int total = (resp['total'] ?? results.length) as int;
    final bool hasNext = resp['has_next'] as bool;
    final List<Tournament> tournaments = List<Tournament>.from(results.map((r) => Tournament.fromJson(r)));
    return (tournaments, total, hasNext);
  }

  @override
  Future<(List<Tournament>, int, bool)> prevPage({String? cursor}) async {
    final List<Tournament> empty = <Tournament>[];
    return (empty, 0, false);
  }

  @override
  Future<Tournament> getById(String id) async {
    try {
      final resp = await _client.getJson('$_baseUrl/tournaments/$id');
      if (resp is! Map<String, dynamic>) {
        throw FormatException('Expected tournament JSON, got ${resp.runtimeType}');
      }
      return Tournament.fromJson(resp);
    } on HttpException catch (e) {
      if (e.statusCode == 404) {
        throw const FormatException('Not found');
      }
      rethrow;
    }
  }

  @override
  Future<(List<Tournament>, int, bool)> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      final List<Tournament> empty = [];
      return (empty, 0, false);
    }
    final resp = await _client.getJson(
      '$_baseUrl/tournaments',
      queryParameters: {'search': trimmed},
    );
    if (resp is! Map<String, dynamic>) {
      throw FormatException('Expected map response, got ${resp.runtimeType}');
    }
    final List<dynamic> results = (resp['results'] ?? []) as List;
    final int total = (resp['total'] ?? results.length) as int;
    final bool hasNext = resp['has_next'] as bool;
    final List<Tournament> tournaments = List<Tournament>.from(results.map((r) => Tournament.fromJson(r)));
    return (tournaments, total, hasNext);
  }

  @override
  Future<void> register(String tournamentId) async {
    // Call registration endpoint
    // In a real system this would be a POST/PUT to /tournaments/{id}/register
    // Using GET for happy-path simulation (endpoint handles registration on GET for simplicity)
    await _client.getJson('$_baseUrl/tournaments/$tournamentId/register');
  }
}
