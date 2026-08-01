import 'package:dio/dio.dart';

import '../../../core/config.dart';

/// Dio client configured with base URL from [AppConfig].
///
/// Uses the active environment's API base URL via [AppConfig.instance].
class ApiClient {
  ApiClient._(this._dio);

  final Dio _dio;

  /// Creates a client for the given base URL.
  factory ApiClient({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    // Add interceptors: auth, logging, error handling...
    return ApiClient._(dio);
  }

  /// Factory using the active environment's API base URL.
  factory ApiClient.fromConfig() {
    return ApiClient(baseUrl: AppConfig.instance.tournamentApiBaseUrl);
  }

  /// Convenience factory for a specific service's base URL.
  factory ApiClient.forTournaments() {
    return ApiClient(baseUrl: AppConfig.instance.tournamentApiBaseUrl);
  }

  factory ApiClient.forNews() {
    return ApiClient(baseUrl: AppConfig.instance.newsApiBaseUrl);
  }

  factory ApiClient.forCaddy() {
    final url = AppConfig.instance.caddyApiBaseUrl;
    if (url == null || url.isEmpty) {
      throw StateError('CADDY_API_BASE_URL not configured for current env');
    }
    return ApiClient(baseUrl: url);
  }

  /// GET request returning parsed JSON.
  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return _parseResponse(response);
  }

  /// POST request returning parsed JSON.
  Future<Map<String, dynamic>> postJson(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.post(path, data: data, queryParameters: queryParameters);
    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'HTTP ${response.statusCode}: ${response.statusMessage}',
      );
    }
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    throw FormatException('Expected JSON object, got ${data.runtimeType}');
  }
}