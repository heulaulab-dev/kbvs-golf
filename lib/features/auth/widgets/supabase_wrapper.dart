import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase client initialization via supabase_flutter's Supabase.initialize().
///
/// Reads environment variables at compile time:
/// - SUPABASE_URL
/// - SUPABASE_ANON_KEY
///
/// Provides a singleton client instance accessible throughout the app.
class SupabaseWrapper {
  static bool _initialized = false;

  /// Initialize once at app startup using supabase_flutter's initialize()
  /// This sets up proper PKCE async storage for auth flows.
  static Future<void> init({required String baseUrl, required String anonKey}) async {
    if (_initialized) return; // Already initialized

    await Supabase.initialize(
      url: baseUrl,
      publishableKey: anonKey,
    );
    _initialized = true;
  }

  /// Get the singleton client instance
  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call SupabaseWrapper.init() first.');
    }
    return Supabase.instance.client;
  }

  /// Check if already initialized
  static bool get initialized => _initialized;
}

/// Extension to easily call init from main without exposing parameters
extension SupabaseWrapperExtension on SupabaseWrapper {
  static Future<void> initWithEnv() async {
    final baseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    final anonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    if (baseUrl.isEmpty || anonKey.isEmpty) {
      throw SupabaseInitError('SUPABASE_URL and SUPABASE_ANON_KEY must be set via --dart-define at build time.');
    }

    await SupabaseWrapper.init(baseUrl: baseUrl, anonKey: anonKey);
  }
}

/// Custom error type for Supabase initialization failures
class SupabaseInitError implements Exception {
  final String message;

  SupabaseInitError(this.message);

  @override
  String toString() => 'SupabaseInitError: $message';
}
