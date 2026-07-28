import 'package:dio/dio.dart';

import 'http_client.dart';

/// Production HTTP client backed by [Dio].
///
/// Configures timeouts per PRD §8 (15s connect, 15s receive) and
/// decodes JSON responses. Throws [HttpException] on non-2xx
/// responses and [HttpTimeoutException] when Dio's timeout fires.
class DioHttpClient implements HttpClient {
  final Dio _dio;

  DioHttpClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                responseType: ResponseType.json,
                headers: {'Accept': 'application/json'},
              ),
            );

  @override
  Future<dynamic> getJson(
    String url, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
      );
      final code = response.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        throw HttpException(code, response.statusMessage);
      }
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        final timeout = e.response?.requestOptions.receiveTimeout ??
            e.response?.requestOptions.connectTimeout ??
            const Duration(seconds: 15);
        throw HttpTimeoutException(timeout);
      }
      final code = e.response?.statusCode ?? 0;
      throw HttpException(code, e.message);
    }
  }
}
