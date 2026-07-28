import 'dart:async';

/// Abstract HTTP client abstraction that wraps Dio for testability.
///
/// Decouples tournament repository from Dio so we can swap implementations
/// (real Dio, mock adapter, in-memory fake) without touching repository code.
abstract class HttpClient {
  /// Performs a GET request and returns parsed JSON body.
  ///
  /// Throws [HttpException] on non-2xx status or network errors.
  /// Throws [HttpTimeoutException] when request exceeds timeout.
  Future<dynamic> getJson(
    String url, {
    Map<String, String>? queryParameters,
  });
}

class HttpException implements Exception {
  final int statusCode;
  final String? message;
  HttpException(this.statusCode, [this.message]);
  @override
  String toString() => 'HttpException($statusCode${message != null ? ': $message' : ''})';
}

class HttpTimeoutException implements Exception {
  final Duration timeout;
  HttpTimeoutException(this.timeout);
  @override
  String toString() => 'HttpTimeoutException(${timeout.inSeconds}s)';
}
